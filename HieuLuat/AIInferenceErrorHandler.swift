//
//  AIInferenceErrorHandler.swift
//  HieuLuat
//
//  Created by AI Assistant on 4/22/26.
//  Copyright © 2026 VietLH. All rights reserved.
//

import Foundation

// MARK: - AI Inference Errors

enum AIInferenceError: Error, LocalizedError {
    case modelNotFound
    case tokenizerNotInitialized
    case inferenceTimeout
    case memoryInsufficient
    case gpuError(String)
    case invalidInput
    case cancelled
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .modelNotFound:
            return "AI model not found or not loaded"
        case .tokenizerNotInitialized:
            return "Tokenizer is not initialized"
        case .inferenceTimeout:
            return "Inference took too long and was cancelled"
        case .memoryInsufficient:
            return "Insufficient memory for inference"
        case .gpuError(let details):
            return "GPU error: \(details)"
        case .invalidInput:
            return "Invalid input for inference"
        case .cancelled:
            return "Inference was cancelled by user"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .modelNotFound:
            return "Please ensure the AI model is downloaded and properly loaded."
        case .tokenizerNotInitialized:
            return "Please restart the application and try again."
        case .inferenceTimeout:
            return "Try with a shorter input or reduce max_new_tokens."
        case .memoryInsufficient:
            return "Close other apps and try again."
        case .gpuError:
            return "Please try again or disable GPU acceleration in settings."
        case .invalidInput:
            return "Please check your input and try again."
        case .cancelled:
            return "You can retry the inference whenever you're ready."
        case .unknown:
            return "Please try again later."
        }
    }
}

// MARK: - AI Inference Wrapper

/// Wrapper for AI inference with proper error handling and state management
class AIInferenceWrapper {
    
    private weak var engine: AIInferenceEngine?
    private let timeout: TimeInterval
    private var inferenceTask: DispatchWorkItem?
    
    init(engine: AIInferenceEngine, timeout: TimeInterval = 300) {
        self.engine = engine
        self.timeout = timeout
    }
    
    // MARK: - Safe Inference Methods
    
    /// Run inference with error handling
    func runGenerate(
        prompt: String,
        maxNewTokens: Int,
        stopTokenIds: Set<Int>,
        completion: @escaping (Result<[Int], AIInferenceError>) -> Void
    ) {
        guard let engine = engine else {
            Logger.error("Engine is nil", category: .inference)
            completion(.failure(.modelNotFound))
            return
        }
        
        // Validate input
        guard !prompt.isEmpty else {
            Logger.warning("Empty prompt provided", category: .inference)
            completion(.failure(.invalidInput))
            return
        }
        
        Logger.info("Starting inference (maxTokens: \(maxNewTokens))", category: .inference)
        
        // Create timeout work item
        let timeoutWorkItem = DispatchWorkItem { [weak self] in
            Logger.warning("Inference timeout after \(self?.timeout ?? 0)s", category: .inference)
            self?.cancel()
            completion(.failure(.inferenceTimeout))
        }
        
        self.inferenceTask = timeoutWorkItem
        
        // Schedule timeout
        DispatchQueue.global(qos: .userInitiated).asyncAfter(
            deadline: .now() + timeout,
            execute: timeoutWorkItem
        )
        
        // Run actual inference
        do {
            try runInferenceWithErrorHandling(
                engine: engine,
                prompt: prompt,
                maxNewTokens: maxNewTokens,
                stopTokenIds: stopTokenIds
            ) { [weak self] result in
                // Cancel timeout if still pending
                timeoutWorkItem.cancel()
                self?.inferenceTask = nil
                completion(result)
            }
        } catch {
            timeoutWorkItem.cancel()
            self.inferenceTask = nil
            Logger.error("Inference setup failed", error: error, category: .inference)
            completion(.failure(.unknown(error.localizedDescription)))
        }
    }
    
