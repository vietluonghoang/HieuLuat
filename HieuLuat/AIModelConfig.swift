//
//  AIModelConfig.swift
//  HieuLuat
//
//  Created by AI Assistant on 4/1/26.
//  Copyright © 2026 VietLH. All rights reserved.
//

import Foundation

/// Parsed from `meta.yaml` inside the model bundle.
/// Drives model loading, tokenizer creation, and inference engine selection dynamically.
struct AIModelConfig {
    
    enum ModelType: String {
        case gemma
        case qwen
        case llama
        
        init(prefix: String) {
            switch prefix.lowercased() {
            case let p where p.starts(with: "gemma"): self = .gemma
            case let p where p.starts(with: "qwen"):  self = .qwen
            case let p where p.starts(with: "llama"): self = .llama
            default: self = .llama
            }
        }
    }
    
    let modelPrefix: String
    let modelType: ModelType
    let contextLength: Int
    let batchSize: Int
    let splitLmHead: Int
    let numChunks: Int
    let lutFFN: String
    let lutLmHead: String
    let lutEmbeddings: String
    
    // Explicit file names from meta.yaml (if provided)
    let embeddingsFileName: String
    let lmHeadFileName: String
    let ffnBaseFileName: String
    
    /// All model file names that must exist on disk.
    var allModelFileNames: [String] {
        var names: [String] = [embeddingsFileName]
        names.append(contentsOf: ffnChunkFileNames)
        names.append(lmHeadFileName)
        return names
    }
    
    /// FFN chunk file names derived from the base FFN name and numChunks.
    var ffnChunkFileNames: [String] {
        guard numChunks > 1 else {
            // Single FFN — base name is the file itself
            return [ffnBaseFileName]
        }
        
        // Pattern: {prefix}_FFN_PF{lut}_chunk_01of02.mlmodelc
        // We derive the chunk names from the base pattern.
        let base = (ffnBaseFileName as NSString).deletingPathExtension
        let ext = (ffnBaseFileName as NSString).pathExtension
        
        // Remove existing chunk suffix if present (e.g., _chunk_01of02)
        let pattern = "_chunk_\\d+of\\d+"
        let cleaned = base.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        
        return (1...numChunks).map { chunk in
            let chunkStr = String(format: "%02d", chunk)
            let totalStr = String(format: "%02d", numChunks)
            return "\(cleaned)_chunk_\(chunkStr)of\(totalStr).\(ext)"
        }
    }
    
    // MARK: - Load from meta.yaml
    
    static func load(from url: URL) -> AIModelConfig? {
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let content = String(data: data, encoding: .utf8) else {
            print("AIModelConfig: Cannot read meta.yaml at \(url.path)")
            return nil
        }
        
        return parse(yaml: content)
    }
    
    /// Lightweight YAML parser for meta.yaml (avoids third-party dependency).
    private static func parse(yaml content: String) -> AIModelConfig? {
        // Extract values from the parameters section
        let lines = content.components(separatedBy: .newlines)
        var params: [String: String] = [:]
        var inParameters = false
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed == "parameters:" {
                inParameters = true
                continue
            }
            if inParameters {
                // Stop if we hit a non-indented line (new top-level key)
                if !line.hasPrefix(" ") && !line.hasPrefix("\t") && !trimmed.isEmpty {
                    break
                }
                let parts = trimmed.split(separator: ":", maxSplits: 1)
                if parts.count == 2 {
                    let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
                    let value = String(parts[1]).trimmingCharacters(in: .whitespaces)
                    params[key] = value
                }
            }
        }
        
        guard !params.isEmpty else {
            print("AIModelConfig: No parameters found in meta.yaml")
            return nil
        }
        
        let prefix = params["model_prefix"] ?? "llama"
        let contextLength = Int(params["context_length"] ?? "") ?? 512
        let batchSize = Int(params["batch_size"] ?? "") ?? 64
        let splitLmHead = Int(params["split_lm_head"] ?? "") ?? 8
        let numChunks = Int(params["num_chunks"] ?? "") ?? 1
        let lutFFN = params["lut_ffn"] ?? "none"
        let lutLmHead = params["lut_lmhead"] ?? "none"
        let lutEmbeddings = params["lut_embeddings"] ?? "none"
        
        // Use explicit file names from meta.yaml if provided, otherwise construct them
        let embeddingsFileName = params["embeddings"]
            ?? "\(prefix)_embeddings\(lutEmbeddings != "none" ? "_lut\(lutEmbeddings)" : "").mlmodelc"
        let lmHeadFileName = params["lm_head"]
            ?? "\(prefix)_lm_head\(lutLmHead != "none" ? "_lut\(lutLmHead)" : "").mlmodelc"
        let ffnBaseFileName = params["ffn"]
            ?? "\(prefix)_FFN_PF\(lutFFN != "none" ? "_lut\(lutFFN)" : "").mlmodelc"
        
        let config = AIModelConfig(
            modelPrefix: prefix,
            modelType: ModelType(prefix: prefix),
            contextLength: contextLength,
            batchSize: batchSize,
            splitLmHead: splitLmHead,
            numChunks: numChunks,
            lutFFN: lutFFN,
            lutLmHead: lutLmHead,
            lutEmbeddings: lutEmbeddings,
            embeddingsFileName: embeddingsFileName,
            lmHeadFileName: lmHeadFileName,
            ffnBaseFileName: ffnBaseFileName
        )
        
        print("AIModelConfig: Loaded — type=\(config.modelType), prefix=\(prefix), ctx=\(contextLength), chunks=\(numChunks), splitLmHead=\(splitLmHead)")
        print("AIModelConfig: Files = \(config.allModelFileNames)")
        
        return config
    }
}
