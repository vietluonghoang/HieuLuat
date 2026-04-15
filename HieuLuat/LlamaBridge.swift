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
        NSLog("[LlamaBridge] infer() START - prompt=\(prompt.prefix(50))... maxNewTokens=\(maxNewTokens)")
        guard isModelLoaded else {
            NSLog("[LlamaBridge] ERROR: model not loaded")
            return ""
        }

        let stopTokens32 = stopTokenIds.map { Int32($0) }
        let cResult = stopTokens32.withUnsafeBufferPointer { (pointer: UnsafeBufferPointer<Int32>) -> UnsafePointer<CChar>? in
            return llama_bridge_run_inference(prompt, Int32(maxNewTokens), pointer.baseAddress, Int32(pointer.count))
        }
        
        guard let result = cResult else {
            NSLog("[LlamaBridge] ERROR: cResult is nil")
            return ""
        }
        
        // Debug: check raw bytes
        let rawBytes = UnsafeBufferPointer(start: result, count: 50)
        let hexStr = rawBytes.prefix(20).map { String(format: "%02x", $0) }.joined(separator: " ")
        NSLog("[LlamaBridge] Raw bytes: %@", hexStr)
        
        let resultStr = String(cString: result)
        NSLog("[LlamaBridge] infer() DONE - result length=\(resultStr.count), preview=\(resultStr.prefix(50))")
        return resultStr
    }

    /// Run inference on a background queue; completion called on main.
    func inferAsync(prompt: String, maxNewTokens: Int, stopTokenIds: [Int], completion: @escaping (String) -> Void) {
        print("[LlamaBridge] inferAsync() START on background thread")
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            print("[LlamaBridge] inferAsync() calling infer() on bg thread")
            let result = self?.infer(prompt: prompt, maxNewTokens: maxNewTokens, stopTokenIds: stopTokenIds) ?? ""
            print("[LlamaBridge] inferAsync() back from infer(), result length=\(result.count), posting to main thread")
            DispatchQueue.main.async { 
                print("[LlamaBridge] inferAsync() completion() on main thread")
                completion(result) 
            }
        }
    }

    func freeModel() {
        llama_bridge_free()
        isModelLoaded = false
    }
}
