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

    /// Load the GGUF model bundled in Resources. Safe to call multiple times.
    func loadModel() {
        guard !isModelLoaded else { return }

        guard let path = Bundle.main.path(forResource: "gemma-4-E2B-it-Q4_K_M", ofType: "gguf") else {
            NSLog("[LlamaBridge] ERROR: GGUF file not found in bundle")
            return
        }

        NSLog("[LlamaBridge] loading model at: %@", path)
        llama_bridge_init_model(path)
        isModelLoaded = true
    }

    /// Run inference synchronously and return the generated text.
    func infer(prompt: String) -> String {
        guard isModelLoaded else {
            NSLog("[LlamaBridge] ERROR: model not loaded")
            return ""
        }

        guard let cResult = llama_bridge_run_inference(prompt) else {
            return ""
        }
        return String(cString: cResult)
    }

    /// Run inference on a background queue; completion called on main.
    func inferAsync(prompt: String, completion: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let result = self?.infer(prompt: prompt) ?? ""
            DispatchQueue.main.async { completion(result) }
        }
    }

    func freeModel() {
        llama_bridge_free()
        isModelLoaded = false
    }
}
