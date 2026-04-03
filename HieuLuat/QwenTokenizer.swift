//
//  QwenTokenizer.swift
//  HieuLuat
//
//  Created by AI Assistant on 4/1/26.
//  Copyright © 2026 VietLH. All rights reserved.
//

import Foundation

/// Tokenizer for Qwen3 models.
/// Uses tiktoken-style byte-level BPE with vocab.json + merges from tokenizer.json.
/// Chat template follows ChatML: `<|im_start|>role\ncontent<|im_end|>`.
class QwenTokenizer: AITokenizer {
    
    // MARK: - Special Token IDs (from tokenizer_config.json)
    
    private(set) var endOfTextTokenId: Int = 151643   // <|endoftext|> (pad)
    private(set) var imStartTokenId: Int = 151644     // <|im_start|>
    private(set) var imEndTokenId: Int = 151645       // <|im_end|>
    private(set) var thinkStartTokenId: Int = 151667  // <think>
    private(set) var thinkEndTokenId: Int = 151668    // </think>
    
    var eosTokenId: Int { return imEndTokenId }
    
    var stopTokenIds: Set<Int> {
        return [imEndTokenId, endOfTextTokenId]
    }
    
    // MARK: - Vocab & Merges
    
    private var vocabToId: [String: Int] = [:]
    private var idToVocab: [Int: String] = [:]
    private var mergeRanks: [String: Int] = [:]
    
    // Byte-level base vocab: maps each byte (0-255) to a unicode character
    private var byteEncoder: [UInt8: Character] = [:]
    private var byteDecoder: [Character: UInt8] = [:]
    
    // Added tokens (special tokens with exact string match)
    private var addedTokensToId: [String: Int] = [:]
    private var addedTokenPatterns: [(String, Int)] = [] // sorted longest-first for greedy match
    
    // Pre-tokenization regex (from tokenizer.json)
    private var preTokenizeRegex: NSRegularExpression?
    
    // MARK: - Init
    
    init(modelDirectory: URL) {
        buildByteEncoder()
        
        let tokenizerURL = modelDirectory.appendingPathComponent("tokenizer.json")
        loadTokenizer(from: tokenizerURL)
        
        let configURL = modelDirectory.appendingPathComponent("tokenizer_config.json")
        loadConfig(from: configURL)
    }
    
    // MARK: - Byte Encoder (tiktoken-style)
    
    /// Build the byte↔unicode mapping used by GPT-2 / tiktoken BPE.
    /// This maps bytes 0-255 to printable unicode characters to avoid control chars.
    private func buildByteEncoder() {
        var bs: [Int] = []
        var cs: [Int] = []
        
        // Printable byte ranges (GPT-2 byte encoder)
        // Range 1: 0x21 '!' to 0x7E '~'
        for b in 0x21...0x7E { bs.append(b); cs.append(b) }
        // Range 2: 0xA1 '¡' to 0xAC '¬'
        for b in 0xA1...0xAC { bs.append(b); cs.append(b) }
        // Range 3: 0xAE '®' to 0xFF 'ÿ'
        for b in 0xAE...0xFF { bs.append(b); cs.append(b) }
        
        // Map remaining bytes to characters starting at 256
        var n = 256
        for b in 0..<256 {
            if !bs.contains(b) {
                bs.append(b)
                cs.append(n)
                n += 1
            }
        }
        
        for (b, c) in zip(bs, cs) {
            let char = Character(Unicode.Scalar(c)!)
            byteEncoder[UInt8(b)] = char
            byteDecoder[char] = UInt8(b)
        }
    }
    
    // MARK: - Load Tokenizer
    
    private func loadTokenizer(from url: URL) {
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            print("QwenTokenizer: Failed to load tokenizer.json")
            return
        }
        