    /// Run inference on tokens with error handling
    func runGenerate(
        tokens: [Int],
        maxNewTokens: Int,
        stopTokenIds: Set<Int>,
        completion: @escaping (Result<[Int], AIInferenceError>) -> Void
    ) {
        guard let engine = engine else {
            Logger.error("Engine is nil", category: .inference)
            completion(.failure(.modelNotFound))
            return
        }
        
        guard !tokens.isEmpty else {
            Logger.warning("Empty token array provided", category: .inference)
            completion(.failure(.invalidInput))
            return
        }
        
        Logger.info("Starting token-based inference (\(tokens.count) tokens)", category: .inference)
        
        let timeoutWorkItem = DispatchWorkItem { [weak self] in
            Logger.warning("Token inference timeout", category: .inference)
            self?.cancel()
            completion(.failure(.inferenceTimeout))
        }
        
        self.inferenceTask = timeoutWorkItem
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(
            deadline: .now() + timeout,
            execute: timeoutWorkItem
        )
        
        do {
            try runTokenInferenceWithErrorHandling(
                engine: engine,
                tokens: tokens,
                maxNewTokens: maxNewTokens,
                stopTokenIds: stopTokenIds
            ) { [weak self] result in
                timeoutWorkItem.cancel()
                self?.inferenceTask = nil
                completion(result)
            }
        } catch {
            timeoutWorkItem.cancel()
            self.inferenceTask = nil
            Logger.error("Token inference setup failed", error: error, category: .inference)
            completion(.failure(.unknown(error.localizedDescription)))
        }
    }
    
    // MARK: - Private Helpers
    
    private func runInferenceWithErrorHandling(
        engine: AIInferenceEngine,
        prompt: String,
        maxNewTokens: Int,
        stopTokenIds: Set<Int>,
        completion: @escaping (Result<[Int], AIInferenceError>) -> Void
    ) throws {
        engine.runGenerate(prompt: prompt, maxNewTokens: maxNewTokens, stopTokenIds: stopTokenIds) { [weak self] tokens in
            if self?.inferenceTask?.isCancelled == true {
                Logger.debug("Inference cancelled", category: .inference)
                completion(.failure(.cancelled))
                return
            }
            
            Logger.info("Inference completed with \(tokens.count) tokens", category: .inference)
            completion(.success(tokens))
        }
    }
    
    private func runTokenInferenceWithErrorHandling(
        engine: AIInferenceEngine,
        tokens: [Int],
        maxNewTokens: Int,
        stopTokenIds: Set<Int>,
        completion: @escaping (Result<[Int], AIInferenceError>) -> Void
    ) throws {
        engine.runGenerate(inputTokens: tokens, maxNewTokens: maxNewTokens, stopTokenIds: stopTokenIds) { [weak self] resultTokens in
            if self?.inferenceTask?.isCancelled == true {
                Logger.debug("Token inference cancelled", category: .inference)
                completion(.failure(.cancelled))
                return
            }
            
            Logger.info("Token inference completed with \(resultTokens.count) tokens", category: .inference)
            completion(.success(resultTokens))
        }
    }
    
    // MARK: - Cancellation
    
    /// Cancel ongoing inference
    func cancel() {
        engine?.isCancelled = true
        inferenceTask?.cancel()
        Logger.debug("Inference cancellation requested", category: .inference)
    }
    
    /// Reset engine state
    func reset() {
        engine?.resetState()
        inferenceTask = nil
        Logger.debug("Engine state reset", category: .inference)
    }
}

// MARK: - Synchronous Safe Wrapper

/// Safe wrapper for synchronous inference operations
class SyncAIInferenceWrapper {
    
    private let engine: AIInferenceEngine
    private let timeout: TimeInterval
    
    init(engine: AIInferenceEngine, timeout: TimeInterval = 300) {
        self.engine = engine
        self.timeout = timeout
    }
    
    /// Execute inference synchronously with timeout
    func execute(
        prompt: String,
        maxNewTokens: Int,
        stopTokenIds: Set<Int>
    ) -> Result<[Int], AIInferenceError> {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<[Int], AIInferenceError> = .failure(.unknown("Unknown error"))
        
        Logger.info("Starting synchronous inference", category: .inference)
        
        let wrapper = AIInferenceWrapper(engine: engine, timeout: timeout)
        wrapper.runGenerate(
            prompt: prompt,
            maxNewTokens: maxNewTokens,
            stopTokenIds: stopTokenIds
        ) { inferenceResult in
            result = inferenceResult
            semaphore.signal()
        }
        
        let waitResult = semaphore.wait(timeout: .now() + timeout)
        
        if waitResult == .timedOut {
            wrapper.cancel()
            Logger.error("Synchronous inference timed out", category: .inference)
            return .failure(.inferenceTimeout)
        }
        
        return result
    }
}
