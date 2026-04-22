//
//  GemmaInferenceEngine.swift
//  HieuLuat
//
//  Created by AI Assistant on 3/30/26.
//  Copyright © 2026 VietLH. All rights reserved.
//

import CoreML
import Foundation

@available(iOS 18.0, *)
class GemmaInferenceEngine: AIInferenceEngine {

    private let embedModel: MLModel
    private let ffnModels: [MLModel]
    private let lmHeadModel: MLModel

    private var ffnState: MLState
    private var contextPosition: Int = 0

    /// Set to `true` by the caller to request early termination of an in-flight generate().
    var isCancelled: Bool = false

    private let contextLength: Int
    private let slidingWindow: Int

    /// Which optional inputs the FFN model actually accepts (detected at init).
    private let ffnAcceptsCurrentPos: Bool

    private static let maskedValue: Float16 = -65504.0

    init(embedModel: MLModel, ffnModels: [MLModel], lmHeadModel: MLModel,
         contextLength: Int = 4096, slidingWindow: Int = 1024) {
        self.embedModel = embedModel
        self.ffnModels = ffnModels
        self.lmHeadModel = lmHeadModel
        self.contextLength = contextLength
        self.slidingWindow = slidingWindow
        self.ffnState = ffnModels.first!.makeState()

        // Detect which inputs the FFN model accepts by inspecting its description
        self.ffnAcceptsCurrentPos = GemmaInferenceEngine.modelAcceptsInput(ffnModels.first, name: "current_pos")

        // Log model input/output info for debugging
        Self.logModelInfo("Embed", embedModel)
        Self.logModelInfo("FFN[0]", ffnModels.first)
        Self.logModelInfo("LMHead", lmHeadModel)
    }

    private static func logModelInfo(_ label: String, _ model: MLModel?) {
        guard let model = model else { return }
        let inputs = model.modelDescription.inputDescriptionsByName.keys.sorted()
        let outputs = model.modelDescription.outputDescriptionsByName.keys.sorted()
        NSLog("GemmaEngine: %@ inputs=%@ outputs=%@", label, inputs.description, outputs.description)
    }

    /// Inspect a model's input description to check if it has a given input name.
    private static func modelAcceptsInput(_ model: MLModel?, name: String) -> Bool {
        guard let model = model else { return false }
        return model.modelDescription.inputDescriptionsByName[name] != nil
    }

    // MARK: - Public API

