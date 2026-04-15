//
//  AITokenizer.swift
//  HieuLuat
//
//  Created by AI Assistant on 4/1/26.
//  Copyright © 2026 VietLH. All rights reserved.
//

import Foundation

/// Abstract tokenizer interface shared by all model types.
protocol AITokenizer: AnyObject {
    var eosTokenId: Int { get }
    var stopTokenIds: Set<Int> { get }
    
    func encode(_ text: String) -> [Int]
    func decode(_ ids: [Int]) -> String
    func buildPrompt(userMessage: String) -> [Int]
    func isStopToken(_ id: Int) -> Bool
}

/// Factory that creates the correct tokenizer for a given model type.
enum AITokenizerFactory {
    static func create(for config: AIModelConfig, modelDirectory: URL) -> AITokenizer {
        switch config.modelType {
        case .qwen:
            return QwenTokenizer(modelDirectory: modelDirectory)
        case .gemma:
            return GemmaTokenizer(modelDirectory: modelDirectory)
        case .llama:
            return LlamaTokenizer()
        }
    }
}

class LlamaTokenizer: AITokenizer {
    var eosTokenId: Int = 2
    var stopTokenIds: Set<Int> = [2]
    
    func encode(_ text: String) -> [Int] {
        return Array(text.utf8).map { Int($0) }
    }
    
    func decode(_ ids: [Int]) -> String {
        let bytes = ids.compactMap { UInt8(exactly: $0) }
        return String(bytes: bytes, encoding: .utf8) ?? ""
    }
    
    func buildPrompt(userMessage: String) -> [Int] {
        // Gemma-4 has built-in Jinja2 chat_template in model file.
        // llama.cpp automatically applies it during tokenization.
        // Just return the user message; llama_tokenize() handles formatting.
        return encode(userMessage)
    }
    
    func isStopToken(_ id: Int) -> Bool {
        return stopTokenIds.contains(id)
    }
}
