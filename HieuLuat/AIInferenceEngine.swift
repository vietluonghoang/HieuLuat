//
//  AIInferenceEngine.swift
//  HieuLuat
//
//  Created by AI Assistant on 4/1/26.
//  Copyright © 2026 VietLH. All rights reserved.
//

import CoreML
import Foundation

/// Abstract inference engine interface shared by all model types.
protocol AIInferenceEngine: AnyObject {
    var isCancelled: Bool { get set }
    
    func runGenerate(inputTokens: [Int], maxNewTokens: Int,
                     stopTokenIds: Set<Int>, completion: @escaping ([Int]) -> Void)
    
    // Support direct string prompt for Llama bypass
    func runGenerate(prompt: String, maxNewTokens: Int,
                     stopTokenIds: Set<Int>, completion: @escaping ([Int]) -> Void)
                     
    func resetState()
}

enum AIModelBackend {
    case coreML
    case llama
}

/// Factory that creates the correct inference engine for a given model type.
@available(iOS 18.0, *)
enum AIInferenceEngineFactory {
    static func create(for config: AIModelConfig,
                       backend: AIModelBackend,
                       tokenizer: Any? = nil,
                       embedModel: MLModel? = nil,
                       ffnModels: [MLModel]? = nil,
                       lmHeadModel: MLModel? = nil,
                       ffnURLs: [URL]? = nil) -> AIInferenceEngine {
        
        if backend == .llama {
            guard let tokenizer = tokenizer as? AITokenizer else {
                fatalError("AITokenizer required for Llama backend")
            }
            return LlamaInferenceEngine(tokenizer: tokenizer, config: config)
        }
        
        // Ensure required CoreML models are present
        guard let embedModel = embedModel,
              let ffnModels = ffnModels,
              let lmHeadModel = lmHeadModel else {
            fatalError("CoreML models required for CoreML backend")
        }

        switch config.modelType {
        case .qwen:
            if let urls = ffnURLs {
                // Multi-function Qwen: load prefill/infer on demand from URLs
                return QwenInferenceEngine(
                    embedModel: embedModel,
                    ffnURLs: urls,
                    lmHeadModel: lmHeadModel,
                    contextLength: config.contextLength,
                    batchSize: config.batchSize,
                    splitLmHead: config.splitLmHead
                )
            } else {
                // Fallback: single-function, use Gemma engine
                return GemmaInferenceEngine(
                    embedModel: embedModel,
                    ffnModels: ffnModels,
                    lmHeadModel: lmHeadModel,
                    contextLength: config.contextLength,
                    slidingWindow: min(1024, config.contextLength)
                )
            }
        case .gemma:
            return GemmaInferenceEngine(
                embedModel: embedModel,
                ffnModels: ffnModels,
                lmHeadModel: lmHeadModel,
                contextLength: config.contextLength,
                slidingWindow: min(1024, config.contextLength)
            )
        case .llama:
            // Fallback for non-GGUF Llama
            return GemmaInferenceEngine(
                embedModel: embedModel,
                ffnModels: ffnModels,
                lmHeadModel: lmHeadModel,
                contextLength: config.contextLength,
                slidingWindow: min(1024, config.contextLength)
            )
        }
    }
}