    /// Run inference on a background thread. Completion is called on the main queue.
    func runGenerate(inputTokens: [Int], maxNewTokens: Int = 256,
                     stopTokenIds: Set<Int>, completion: @escaping ([Int]) -> Void) {
        // NOTE: isCancelled is set to false INSIDE the async block to avoid race condition
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion([]) }
                return
            }

            // Reset cancellation at the start of actual work
            self.isCancelled = false

            NSLog("GemmaEngine: generate() starting on background thread")
            let tokens = self.generate(inputTokens: inputTokens, maxNewTokens: maxNewTokens,
                                       stopTokenIds: stopTokenIds)
            NSLog("GemmaEngine: generate() finished with %d tokens", tokens.count)

            DispatchQueue.main.async { completion(tokens) }
        }
    }

    func runGenerate(prompt: String, maxNewTokens: Int,
                     stopTokenIds: Set<Int>, completion: @escaping ([Int]) -> Void) {
        // GemmaEngine doesn't support direct string prompt (it needs tokenized inputs)
        completion([])
    }

    private func generate(inputTokens: [Int], maxNewTokens: Int, stopTokenIds: Set<Int>) -> [Int] {
        guard !inputTokens.isEmpty else { return [] }

        // Reset state at the start of each generation
        resetState()

        NSLog("GemmaEngine: prefill starting (%d tokens, contextLength=%d)", inputTokens.count, contextLength)

        do {
            // Prefill: process all input tokens one-by-one (memory safe)
            for i in 0..<inputTokens.count {
                if isCancelled {
                    NSLog("GemmaEngine: prefill cancelled at %d/%d", i, inputTokens.count)
                    return []
                }

                if i == 0 {
                    NSLog("GemmaEngine: prefill token 0 (first call)...")
                }

                try inferSingleToken(tokenId: inputTokens[i])

                if i == 0 {
                    NSLog("GemmaEngine: prefill token 0 succeeded")
                } else if i % 200 == 0 {
                    NSLog("GemmaEngine: prefill %d/%d", i, inputTokens.count)
                }
            }
            NSLog("GemmaEngine: prefill done, contextPosition=%d", contextPosition)

            // Decode: generate new tokens auto-regressively
            var generatedTokens = [Int]()
            var currentToken = inputTokens.last!
            NSLog("GemmaEngine: starting decode loop (lastToken=%d, isCancelled=%d)", currentToken, isCancelled ? 1 : 0)

            for step in 0..<maxNewTokens {
                if isCancelled {
                    NSLog("GemmaEngine: decode cancelled at step %d", step)
                    return generatedTokens
                }

                let nextToken = try decodeOneToken(tokenId: currentToken)
                generatedTokens.append(nextToken)

                if step < 2 {
                    NSLog("GemmaEngine: decode step %d → token %d", step, nextToken)
                }

                if stopTokenIds.contains(nextToken) {
                    NSLog("GemmaEngine: stop token reached at step %d", step)
                    break
                }
                currentToken = nextToken
            }

            return generatedTokens
        } catch {
            NSLog("GemmaEngine ERROR: %@", "\(error)")
            return []
        }
    }

    func resetState() {
        contextPosition = 0
        decodeCount = 0
        ffnState = ffnModels.first!.makeState()
    }

    // MARK: - Single Token Processing

    /// Process one token through embed → FFN → advance position (prefill).
    private func inferSingleToken(tokenId: Int) throws {
        let inputIds = try createInputIds(token: tokenId)

        if contextPosition == 0 {
            NSLog("GemmaEngine: [token 0] running embeddings (first call — ANE compile may take 1-2 min)...")
        }
        let embedOutput = try runEmbeddings(inputIds: inputIds)
        if contextPosition == 0 {
            NSLog("GemmaEngine: [token 0] embeddings OK, running FFN %d chunks (ANE compile may take 1-2 min per chunk)...", ffnModels.count)
        }

        _ = try runFFNChunks(hiddenStates: embedOutput)

        if contextPosition == 0 {
            NSLog("GemmaEngine: [token 0] ✅ first token complete — ANE compilation done")
        } else if contextPosition % 200 == 0 {
            NSLog("GemmaEngine: prefill %d/%d", contextPosition, contextPosition) // actual total unknown here
        }

        contextPosition += 1
    }

    private var decodeCount = 0

    /// Process one token and return the next predicted token (decode).
    private func decodeOneToken(tokenId: Int) throws -> Int {
        let inputIds = try createInputIds(token: tokenId)
        let embedOutput = try runEmbeddings(inputIds: inputIds)

        if decodeCount == 0 {
            NSLog("GemmaEngine: decode[0] embed OK, running FFN...")
        }
        let hiddenStates = try runFFNChunks(hiddenStates: embedOutput)

        if decodeCount == 0 {
            NSLog("GemmaEngine: decode[0] FFN OK, running LMHead (first call — ANE compile may take 1-2 min)...")
        }
        contextPosition += 1
        let token = try runLMHead(hiddenStates: hiddenStates)

        if decodeCount == 0 {
            NSLog("GemmaEngine: decode[0] ✅ LMHead OK → token %d", token)
        }
        decodeCount += 1
        return token
    }

    // MARK: - Model Execution

    private func runEmbeddings(inputIds: MLMultiArray) throws -> MLMultiArray {
        let provider = try MLDictionaryFeatureProvider(dictionary: ["input_ids": inputIds])
        let output = try embedModel.prediction(from: provider)
        return output.featureValue(for: "hidden_states")!.multiArrayValue!
    }

    @discardableResult
    private func runFFNChunks(hiddenStates: MLMultiArray) throws -> MLMultiArray {
        let positionIds = try createPositionIds(position: contextPosition)
        let causalMask = try createCausalMask(position: contextPosition)

        var currentHiddenStates = hiddenStates

        for (index, ffnModel) in ffnModels.enumerated() {
            var inputDict: [String: Any] = [
                "hidden_states": currentHiddenStates,
                "position_ids": positionIds,
                "causal_mask": causalMask
            ]

            // Only include current_pos if the model expects it
            if ffnAcceptsCurrentPos {
                inputDict["current_pos"] = try createCurrentPos(value: contextPosition)
            }

            let provider = try MLDictionaryFeatureProvider(dictionary: inputDict)
            let output = try ffnModel.prediction(from: provider, using: ffnState)
            currentHiddenStates = output.featureValue(for: "output_hidden_states")!.multiArrayValue!
        }

        return currentHiddenStates
    }

    private func runLMHead(hiddenStates: MLMultiArray) throws -> Int {
        let provider = try MLDictionaryFeatureProvider(dictionary: ["hidden_states": hiddenStates])
        let output = try lmHeadModel.prediction(from: provider)

        // Support argmax_ids (new) / argmax_idx (legacy)
        if let arr = output.featureValue(for: "argmax_ids")?.multiArrayValue {
            return Int(arr[0].int32Value)
        }
        if let arr = output.featureValue(for: "argmax_idx")?.multiArrayValue {
            return Int(arr[0].int32Value)
        }

        // Fallback: logits
        let logits = output.featureValue(for: "logits")!.multiArrayValue!
        var maxVal: Float = -Float.infinity
        var maxIdx = 0
        let count = logits.count
        let ptr = logits.dataPointer.bindMemory(to: Float16.self, capacity: count)
        for i in 0..<count {
            let val = Float(ptr[i])
            if val > maxVal {
                maxVal = val
                maxIdx = i
            }
        }
        return maxIdx
    }

    // MARK: - MLMultiArray Construction (single-token)

    private func createInputIds(token: Int) throws -> MLMultiArray {
        let array = try MLMultiArray(shape: [1, 1], dataType: .int32)
        array[0] = NSNumber(value: Int32(token))
        return array
    }

    private func createPositionIds(position: Int) throws -> MLMultiArray {
        // Rank 1: shape [1] — model requires rank 1
        let array = try MLMultiArray(shape: [1], dataType: .int32)
        array[0] = NSNumber(value: Int32(position))
        return array
    }

    private func createCurrentPos(value: Int) throws -> MLMultiArray {
        let array = try MLMultiArray(shape: [1], dataType: .int32)
        array[0] = NSNumber(value: Int32(value))
        return array
    }

    private func createCausalMask(position: Int) throws -> MLMultiArray {
        // Single-token mask: [1, 1, 1, contextLength]
        let array = try MLMultiArray(shape: [1, 1, 1, NSNumber(value: contextLength)],
                                     dataType: .float16)
        let ptr = array.dataPointer.bindMemory(to: Float16.self, capacity: contextLength)

        for j in 0..<contextLength {
            let visible: Bool
            if j > position {
                visible = false
            } else if (position - j) > slidingWindow {
                visible = false
            } else {
                visible = true
            }
            ptr[j] = visible ? Float16(0.0) : Self.maskedValue
        }

        return array
    }
}
