//
//  LlamaInferenceEngine.swift
//  HieuLuat
//
//  Created by AI Assistant on 4/10/26.
//  Copyright © 2026 VietLH. All rights reserved.
//

import Foundation

/// Llama-based inference engine, bridging to C++ llama.cpp.
final class LlamaInferenceEngine: AIInferenceEngine {
    
    var isCancelled: Bool = false
    private let bridge = LlamaBridge.shared
    private let tokenizer: AITokenizer
    private let config: AIModelConfig
    
    init(tokenizer: AITokenizer, config: AIModelConfig) {
        self.tokenizer = tokenizer
        self.config = config
        NSLog("LlamaInferenceEngine: Initialized with config: contextLength=%d", config.contextLength)
    }
    
    func runGenerate(inputTokens: [Int], maxNewTokens: Int,
                     stopTokenIds: Set<Int>, completion: @escaping ([Int]) -> Void) {
        // Dummy implementation for protocol compliance, llama backend should use runGenerate(prompt: String, ...)
        runGenerate(prompt: "", maxNewTokens: maxNewTokens, stopTokenIds: stopTokenIds, completion: completion)
    }
    
    func runGenerate(prompt: String, maxNewTokens: Int,
                     stopTokenIds: Set<Int>, completion: @escaping ([Int]) -> Void) {
        
        NSLog("LlamaInferenceEngine: Prompt: %@", prompt)
        
        bridge.inferAsync(prompt: prompt, maxNewTokens: maxNewTokens, stopTokenIds: Array(stopTokenIds)) { [weak self] resultString in
            guard let self = self else { return }
            let resultTokens = self.tokenizer.encode(resultString)
            completion(resultTokens)
        }
    }
    
    func resetState() {
        // LlamaBridge handles its own memory/KV cache clearing in run_inference
        NSLog("LlamaInferenceEngine: State reset")
    }
}
