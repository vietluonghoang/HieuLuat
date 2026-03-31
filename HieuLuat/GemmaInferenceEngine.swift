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
class GemmaInferenceEngine {

    private let embedModel: MLModel
    private let ffnModels: [MLModel]
    private let lmHeadModel: MLModel

    private var ffnStates: [MLState]
    private var contextPosition: Int = 0

    /// Set to `true` by the caller to request early termination of an in-flight generate().
    var isCancelled: Bool = false

    private let contextLength: Int
    private let slidingWindow: Int

    /// Which optional inputs the FFN model actually accepts (detected at init).
    private let ffnAcceptsCurrentPos: Bool

    /// Serial queue to ensure only one inference runs at a time.
    private let inferenceQueue = DispatchQueue(label: "com.hieuluat.gemma.inference", qos: .userInitiated)

    private static let maskedValue: Float16 = -65504.0

    init(embedModel: MLModel, ffnModels: [MLModel], lmHeadModel: MLModel,
         contextLength: Int = 4096, slidingWindow: Int = 1024) {
        self.embedModel = embedModel
        self.ffnModels = ffnModels
        self.lmHeadModel = lmHeadModel
        self.contextLength = contextLength
        self.slidingWindow = slidingWindow
        self.ffnStates = ffnModels.map { $0.makeState() }

        // Detect which inputs the FFN model accepts by inspecting its description
        self.ffnAcceptsCurrentPos = GemmaInferenceEngine.modelAcceptsInput(ffnModels.first, name: "current_pos")
        print("GemmaInferenceEngine: FFN accepts current_pos = \(self.ffnAcceptsCurrentPos)")
    }

    /// Inspect a model's input description to check if it has a given input name.
    private static func modelAcceptsInput(_ model: MLModel?, name: String) -> Bool {
        guard let model = model else { return false }
        let desc = model.modelDescription
        return desc.inputDescriptionsByName[name] != nil
    }

    // MARK: - Public API

    /// Run inference synchronously on the internal serial queue.
    /// The completion closure is called on the main queue.
    func runGenerate(inputTokens: [Int], maxNewTokens: Int = 256,
                     stopTokenIds: Set<Int>, completion: @escaping ([Int]) -> Void) {
        isCancelled = false
        inferenceQueue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            let tokens = self.generate(inputTokens: inputTokens, maxNewTokens: maxNewTokens,
                                       stopTokenIds: stopTokenIds)
            DispatchQueue.main.async { completion(tokens) }
        }
    }

    private func generate(inputTokens: [Int], maxNewTokens: Int, stopTokenIds: Set<Int>) -> [Int] {
        guard !inputTokens.isEmpty else { return [] }

        // Reset state at the start of each generation
        resetState()

        do {
            // Prefill: process all input tokens one-by-one (memory safe)
            for i in 0..<inputTokens.count {
                if isCancelled { return [] }

                if i % 50 == 0 && i > 0 {
                    print("GemmaInferenceEngine: prefill \(i)/\(inputTokens.count)")
                }
                try inferSingleToken(tokenId: inputTokens[i])
            }
            print("GemmaInferenceEngine: prefill done (\(inputTokens.count) tokens)")

            // Decode: generate new tokens auto-regressively
            var generatedTokens = [Int]()
            var currentToken = inputTokens.last!

            for step in 0..<maxNewTokens {
                if isCancelled { return generatedTokens }

                let nextToken = try decodeOneToken(tokenId: currentToken)
                generatedTokens.append(nextToken)

                if step < 3 {
                    print("GemmaInferenceEngine: decode step \(step) → token \(nextToken)")
                }

                if stopTokenIds.contains(nextToken) {
                    break
                }
                currentToken = nextToken
            }

            return generatedTokens
        } catch {
            print("GemmaInferenceEngine error: \(error)")
            return []
        }
    }

    func resetState() {
        contextPosition = 0
        ffnStates = ffnModels.map { $0.makeState() }
    }

    // MARK: - Single Token Processing

    /// Process one token through embed → FFN → advance position (prefill).
    private func inferSingleToken(tokenId: Int) throws {
        let inputIds = try createInputIds(token: tokenId)
        let embedOutput = try runEmbeddings(inputIds: inputIds)

        _ = try runFFNChunks(hiddenStates: embedOutput)
        contextPosition += 1
    }

    /// Process one token and return the next predicted token (decode).
    private func decodeOneToken(tokenId: Int) throws -> Int {
        let inputIds = try createInputIds(token: tokenId)
        let embedOutput = try runEmbeddings(inputIds: inputIds)

        let hiddenStates = try runFFNChunks(hiddenStates: embedOutput)
        contextPosition += 1

        return try runLMHead(hiddenStates: hiddenStates)
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
            let output = try ffnModel.prediction(from: provider, using: ffnStates[index])
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
