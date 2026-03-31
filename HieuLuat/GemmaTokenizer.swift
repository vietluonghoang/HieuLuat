//
//  GemmaTokenizer.swift
//  HieuLuat
//
//  Created by AI Assistant on 3/30/26.
//  Copyright © 2026 VietLH. All rights reserved.
//

import Foundation

class GemmaTokenizer {
    
    // MARK: - Special Token IDs
    
    let padTokenId: Int = 0
    let eosTokenId: Int = 1
    let bosTokenId: Int = 2
    let unkTokenId: Int = 3
    private(set) var startOfTurnTokenId: Int = 105
    private(set) var endOfTurnTokenId: Int = 106
    
    // MARK: - Vocab & Merges
    
    private var vocabToId: [String: Int] = [:]
    private var idToVocab: [Int: String] = [:]
    private var merges: [(String, String)] = []
    private var mergeRanks: [String: Int] = [:]
    
    private var addedTokensToId: [String: Int] = [:]
    
    private static let sentencePieceSpace: Character = "\u{2581}" // ▁
    
    // MARK: - Init
    
    init(modelDirectory: URL) {
        let tokenizerURL = modelDirectory.appendingPathComponent("tokenizer.json")
        loadTokenizer(from: tokenizerURL)
    }
    
    // MARK: - Load Tokenizer
    
    private func loadTokenizer(from url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("GemmaTokenizer: tokenizer.json not found at \(url.path)")
            return
        }
        
        guard let data = try? Data(contentsOf: url) else {
            print("GemmaTokenizer: Failed to read tokenizer.json")
            return
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            print("GemmaTokenizer: Failed to parse tokenizer.json")
            return
        }
        
        // Parse added_tokens (special tokens with explicit IDs)
        if let addedTokens = json["added_tokens"] as? [[String: Any]] {
            for tokenObj in addedTokens {
                if let content = tokenObj["content"] as? String,
                   let id = tokenObj["id"] as? Int {
                    addedTokensToId[content] = id
                }
            }
        }
        
        // Look up start_of_turn and end_of_turn from added tokens
        if let id = addedTokensToId["<start_of_turn>"] {
            startOfTurnTokenId = id
        }
        if let id = addedTokensToId["<end_of_turn>"] {
            endOfTurnTokenId = id
        }
        
        // Parse model section
        guard let model = json["model"] as? [String: Any] else {
            print("GemmaTokenizer: Missing 'model' section")
            return
        }
        
        // Parse vocab: dict of token_string -> id
        if let vocab = model["vocab"] as? [String: Int] {
            vocabToId = vocab
            idToVocab.reserveCapacity(vocab.count)
            for (token, id) in vocab {
                idToVocab[id] = token
            }
        }
        
        // Also add added_tokens to vocab maps (they may overlap but that's fine)
        for (token, id) in addedTokensToId {
            vocabToId[token] = id
            idToVocab[id] = token
        }
        
        // Parse merges: array of [left, right] pairs
        if let mergesArray = model["merges"] as? [[String]] {
            merges.reserveCapacity(mergesArray.count)
            mergeRanks.reserveCapacity(mergesArray.count)
            for (index, pair) in mergesArray.enumerated() {
                guard pair.count == 2 else { continue }
                let left = pair[0]
                let right = pair[1]
                merges.append((left, right))
                let key = "\(left) \(right)"
                mergeRanks[key] = index
            }
        }
        