        // Parse added_tokens
        if let addedTokens = json["added_tokens"] as? [[String: Any]] {
            for tokenObj in addedTokens {
                if let content = tokenObj["content"] as? String,
                   let id = tokenObj["id"] as? Int {
                    addedTokensToId[content] = id
                    vocabToId[content] = id
                    idToVocab[id] = content
                }
            }
            // Sort longest-first for greedy matching
            addedTokenPatterns = addedTokensToId.sorted { $0.key.count > $1.key.count }
        }
        
        // Update special token IDs from added_tokens
        if let id = addedTokensToId["<|endoftext|>"] { endOfTextTokenId = id }
        if let id = addedTokensToId["<|im_start|>"] { imStartTokenId = id }
        if let id = addedTokensToId["<|im_end|>"] { imEndTokenId = id }
        if let id = addedTokensToId["<think>"] { thinkStartTokenId = id }
        if let id = addedTokensToId["</think>"] { thinkEndTokenId = id }
        
        // Parse model section
        guard let model = json["model"] as? [String: Any] else {
            print("QwenTokenizer: Missing 'model' section")
            return
        }
        
        // Parse vocab
        if let vocab = model["vocab"] as? [String: Int] {
            for (token, id) in vocab {
                vocabToId[token] = id
                idToVocab[id] = token
            }
        }
        
        // Parse merges — supports both ["a b", ...] and [["a","b"], ...] formats
        if let mergesArray = model["merges"] as? [[String]] {
            // Format: [["a","b"], ["c","d"], ...]
            for (index, pair) in mergesArray.enumerated() {
                guard pair.count == 2 else { continue }
                mergeRanks["\(pair[0]) \(pair[1])"] = index
            }
        } else if let mergesArray = model["merges"] as? [String] {
            // Format: ["a b", "c d", ...]
            for (index, mergeStr) in mergesArray.enumerated() {
                mergeRanks[mergeStr] = index
            }
        }
        
        // Parse pre-tokenizer regex
        if let preTokenizer = json["pre_tokenizer"] as? [String: Any] {
            loadPreTokenizerRegex(from: preTokenizer)
        }
        
