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
    func resetState()
}

/// Factory that creates the correct inference engine for a given model type.
@available(iOS 18.0, *)
enum AIInferenceEngineFactory {
    static func create(for config: AIModelConfig,
                       embedModel: MLModel,
                       ffnModels: [MLModel],
                       lmHeadModel: MLModel,
                       ffnURLs: [URL]? = nil) -> AIInferenceEngine {
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