        print("GemmaTokenizer: Loaded \(vocabToId.count) vocab tokens, \(merges.count) merge rules")
    }
    
    // MARK: - Encode
    
    func encode(_ text: String) -> [Int] {
        guard !text.isEmpty else { return [] }
        
        let pieces = preTokenize(text)
        var ids: [Int] = []
        
        for piece in pieces {
            let tokenIds = bpeEncode(piece)
            ids.append(contentsOf: tokenIds)
        }
        
        return ids
    }
    
    // MARK: - Decode
    
    func decode(_ ids: [Int]) -> String {
        var tokens: [String] = []
        
        for id in ids {
            // Skip special tokens in decode output
            if id == bosTokenId || id == eosTokenId || id == padTokenId {
                continue
            }
            if id == startOfTurnTokenId || id == endOfTurnTokenId {
                continue
            }
            
            if let token = idToVocab[id] {
                // Handle byte fallback tokens like <0xAB>
                if token.hasPrefix("<0x") && token.hasSuffix(">") && token.count == 6 {
                    let hexStr = String(token.dropFirst(3).dropLast(1))
                    if let byte = UInt8(hexStr, radix: 16) {
                        tokens.append(String(bytes: [byte], encoding: .utf8) ?? "")
                    }
                } else {
                    tokens.append(token)
                }
            }
        }
        
        var result = tokens.joined()
        result = result.replacingOccurrences(of: String(GemmaTokenizer.sentencePieceSpace), with: " ")
        
        // Remove leading space that SentencePiece adds
        if result.hasPrefix(" ") {
            result = String(result.dropFirst())
        }
        
        return result
    }
    
    // MARK: - Chat Prompt
    
    func buildPrompt(userMessage: String) -> [Int] {
        // Template: <bos><start_of_turn>user\n{prompt}<end_of_turn>\n<start_of_turn>model\n
        var ids: [Int] = []
        
        // <bos>
        ids.append(bosTokenId)
        
        // <start_of_turn>
        ids.append(startOfTurnTokenId)
        
        // "user\n{prompt}"
        let userPart = "user\n" + userMessage
        ids.append(contentsOf: encode(userPart))
        
        // <end_of_turn>
        ids.append(endOfTurnTokenId)
        
        // "\n"
        ids.append(contentsOf: encode("\n"))
        
        // <start_of_turn>
        ids.append(startOfTurnTokenId)
        
        // "model\n"
        ids.append(contentsOf: encode("model\n"))
        
        return ids
    }
    
    // MARK: - Stop Token
    
    func isStopToken(_ id: Int) -> Bool {
        return id == eosTokenId || id == endOfTurnTokenId
    }
    
    // MARK: - Pre-tokenization
    
    /// Gemma normalizer: replace spaces with ▁, then pre-tokenizer splits on space
    /// with "MergedWithPrevious" behavior (space attaches to preceding token).
    private func preTokenize(_ text: String) -> [String] {
        // Step 1: Normalizer — replace " " with "▁"
        let normalized = text.replacingOccurrences(of: " ", with: String(GemmaTokenizer.sentencePieceSpace))
        
        // Step 2: Pre-tokenizer — Split on " " with MergedWithPrevious.
        // After normalization, there are no literal spaces left (they became ▁).
        // The HF pre-tokenizer splits on space *before* normalization in the pipeline,
        // but since the tokenizer.json specifies normalizer runs first, we just
        // add a leading ▁ to indicate start-of-text (SentencePiece convention)
        // and return the whole string as one piece.
        //
        // Actually, looking at the config: normalizer replaces " " -> "▁",
        // then pre_tokenizer splits on " " (literal space). Since all spaces
        // are already replaced, the split is effectively a no-op.
        // We add leading ▁ per SentencePiece convention.
        
        let withLeading = String(GemmaTokenizer.sentencePieceSpace) + normalized
        return [withLeading]
    }
    
    // MARK: - BPE Encoding
    
    private func bpeEncode(_ piece: String) -> [Int] {
        // Check if the whole piece is in vocab (added/special tokens)
        if let id = vocabToId[piece] {
            return [id]
        }
        
        // Split into individual characters as initial tokens
        var tokens = piece.map { String($0) }
        
        if tokens.isEmpty { return [] }
        if tokens.count == 1 {
            return tokenToIds(tokens[0])
        }
        
        // Iteratively apply BPE merges
        while tokens.count > 1 {
            // Find the pair with the lowest merge rank (highest priority)
            var bestRank = Int.max
            var bestIndex = -1
            
            for i in 0..<(tokens.count - 1) {
                let key = "\(tokens[i]) \(tokens[i + 1])"
                if let rank = mergeRanks[key], rank < bestRank {
                    bestRank = rank
                    bestIndex = i
                }
            }
            
            // No more merges possible
            if bestIndex == -1 {
                break
            }
            
            // Apply the merge
            let merged = tokens[bestIndex] + tokens[bestIndex + 1]
            tokens[bestIndex] = merged
            tokens.remove(at: bestIndex + 1)
        }
        
        // Convert tokens to IDs
        var ids: [Int] = []
        for token in tokens {
            ids.append(contentsOf: tokenToIds(token))
        }
        return ids
    }
    
    /// Convert a single BPE token string to one or more IDs.
    /// Falls back to byte-level encoding if the token isn't in vocab.
    private func tokenToIds(_ token: String) -> [Int] {
        if let id = vocabToId[token] {
            return [id]
        }
        
        // Byte fallback: encode each byte as <0xXX>
        let bytes = Array(token.utf8)
        var ids: [Int] = []
        for byte in bytes {
            let byteToken = String(format: "<0x%02X>", byte)
            if let id = vocabToId[byteToken] {
                ids.append(id)
            } else {
                ids.append(unkTokenId)
            }
        }
        return ids
    }
}
