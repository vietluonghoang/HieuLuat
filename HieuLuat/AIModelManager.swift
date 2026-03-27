//
//  AIModelManager.swift
//  HieuLuat
//
//  Created by AI Assistant on 3/27/26.
//  Copyright © 2026 VietLH. All rights reserved.
//

import Foundation
import UIKit
import CoreML
import FirebaseRemoteConfig

// MARK: - Enums

enum AIModelError: Error {
    case networkUnavailable
    case insufficientStorage
    case downloadFailed(String)
    case unzipFailed(String)
    case modelLoadFailed(String)
    case checksumMismatch
    case lowMemory
}

enum AIModelState {
    case idle
    case checkingRemoteConfig
    case downloading(progress: Double, speed: Double)
    case unzipping(progress: Double)
    case loadingModels(current: Int, total: Int)
    case ready
    case error(AIModelError)
}

// MARK: - Delegate Protocol

protocol AIModelManagerDelegate: AnyObject {
    func aiModelManagerDidChangeState(_ manager: AIModelManager, state: AIModelState)
}

// MARK: - Notification

extension Notification.Name {
    static let AIModelStateDidChange = Notification.Name("AIModelStateDidChange")
}

// MARK: - AIModelManager

class AIModelManager {
    
    static let shared = AIModelManager()
    
    weak var delegate: AIModelManagerDelegate?
    
    private(set) var state: AIModelState = .idle {
        didSet {
            delegate?.aiModelManagerDidChangeState(self, state: state)
            NotificationCenter.default.post(
                name: .AIModelStateDidChange,
                object: self,
                userInfo: ["state": state]
            )
        }
    }
    
    var isModelReady: Bool {
        if case .ready = state {
            return true
        }
        return false
    }
    
    // MARK: - Constants
    
    private static let modelFileNames = [
        "gemma3_embeddings_lut8.mlmodelc",
        "gemma3_FFN_PF_lut6_chunk_01of03.mlmodelc",
        "gemma3_FFN_PF_lut6_chunk_02of03.mlmodelc",
        "gemma3_FFN_PF_lut6_chunk_03of03.mlmodelc",
        "gemma3_lm_head_lut6.mlmodelc"
    ]
    
    private static let modelsFolderName = "AIModels"
    private static let minimumRequiredDiskSpaceBytes: UInt64 = 9 * 1024 * 1024 * 1024 // 9GB
    private static let userDefaultsModelVersionKey = "ai_model_version"
    private static let userDefaultsOptedInKey = "ai_model_opted_in"
    
    // MARK: - Properties
    
    private var loadedModels: [String: MLModel] = [:]
    private var remoteModelUrl: String?
    private var remoteModelVersion: String?
    
    private var modelsDirectoryURL: URL {
        let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupportURL.appendingPathComponent(AIModelManager.modelsFolderName)
    }
    
    var modelVersion: String? {
        get {
            return UserDefaults.standard.string(forKey: AIModelManager.userDefaultsModelVersionKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AIModelManager.userDefaultsModelVersionKey)
        }
    }
    