        print("QwenTokenizer: Loaded \(vocabToId.count) vocab tokens, \(mergeRanks.count) merge rules")
    }
    
    private func loadPreTokenizerRegex(from preTokenizer: [String: Any]) {
        // The Qwen tokenizer uses a Sequence of Split pre-tokenizers
        // We extract the first regex pattern
        if let pretokenizers = preTokenizer["pretokenizers"] as? [[String: Any]] {
            for pt in pretokenizers {
                if let pattern = pt["pattern"] as? [String: String],
                   let regex = pattern["Regex"] {
                    preTokenizeRegex = try? NSRegularExpression(pattern: regex, options: [])
                    if preTokenizeRegex != nil {
                        return
                    }
                }
            }
        }
        // Direct pattern
        if let pattern = preTokenizer["pattern"] as? [String: String],
           let regex = pattern["Regex"] {
            preTokenizeRegex = try? NSRegularExpression(pattern: regex, options: [])
        }
    }
    
    private func loadConfig(from url: URL) {
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return
        }
        
        // Read eos_token
        if let eosToken = json["eos_token"] as? String,
           let id = addedTokensToId[eosToken] {
            // imEndTokenId already set
            print("QwenTokenizer: EOS token = '\(eosToken)' (ID: \(id))")
        }
    }
    
    // MARK: - AITokenizer Protocol
    
    func encode(_ text: String) -> [Int] {
        guard !text.isEmpty else { return [] }
        
        // First, extract added/special tokens, then BPE-encode the rest
        let segments = splitOnAddedTokens(text)
        var ids: [Int] = []
        
        for segment in segments {
            if let specialId = addedTokensToId[segment] {
                ids.append(specialId)
            } else {
                let pieces = preTokenize(segment)
                for piece in pieces {
                    ids.append(contentsOf: bpeEncode(piece))
                }
            }
        }
        
        return ids
    }
    
    func decode(_ ids: [Int]) -> String {
        var byteArray: [UInt8] = []
        
        for id in ids {
            // Skip special/control tokens
            if addedTokensToId.values.contains(id) {
                // Flush any pending bytes
                if !byteArray.isEmpty {
                    // handled below
                }
                // For think tags, we might want to include them
                if id == thinkStartTokenId || id == thinkEndTokenId {
                    if !byteArray.isEmpty {
                        if let str = String(bytes: byteArray, encoding: .utf8) {
                            // will be appended after flush
                        }
                    }
                }
                continue
            }
            
            guard let token = idToVocab[id] else { continue }
            
            // Convert token chars back to bytes via byteDecoder
            for char in token {
                if let byte = byteDecoder[char] {
                    byteArray.append(byte)
                }
            }
        }
        
        return String(bytes: byteArray, encoding: .utf8) ?? ""
    }
    
    func buildPrompt(userMessage: String) -> [Int] {
        // ChatML template:
        // <|im_start|>user\n{message}<|im_end|>\n<|im_start|>assistant\n
        var ids: [Int] = []
        
        // <|im_start|>user\n{message}<|im_end|>\n
        ids.append(imStartTokenId)
        ids.append(contentsOf: encode("user\n" + userMessage))
        ids.append(imEndTokenId)
        ids.append(contentsOf: encode("\n"))
        
        // <|im_start|>assistant\n
        ids.append(imStartTokenId)
        ids.append(contentsOf: encode("assistant\n"))
        
        return ids
    }
    
    func isStopToken(_ id: Int) -> Bool {
        return stopTokenIds.contains(id)
    }
    
    // MARK: - Pre-tokenization
    
    /// Split text into pre-tokenized pieces using the regex pattern from tokenizer.json.
    private func preTokenize(_ text: String) -> [String] {
        guard let regex = preTokenizeRegex else {
            return [text]
        }
        
        let nsText = text as NSString
        let range = NSRange(location: 0, length: nsText.length)
        let matches = regex.matches(in: text, options: [], range: range)
        
        if matches.isEmpty {
            return [text]
        }
        
        return matches.map { nsText.substring(with: $0.range) }
    }
    
    /// Split text so that added/special tokens are separate segments.
    private func splitOnAddedTokens(_ text: String) -> [String] {
        var result: [String] = []
        var remaining = text
        
        while !remaining.isEmpty {
            var foundMatch = false
            for (token, _) in addedTokenPatterns {
                if let range = remaining.range(of: token) {
                    // Add text before the token
                    let before = String(remaining[remaining.startIndex..<range.lowerBound])
                    if !before.isEmpty {
                        result.append(before)
                    }
                    // Add the token itself
                    result.append(token)
                    remaining = String(remaining[range.upperBound...])
                    foundMatch = true
                    break
                }
            }
            if !foundMatch {
                result.append(remaining)
                break
            }
        }
        
        return result
    }
    
    // MARK: - BPE Encoding
    
    private func bpeEncode(_ piece: String) -> [Int] {
        // Convert text to byte-level token string
        let bytes = Array(piece.utf8)
        var tokens = bytes.map { String(byteEncoder[$0]!) }
        
        if tokens.isEmpty { return [] }
        if tokens.count == 1 {
            if let id = vocabToId[tokens[0]] {
                return [id]
            }
            return []
        }
        
        // Iteratively apply BPE merges
        while tokens.count > 1 {
            var bestRank = Int.max
            var bestIndex = -1
            
            for i in 0..<(tokens.count - 1) {
                let pair = "\(tokens[i]) \(tokens[i + 1])"
                if let rank = mergeRanks[pair], rank < bestRank {
                    bestRank = rank
                    bestIndex = i
                }
            }
            
            if bestIndex == -1 { break }
            
            let merged = tokens[bestIndex] + tokens[bestIndex + 1]
            tokens[bestIndex] = merged
            tokens.remove(at: bestIndex + 1)
        }
        
        // Convert to IDs
        var ids: [Int] = []
        for token in tokens {
            if let id = vocabToId[token] {
                ids.append(id)
            }
        }
        return ids
    }
}
