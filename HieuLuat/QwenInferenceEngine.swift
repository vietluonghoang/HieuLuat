//
//  QwenInferenceEngine.swift
//  HieuLuat
//
//  Created by AI Assistant on 4/1/26.
//  Copyright © 2026 VietLH. All rights reserved.
//

import CoreML
import Foundation

/// Inference engine for Qwen3 models converted via ANEMLL.
/// Key differences from Gemma:
/// - FFN chunks are multi-function models with separate prefill + infer functions
/// - Prefill function: hidden_states, position_ids, causal_mask, current_pos (no update_mask)
/// - Infer function: hidden_states, update_mask, position_ids, causal_mask, current_pos
/// - LM head uses split logits (logits1..logitsN)
/// - Global attention (no sliding window)
///
/// Memory management: FFN models are cached between inferences.
/// Infer models stay resident; prefill models are loaded lazily and evicted on memory warning.
@available(iOS 18.0, *)
class QwenInferenceEngine: AIInferenceEngine {
    
    private let embedModel: MLModel
    private let lmHeadModel: MLModel
    
    /// FFN model file URLs — used to load prefill/infer functions on demand.
    private let ffnURLs: [URL]
    
    /// Cached FFN models — kept across inferences to avoid expensive reloads.
    private var prefillModels: [MLModel]?
    private var inferModels: [MLModel]?
    
    /// Currently active FFN models (points to either prefillModels or inferModels).
    private var activeFFNModels: [MLModel] = []
    private var activeFunction: String? = nil
    
    /// Single unified KV cache state shared across all FFN chunks and both functions.
    private var ffnState: MLState!
    private var contextPosition: Int = 0
    private var decodeCount: Int = 0
    
    var isCancelled: Bool = false
    
    /// Serial queue to prevent overlapping inference runs.
    private let inferenceQueue = DispatchQueue(label: "com.hieuluat.qwen.inference")
    /// Generation ID to detect stale results after cancellation.
    private var generationID: UInt64 = 0
    
    /// Reusable decode-step buffers (allocated once, mutated in-place each step).
    private var reusableInputIds: MLMultiArray?
    private var reusablePositionIds: MLMultiArray?
    private var reusableCurrentPos: MLMultiArray?
    private var reusableUpdateMask: MLMultiArray?
    private var reusableCausalMask: MLMultiArray?
    /// Whether the infer function accepts update_mask (detected once).
    private var inferNeedsUpdateMask: Bool?
    
    private let contextLength: Int
    private let batchSize: Int
    private let splitLmHead: Int
    
    private static let maskedValue: Float16 = -65504.0
    
    init(embedModel: MLModel, ffnURLs: [URL], lmHeadModel: MLModel,
         contextLength: Int, batchSize: Int, splitLmHead: Int) {
        self.embedModel = embedModel
        self.ffnURLs = ffnURLs
        self.lmHeadModel = lmHeadModel
        self.contextLength = contextLength
        self.batchSize = batchSize
        self.splitLmHead = splitLmHead
        
        Self.logModelInfo("Embed", embedModel)
        Self.logModelInfo("LMHead", lmHeadModel)
        NSLog("QwenEngine: init with %d FFN URLs, ctx=%d, batch=%d", ffnURLs.count, contextLength, batchSize)
        
        // Pre-allocate reusable decode buffers
        allocateReusableBuffers()
    }
    
    private static func logModelInfo(_ label: String, _ model: MLModel?) {
        guard let model = model else { return }
        let inputs = model.modelDescription.inputDescriptionsByName.keys.sorted()
        let outputs = model.modelDescription.outputDescriptionsByName.keys.sorted()
        NSLog("QwenEngine: %@ inputs=%@ outputs=%@", label, inputs.description, outputs.description)
    }
    
    // MARK: - Reusable Buffers
    
    private func allocateReusableBuffers() {
        do {
            reusableInputIds = try MLMultiArray(shape: [1, 1], dataType: .int32)
            reusablePositionIds = try MLMultiArray(shape: [1], dataType: .int32)
            reusableCurrentPos = try MLMultiArray(shape: [1], dataType: .int32)
            reusableUpdateMask = try MLMultiArray(
                shape: [1, 1, NSNumber(value: contextLength), 1], dataType: .float16)
            reusableCausalMask = try MLMultiArray(
                shape: [1, 1, 1, NSNumber(value: contextLength)], dataType: .float16)
        } catch {
            NSLog("QwenEngine: Failed to pre-allocate buffers: %@", "\(error)")
        }
    }
    