    private var isOptedIn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: AIModelManager.userDefaultsOptedInKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AIModelManager.userDefaultsOptedInKey)
        }
    }
    
    // MARK: - Init
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Memory Warning
    
    @objc private func handleMemoryWarning() {
        if case .ready = state {
            print("AIModelManager: Memory warning received, unloading models")
            loadedModels.removeAll()
            state = .idle
        }
    }
    
    // MARK: - Model Availability
    
    func checkModelAvailability() -> Bool {
        let fileManager = FileManager.default
        for fileName in AIModelManager.modelFileNames {
            let fileURL = modelsDirectoryURL.appendingPathComponent(fileName)
            var isDirectory: ObjCBool = false
            if !fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory) || !isDirectory.boolValue {
                return false
            }
        }
        return true
    }
    
    // MARK: - Remote Config
    
    func fetchRemoteModelConfig() {
        state = .checkingRemoteConfig
        
        let remoteConfig = RemoteConfig.remoteConfig()
        let url = remoteConfig.configValue(forKey: "aiModelUrl").stringValue
        let version = remoteConfig.configValue(forKey: "aiModelVersion").stringValue
        
        remoteModelUrl = url
        remoteModelVersion = version
        
        print("AIModelManager: Remote model URL = \(url ?? "nil")")
        print("AIModelManager: Remote model version = \(version ?? "nil")")
        
        if let remoteVersion = version, !remoteVersion.isEmpty {
            let localVersion = modelVersion
            if localVersion != remoteVersion {
                print("AIModelManager: New model version available (\(remoteVersion) vs local \(localVersion ?? "none"))")
            } else {
                print("AIModelManager: Model is up to date (version \(remoteVersion))")
            }
        }
        
        state = .idle
    }
    
    // MARK: - Disk Space
    
    func checkDiskSpace() -> Bool {
        do {
            let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let values = try appSupportURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            if let availableBytes = values.volumeAvailableCapacityForImportantUsage {
                let available = UInt64(availableBytes)
                print("AIModelManager: Available disk space = \(available / (1024 * 1024)) MB")
                return available >= AIModelManager.minimumRequiredDiskSpaceBytes
            }
        } catch {
            print("AIModelManager: Failed to check disk space: \(error.localizedDescription)")
        }
        return false
    }
    
    // MARK: - Download
    
    func startDownload() {
        guard let urlString = remoteModelUrl, !urlString.isEmpty else {
            state = .error(.downloadFailed("No model URL available from Remote Config"))
            return
        }
        
        if !checkDiskSpace() {
            state = .error(.insufficientStorage)
            return
        }
        
        state = .downloading(progress: 0.0, speed: 0.0)
        
        // Actual download will be handled by AIModelDownloader class
        print("AIModelManager: Download triggered for URL: \(urlString)")
    }
    
    func updateDownloadProgress(progress: Double, speed: Double) {
        state = .downloading(progress: progress, speed: speed)
    }
    
    func updateUnzipProgress(progress: Double) {
        state = .unzipping(progress: progress)
    }
    
    func downloadAndUnzipCompleted() {
        if let version = remoteModelVersion {
            modelVersion = version
        }
        loadModels()
    }
    
    func downloadFailed(error: String) {
        state = .error(.downloadFailed(error))
    }
    
    func unzipFailed(error: String) {
        state = .error(.unzipFailed(error))
    }
    
    // MARK: - Load Models
    
    func loadModels() {
        let totalModels = AIModelManager.modelFileNames.count
        state = .loadingModels(current: 0, total: totalModels)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var models = [String: MLModel]()
            
            for (index, fileName) in AIModelManager.modelFileNames.enumerated() {
                DispatchQueue.main.async {
                    self.state = .loadingModels(current: index, total: totalModels)
                }
                
                let fileURL = self.modelsDirectoryURL.appendingPathComponent(fileName)
                
                do {
                    let model = try self.loadSingleModel(at: fileURL)
                    models[fileName] = model
                    print("AIModelManager: Loaded model \(fileName) (\(index + 1)/\(totalModels))")
                } catch {
                    print("AIModelManager: Failed to load model \(fileName): \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.state = .error(.modelLoadFailed("Failed to load \(fileName): \(error.localizedDescription)"))
                    }
                    return
                }
            }
            
            DispatchQueue.main.async {
                self.loadedModels = models
                self.state = .ready
                print("AIModelManager: All models loaded successfully")
            }
        }
    }
    
    private func loadSingleModel(at url: URL) throws -> MLModel {
        let config = MLModelConfiguration()
        config.computeUnits = .all
        
        // Multi-function CoreML models (like Gemma 3n) require
        // specifying functionName on iOS 18+ / macOS 15+.
        // Try without functionName first, then retry with known function names.
        do {
            return try MLModel(contentsOf: url, configuration: config)
        } catch {
            let errorDesc = error.localizedDescription
            guard errorDesc.contains("multi-function") || errorDesc.contains("multifunction") else {
                throw error
            }
            
            print("AIModelManager: Multi-function model detected, trying with functionName...")
            
            if #available(iOS 18.0, *) {
                let functionNames = ["main", "predict", "forward"]
                for funcName in functionNames {
                    let mfConfig = MLModelConfiguration()
                    mfConfig.computeUnits = .all
                    mfConfig.functionName = funcName
                    do {
                        let model = try MLModel(contentsOf: url, configuration: mfConfig)
                        print("AIModelManager: Loaded with functionName=\"\(funcName)\"")
                        return model
                    } catch {
                        print("AIModelManager: functionName=\"\(funcName)\" failed, trying next...")
                        continue
                    }
                }
                throw AIModelError.modelLoadFailed("No valid function found in multi-function model at \(url.lastPathComponent)")
            } else {
                throw AIModelError.modelLoadFailed("Multi-function models require iOS 18.0+. Current device is not supported.")
            }
        }
    }
    
    // MARK: - Inference
    
    func runInference(input: String, completion: @escaping (String) -> Void) {
        guard isModelReady else {
            print("AIModelManager: Models not ready for inference")
            completion("")
            return
        }
        
        // Placeholder: chain models in pipeline order
        // 1. gemma3_embeddings_lut8
        // 2. gemma3_FFN_PF_lut6_chunk_01of03
        // 3. gemma3_FFN_PF_lut6_chunk_02of03
        // 4. gemma3_FFN_PF_lut6_chunk_03of03
        // 5. gemma3_lm_head_lut6
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            _ = self.loadedModels[AIModelManager.modelFileNames[0]] // embeddings
            _ = self.loadedModels[AIModelManager.modelFileNames[1]] // FFN chunk 1
            _ = self.loadedModels[AIModelManager.modelFileNames[2]] // FFN chunk 2
            _ = self.loadedModels[AIModelManager.modelFileNames[3]] // FFN chunk 3
            _ = self.loadedModels[AIModelManager.modelFileNames[4]] // lm_head
            
            // TODO: Implement actual inference pipeline
            let result = ""
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    // MARK: - Delete Model
    
    func deleteModel() {
        loadedModels.removeAll()
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: modelsDirectoryURL.path) {
            do {
                try fileManager.removeItem(at: modelsDirectoryURL)
                print("AIModelManager: Model files deleted")
            } catch {
                print("AIModelManager: Failed to delete model files: \(error.localizedDescription)")
            }
        }
        
        modelVersion = nil
        state = .idle
    }
    
    // MARK: - User Opt-in
    
    func userDidOptIn() {
        isOptedIn = true
        print("AIModelManager: User opted in for AI model")
    }
    
    func userDidOptOut() {
        isOptedIn = false
        deleteModel()
        print("AIModelManager: User opted out of AI model")
    }
    
    func shouldPromptUser() -> Bool {
        return !isOptedIn && !checkModelAvailability()
    }
}
