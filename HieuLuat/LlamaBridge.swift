//
//  LlamaBridge.swift
//  HieuLuat
//
//  Swift wrapper around the llama.cpp Obj-C++ bridge.
//

import Foundation

final class LlamaBridge {

    static let shared = LlamaBridge()
    private(set) var isModelLoaded = false

    private init() {}

    /// Load the GGUF model from the given absolute path. Safe to call multiple times.
    func loadModel(path: String) {
        guard !isModelLoaded else { return }

        // Ensure the file exists
        guard FileManager.default.fileExists(atPath: path) else {
            NSLog("[LlamaBridge] ERROR: GGUF file not found at path: %@", path)
            return
        }

        NSLog("[LlamaBridge] loading model at: %@", path)
        llama_bridge_init_model(path)
        isModelLoaded = true
    }

    /// Run inference synchronously and return the generated text.
    func infer(prompt: String, maxNewTokens: Int, stopTokenIds: [Int]) -> String {
        guard isModelLoaded else {
            NSLog("[LlamaBridge] ERROR: model not loaded")
            return ""
        }

        let stopTokens32 = stopTokenIds.map { Int32($0) }
        let cResult = stopTokens32.withUnsafeBufferPointer { (pointer: UnsafeBufferPointer<Int32>) -> UnsafePointer<CChar>? in
            return llama_bridge_run_inference(prompt, Int32(maxNewTokens), pointer.baseAddress, Int32(pointer.count))
        }
        
        guard let result = cResult else {
            return ""
        }
        return String(cString: result)
    }

    /// Run inference on a background queue; completion called on main.
    func inferAsync(prompt: String, maxNewTokens: Int, stopTokenIds: [Int], completion: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let result = self?.infer(prompt: prompt, maxNewTokens: maxNewTokens, stopTokenIds: stopTokenIds) ?? ""
            DispatchQueue.main.async { completion(result) }
        }
    }

    func freeModel() {
        llama_bridge_free()
        isModelLoaded = false
    }
}