    // MARK: - FFN Loading (cached)
    
    /// Whether models are single-function (Neural Network) — detected on first load.
    private var isSingleFunctionModel: Bool?
    
    /// Activate the prefill or infer FFN model set.
    /// Models are cached: first load from disk, subsequent activations are instant.
    /// For single-function models (Neural Network), prefill and infer share the same loaded models.
    private func activateFFN(functionName: String) throws {
        if activeFunction == functionName && !activeFFNModels.isEmpty {
            return // Already active
        }
        
        // Single-function models: both phases use the same model — just switch the label.
        if let singleFunc = isSingleFunctionModel, singleFunc {
            if let cached = prefillModels ?? inferModels {
                activeFFNModels = cached
                activeFunction = functionName
                NSLog("QwenEngine: Activated single-function FFN as '%@' (%d chunks)", functionName, cached.count)
                return
            }
        }
        
        switch functionName {
        case "prefill":
            if let cached = prefillModels {
                activeFFNModels = cached
                activeFunction = "prefill"
                NSLog("QwenEngine: Activated cached prefill FFN (%d chunks)", cached.count)
                return
            }
            // First load
            let models = try loadFFNFromDisk(functionName: "prefill")
            prefillModels = models
            activeFFNModels = models
            activeFunction = "prefill"
            
            // If first load succeeded as single-function, share with infer too
            if isSingleFunctionModel == true {
                inferModels = models
            }
            
        case "infer":
            if let cached = inferModels {
                activeFFNModels = cached
                activeFunction = "infer"
                NSLog("QwenEngine: Activated cached infer FFN (%d chunks)", cached.count)
                return
            }
            // First load
            let models = try loadFFNFromDisk(functionName: "infer")
            inferModels = models
            activeFFNModels = models
            activeFunction = "infer"
            
            // Detect if infer function needs update_mask (check once)
            if inferNeedsUpdateMask == nil, let first = models.first {
                inferNeedsUpdateMask = first.modelDescription.inputDescriptionsByName["update_mask"] != nil
            }
            
        default:
            break
        }
    }
    
    private static let maxLoadRetries = 3
    private static let retryDelay: TimeInterval = 2.0
    
    private func loadFFNFromDisk(functionName: String) throws -> [MLModel] {
        NSLog("QwenEngine: Loading FFN with '%@' function (%d chunks)...", functionName, ffnURLs.count)
        
        var models: [MLModel] = []
        for (index, url) in ffnURLs.enumerated() {
            let model = try loadSingleFFN(url: url, functionName: functionName, chunkIndex: index)
            models.append(model)
            NSLog("QwenEngine: FFN chunk %d/%d loaded with '%@'", index + 1, ffnURLs.count, functionName)
        }
        
        Self.logModelInfo("FFN-\(functionName)[0]", models.first)
        return models
    }
    
    /// Load a single FFN model with retry logic for transient ANE failures.
    /// Tries multi-function (functionName) first; falls back to single-function if model is not ML Program.
    private func loadSingleFFN(url: URL, functionName: String, chunkIndex: Int) throws -> MLModel {
        var lastError: Error?
        
        for attempt in 1...Self.maxLoadRetries {
            do {
                let config = MLModelConfiguration()
                config.computeUnits = .cpuAndNeuralEngine
                config.functionName = functionName
                return try MLModel(contentsOf: url, configuration: config)
            } catch {
                lastError = error
                let desc = "\(error)"
                NSLog("QwenEngine: FFN chunk %d load attempt %d/%d failed: %@",
                      chunkIndex + 1, attempt, Self.maxLoadRetries, desc)
                
                // Model is not ML Program — functionName not supported.
                // Load without functionName (single-function Neural Network model).
                if desc.contains("functionName") && desc.contains("must be nil") {
                    NSLog("QwenEngine: Model is not ML Program — loading chunk %d without functionName (single-function mode)", chunkIndex + 1)
                    do {
                        let fallbackConfig = MLModelConfiguration()
                        fallbackConfig.computeUnits = .cpuAndNeuralEngine
                        // Do NOT set functionName — model has only one function
                        let model = try MLModel(contentsOf: url, configuration: fallbackConfig)
                        isSingleFunctionModel = true
                        NSLog("QwenEngine: Chunk %d loaded successfully without functionName", chunkIndex + 1)
                        return model
                    } catch {
                        lastError = error
                        NSLog("QwenEngine: Fallback load also failed: %@", "\(error)")
                    }
                    break
                }
                
                // Transient ANE error — wait and retry
                if attempt < Self.maxLoadRetries {
                    NSLog("QwenEngine: Waiting %.0fs before retry...", Self.retryDelay)
                    Thread.sleep(forTimeInterval: Self.retryDelay)
                }
            }
        }
        
        throw lastError!
    }
    
