//
//  LlamaBridge.swift
//  HieuLuat
//
//  Swift wrapper around the llama.cpp Obj-C++ bridge.
//

import Foundation
import os.log

final class LlamaBridge {

    private static let logger = OSLog(subsystem: "com.hieuluat.app", category: "LlamaBridge")
    static let shared = LlamaBridge()
    private(set) var isModelLoaded = false

    private init() {}

    /// Load the GGUF model with runtime config from Remote Config.
    func loadModel(path: String, config: AIRuntimeConfig) {
        guard !isModelLoaded else { return }

        guard FileManager.default.fileExists(atPath: path) else {
            os_log(.error, log: Self.logger, "GGUF file not found at path: %{public}@", path)
            return
        }

        os_log(.info, log: Self.logger, "loading model at: %{public}@", path)
        llama_bridge_init_model(path,
                                Int32(config.gpuLayers),
                                Int32(config.contextLength),
                                Int32(config.batchSize),
                                Int32(config.threadCount))
        isModelLoaded = true
    }

    /// Run inference synchronously and return the generated text.
    func infer(prompt: String, maxNewTokens: Int, stopTokenIds: [Int]) -> String {
        os_log(.info, log: Self.logger, "infer() START - maxNewTokens=%d", maxNewTokens)
        guard isModelLoaded else {
            os_log(.error, log: Self.logger, "model not loaded")
            return ""
        }

        let stopTokens32 = stopTokenIds.map { Int32($0) }
        let cResult = stopTokens32.withUnsafeBufferPointer { (pointer: UnsafeBufferPointer<Int32>) -> UnsafePointer<CChar>? in
            return llama_bridge_run_inference(prompt, Int32(maxNewTokens), pointer.baseAddress, Int32(pointer.count))
        }
        
        guard let result = cResult else {
            os_log(.error, log: Self.logger, "cResult is nil")
            return ""
        }
        
        let resultStr = String(cString: result)
        os_log(.info, log: Self.logger, "infer() DONE - result length=%d", resultStr.count)
        return resultStr
    }

    /// Run inference on a background queue; completion called on main.
    func inferAsync(prompt: String, maxNewTokens: Int, stopTokenIds: [Int], completion: @escaping (String) -> Void) {
        os_log(.info, log: Self.logger, "inferAsync() START")
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let result = self?.infer(prompt: prompt, maxNewTokens: maxNewTokens, stopTokenIds: stopTokenIds) ?? ""
            os_log(.info, log: Self.logger, "inferAsync() done, result length=%d", result.count)
            DispatchQueue.main.async { completion(result) }
        }
    }

    func freeModel() {
        llama_bridge_free()
        isModelLoaded = false
    }
}