    /// Evict prefill models to free memory (infer models stay resident).
    func evictPrefillModels() {
        if prefillModels != nil {
            prefillModels = nil
            if activeFunction == "prefill" {
                activeFFNModels = []
                activeFunction = nil
            }
            NSLog("QwenEngine: Prefill models evicted to free memory")
        }
    }
    
    // MARK: - AIInferenceEngine Protocol
    
    func runGenerate(inputTokens: [Int], maxNewTokens: Int,
                     stopTokenIds: Set<Int>, completion: @escaping ([Int]) -> Void) {
        // Bump generation ID to invalidate any in-flight run
        generationID &+= 1
        let myID = generationID
        
        inferenceQueue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            
            // Check if already stale before starting
            guard myID == self.generationID else {
                NSLog("QwenEngine: generation %llu stale before start, skipping", myID)
                DispatchQueue.main.async { completion([]) }
                return
            }
            
            self.isCancelled = false
            NSLog("QwenEngine: generate() starting (%d input tokens, gen=%llu)", inputTokens.count, myID)
            let tokens = self.generate(inputTokens: inputTokens, maxNewTokens: maxNewTokens,
                                        stopTokenIds: stopTokenIds, generationID: myID)
            
            // Don't deliver stale results
            guard myID == self.generationID else {
                NSLog("QwenEngine: generation %llu stale after finish, discarding %d tokens", myID, tokens.count)
                DispatchQueue.main.async { completion([]) }
                return
            }
            
            NSLog("QwenEngine: generate() finished with %d tokens (gen=%llu)", tokens.count, myID)
            DispatchQueue.main.async { completion(tokens) }
        }
    }

    func runGenerate(prompt: String, maxNewTokens: Int,
                     stopTokenIds: Set<Int>, completion: @escaping ([Int]) -> Void) {
        // QwenEngine doesn't support direct string prompt (it needs tokenized inputs)
        completion([])
    }
    
    func resetState() {
        contextPosition = 0
        decodeCount = 0
        ffnState = nil
    }
    
    // MARK: - Generate
    
    private func generate(inputTokens: [Int], maxNewTokens: Int,
                          stopTokenIds: Set<Int>, generationID myID: UInt64) -> [Int] {
        guard !inputTokens.isEmpty else { return [] }
        
        resetState()
        
        do {
            // === Phase 1: Prefill ===
            NSLog("QwenEngine: prefill starting (%d tokens, ctx=%d, batch=%d)", inputTokens.count, contextLength, batchSize)
            
            try activateFFN(functionName: "prefill")
            
            // Create fresh KV cache state for this generation
            ffnState = activeFFNModels.first!.makeState()
            
            try runBatchPrefill(inputTokens: inputTokens)
            NSLog("QwenEngine: prefill done, contextPosition=%d", contextPosition)
            
            // === Phase 2: Switch to infer (cached, no reload) ===
            NSLog("QwenEngine: switching FFN from prefill → infer...")
            try activateFFN(functionName: "infer")
            NSLog("QwenEngine: infer models active, starting decode")
            
            // === Phase 3: Decode ===
            var generatedTokens = [Int]()
            var currentToken = inputTokens.last!
            
            for step in 0..<maxNewTokens {
                if isCancelled || myID != generationID {
                    NSLog("QwenEngine: decode cancelled at step %d", step)
                    return generatedTokens
                }
                
                let nextToken: Int = try autoreleasepool {
                    try decodeOneToken(tokenId: currentToken)
                }
                generatedTokens.append(nextToken)
                
                if step < 5 || step % 20 == 0 {
                    NSLog("QwenEngine: decode step %d/%d → token %d", step, maxNewTokens, nextToken)
                }
                
                if stopTokenIds.contains(nextToken) {
                    NSLog("QwenEngine: stop token reached at step %d", step)
                    break
                }
                currentToken = nextToken
            }
            
            return generatedTokens
        } catch {
            NSLog("QwenEngine ERROR: %@", "\(error)")
            return []
        }
    }
    
    // MARK: - Batch Prefill
    
    private func runBatchPrefill(inputTokens: [Int]) throws {
        let contextPos = inputTokens.count
        var batchPos = 0
        
        while batchPos < contextPos {
            if isCancelled {
                NSLog("QwenEngine: prefill cancelled at batch pos %d", batchPos)
                return
            }
            
            let batchEnd = min(batchPos + batchSize, contextPos)
            
            NSLog("QwenEngine: prefill batch %d-%d/%d", batchPos, batchEnd, contextPos)
            
            try autoreleasepool {
                let batchInputIds = try createBatchInputIds(
                    tokens: Array(inputTokens[batchPos..<batchEnd]),
                    padToSize: batchSize
                )
                let embedOutput = try runEmbeddings(inputIds: batchInputIds)
                let positionIds = try createBatchPositionIds(start: batchPos, count: batchSize)
                let causalMask = try createBatchCausalMask(start: batchPos, seqLen: batchSize)
                let currentPos = try createScalarInt32(value: batchPos)
                
                var currentHidden = embedOutput
                for ffnModel in activeFFNModels {
                    let inputDict: [String: Any] = [
                        "hidden_states": currentHidden,
                        "position_ids": positionIds,
                        "causal_mask": causalMask,
                        "current_pos": currentPos
                    ]
                    let provider = try MLDictionaryFeatureProvider(dictionary: inputDict)
                    let output = try ffnModel.prediction(from: provider, using: ffnState)
                    currentHidden = output.featureValue(for: "output_hidden_states")!.multiArrayValue!
                }
            }
            
            batchPos = batchEnd
        }
        
        contextPosition = contextPos
    }
    
    // MARK: - Single Token Decode
    
    private func decodeOneToken(tokenId: Int) throws -> Int {
        let inputIds = fillReusableInputIds(token: tokenId)
        let embedOutput = try runEmbeddings(inputIds: inputIds)
        
        if decodeCount == 0 {
            NSLog("QwenEngine: decode[0] embed OK, running FFN infer...")
        }
        
        let inferPos = contextPosition - 1
        let hiddenStates = try runFFNInfer(hiddenStates: embedOutput, position: inferPos)
        
        if decodeCount == 0 {
            NSLog("QwenEngine: decode[0] FFN OK, running LMHead (ANE compile may take 1-2 min)...")
        }
        
        let token = try runLMHead(hiddenStates: hiddenStates)
        
        if decodeCount == 0 {
            NSLog("QwenEngine: decode[0] ✅ LMHead OK → token %d", token)
        }
        
        contextPosition += 1
        decodeCount += 1
        return token
    }
    
    // MARK: - Model Execution
    
    private func runEmbeddings(inputIds: MLMultiArray) throws -> MLMultiArray {
        let provider = try MLDictionaryFeatureProvider(dictionary: ["input_ids": inputIds])
        let output = try embedModel.prediction(from: provider)
        return output.featureValue(for: "hidden_states")!.multiArrayValue!
    }
    
    private func runFFNInfer(hiddenStates: MLMultiArray, position: Int) throws -> MLMultiArray {
        let positionIds = fillReusablePositionIds(position: position)
        let causalMask = fillReusableCausalMask(position: position)
        let currentPos = fillReusableCurrentPos(value: position)
        
        var currentHidden = hiddenStates
        let needsUpdateMask = inferNeedsUpdateMask ?? false
        
        for ffnModel in activeFFNModels {
            var inputDict: [String: Any] = [
                "hidden_states": currentHidden,
                "position_ids": positionIds,
                "causal_mask": causalMask,
                "current_pos": currentPos
            ]
            
            if needsUpdateMask {
                inputDict["update_mask"] = fillReusableUpdateMask(position: position)
            }
            
            let provider = try MLDictionaryFeatureProvider(dictionary: inputDict)
            let output = try ffnModel.prediction(from: provider, using: ffnState)
            currentHidden = output.featureValue(for: "output_hidden_states")!.multiArrayValue!
        }
        
        return currentHidden
    }
    
    /// Run LM head with split logits support (logits1..logitsN → concat → argmax).
    private func runLMHead(hiddenStates: MLMultiArray) throws -> Int {
        let provider = try MLDictionaryFeatureProvider(dictionary: ["hidden_states": hiddenStates])
        let output = try lmHeadModel.prediction(from: provider)
        
        if let arr = output.featureValue(for: "argmax_ids")?.multiArrayValue {
            return Int(arr[0].int32Value)
        }
        if let arr = output.featureValue(for: "argmax_idx")?.multiArrayValue {
            return Int(arr[0].int32Value)
        }
        
        // Split logits: concatenate logits1..logitsN and find argmax
        if output.featureValue(for: "logits1") != nil {
            var maxVal: Float = -Float.infinity
            var maxIdx = 0
            var globalOffset = 0
            
            for i in 1...splitLmHead {
                guard let logitsArray = output.featureValue(for: "logits\(i)")?.multiArrayValue else {
                    break
                }
                
                let count = logitsArray.count
                let ptr = logitsArray.dataPointer.bindMemory(to: Float16.self, capacity: count)
                
                for j in 0..<count {
                    let val = Float(ptr[j])
                    if val > maxVal {
                        maxVal = val
                        maxIdx = globalOffset + j
                    }
                }
                
                globalOffset += count
            }
            
            return maxIdx
        }
        
        // Fallback: single logits output
        let logits = output.featureValue(for: "logits")?.multiArrayValue
            ?? output.featureValue(for: "output_logits")!.multiArrayValue!
        
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
    
    // MARK: - Reusable Buffer Fill (decode, no allocation)
    
    private func fillReusableInputIds(token: Int) -> MLMultiArray {
        let arr = reusableInputIds!
        arr[0] = NSNumber(value: Int32(token))
        return arr
    }
    
    private func fillReusablePositionIds(position: Int) -> MLMultiArray {
        let arr = reusablePositionIds!
        arr[0] = NSNumber(value: Int32(position))
        return arr
    }
    
    private func fillReusableCurrentPos(value: Int) -> MLMultiArray {
        let arr = reusableCurrentPos!
        arr[0] = NSNumber(value: Int32(value))
        return arr
    }
    
    private func fillReusableUpdateMask(position: Int) -> MLMultiArray {
        let arr = reusableUpdateMask!
        let ptr = arr.dataPointer.bindMemory(to: Float16.self, capacity: contextLength)
        // Zero all then set the one position
        memset(arr.dataPointer, 0, contextLength * MemoryLayout<Float16>.size)
        if position < contextLength {
            ptr[position] = Float16(1.0)
        }
        return arr
    }
    
    private func fillReusableCausalMask(position: Int) -> MLMultiArray {
        let arr = reusableCausalMask!
        let ptr = arr.dataPointer.bindMemory(to: Float16.self, capacity: contextLength)
        for j in 0..<contextLength {
            ptr[j] = (j <= position) ? Float16(0.0) : Self.maskedValue
        }
        return arr
    }
    
    // MARK: - MLMultiArray Construction (batch, for prefill — allocated each time)
    
    private func createBatchInputIds(tokens: [Int], padToSize: Int) throws -> MLMultiArray {
        let array = try MLMultiArray(shape: [1, NSNumber(value: padToSize)], dataType: .int32)
        let ptr = array.dataPointer.bindMemory(to: Int32.self, capacity: padToSize)
        for i in 0..<padToSize {
            ptr[i] = i < tokens.count ? Int32(tokens[i]) : 0
        }
        return array
    }
    
    private func createBatchPositionIds(start: Int, count: Int) throws -> MLMultiArray {
        let array = try MLMultiArray(shape: [NSNumber(value: count)], dataType: .int32)
        let ptr = array.dataPointer.bindMemory(to: Int32.self, capacity: count)
        for i in 0..<count {
            ptr[i] = Int32(start + i)
        }
        return array
    }
    
    private func createBatchCausalMask(start: Int, seqLen: Int) throws -> MLMultiArray {
        let totalElements = seqLen * contextLength
        let array = try MLMultiArray(
            shape: [1, 1, NSNumber(value: seqLen), NSNumber(value: contextLength)],
            dataType: .float16
        )
        let ptr = array.dataPointer.bindMemory(to: Float16.self, capacity: totalElements)
        for row in 0..<seqLen {
            let globalRow = start + row
            for col in 0..<contextLength {
                ptr[row * contextLength + col] = (col <= globalRow) ? Float16(0.0) : Self.maskedValue
            }
        }
        return array
    }
    
    private func createScalarInt32(value: Int) throws -> MLMultiArray {
        let array = try MLMultiArray(shape: [1], dataType: .int32)
        array[0] = NSNumber(value: Int32(value))
        return array
    }
}
