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
    
    /// True when the manager is actively downloading, unzipping, or loading models.
    var isBusy: Bool {
        switch state {
        case .downloading, .unzipping, .loadingModels:
            return true
        default:
            return false
        }
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
    private static let minimumRAMBytes: UInt64 = 5 * 1024 * 1024 * 1024 // 5GB RAM minimum
    private static let userDefaultsModelVersionKey = "ai_model_version"
    private static let userDefaultsOptedInKey = "ai_model_opted_in"
    
    // MARK: - Properties
    
    private var loadedModels: [String: MLModel] = [:]
    private var remoteModelUrl: String?
    private var remoteModelVersion: String?
    private var tokenizer: GemmaTokenizer?
    private var inferenceEngine: Any? // GemmaInferenceEngine (iOS 18+)
    
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
    
    private var memoryWarningsDuringLoad: Int = 0
    
    @objc private func handleMemoryWarning() {
        print("AIModelManager: ⚠️ Memory warning (state: \(state))")
        switch state {
        case .ready:
            print("AIModelManager: Unloading models to free memory")
            inferenceEngine = nil
            loadedModels.removeAll()
            state = .idle
        case .loadingModels:
            // Do NOT abort — CoreML compile causes temporary memory spikes.
            // The memory will recover after compilation finishes.
            memoryWarningsDuringLoad += 1
            print("AIModelManager: Memory warning #\(memoryWarningsDuringLoad) during load (expected during CoreML compile) - continuing")
        default:
            break
        }
    }
    
    // MARK: - Device Capability
    
    struct DeviceCapability {
        let totalRAM: UInt64
        let availableRAM: UInt64
        let chipGeneration: Int // A-series number (e.g., 15 for A15)
        let isSupported: Bool
        let reason: String?
    }
    
    func checkDeviceCapability() -> DeviceCapability {
        let totalRAM = ProcessInfo.processInfo.physicalMemory
        let availableRAM = getAvailableMemory()
        let chip = detectChipGeneration()
        
        print("AIModelManager: Device check - RAM: \(totalRAM / (1024*1024))MB, Available: \(availableRAM / (1024*1024))MB, Chip: A\(chip)")
        
        // Check iOS version
        guard #available(iOS 18.0, *) else {
            return DeviceCapability(totalRAM: totalRAM, availableRAM: availableRAM,
                                    chipGeneration: chip, isSupported: false,
                                    reason: "AI Search yêu cầu iOS 18 trở lên.")
        }
        
        // Check RAM (need 6GB+ total)
        if totalRAM < AIModelManager.minimumRAMBytes {
            return DeviceCapability(totalRAM: totalRAM, availableRAM: availableRAM,
                                    chipGeneration: chip, isSupported: false,
                                    reason: "Thiết bị cần ít nhất 5GB RAM để chạy AI. Thiết bị hiện có \(totalRAM / (1024*1024))MB.")
        }
        
        // Check chip (A15+ recommended for Neural Engine performance)
        if chip < 15 {
            return DeviceCapability(totalRAM: totalRAM, availableRAM: availableRAM,
                                    chipGeneration: chip, isSupported: false,
                                    reason: "AI Search yêu cầu chip A15 Bionic trở lên (iPhone 13 trở lên).")
        }
        
        return DeviceCapability(totalRAM: totalRAM, availableRAM: availableRAM,
                                chipGeneration: chip, isSupported: true, reason: nil)
    }
    
    private func getAvailableMemory() -> UInt64 {
        // os_proc_available_memory() returns the actual memory available
        // to this process before the OS will jetsam/kill it.
        // This is the correct API — NOT (total - resident_size).
        if #available(iOS 13.0, *) {
            let available = os_proc_available_memory()
            return UInt64(available)
        }
        return 0
    }
    
    private func getAppUsedMemory() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        return result == KERN_SUCCESS ? UInt64(info.resident_size) : 0
    }
    
    private func detectChipGeneration() -> Int {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(cString: $0)
            }
        }
        // iPhone identifiers: iPhone14,x = A15, iPhone15,x = A16, iPhone16,x = A17, iPhone17,x = A18
        if machine.hasPrefix("iPhone") {
            let parts = machine.replacingOccurrences(of: "iPhone", with: "").split(separator: ",")
            if let major = Int(parts.first ?? "") {
                switch major {
                case 17: return 18 // iPhone 16
                case 16: return 17 // iPhone 15
                case 15: return 16 // iPhone 14
                case 14: return 15 // iPhone 13
                case 13: return 14 // iPhone 12
                case 12: return 13 // iPhone 11
                default: return major >= 17 ? 18 : 12
                }
            }
        }
        // iPad identifiers
        if machine.hasPrefix("iPad") {
            let parts = machine.replacingOccurrences(of: "iPad", with: "").split(separator: ",")
            if let major = Int(parts.first ?? "") {
                if major >= 16 { return 17 }
                if major >= 14 { return 15 }
                return 14
            }
        }
        // Simulator
        if machine == "x86_64" || machine == "arm64" {
            return 99
        }
        return 12
    }
    
    func checkAvailableMemoryForLoading() -> Bool {
        let available = getAvailableMemory()
        let appUsed = getAppUsedMemory()
        let needed: UInt64 = 800 * 1024 * 1024 // Need ~800MB free to safely load models
        print("AIModelManager: Memory check - available (os_proc): \(available / (1024*1024))MB, app used: \(appUsed / (1024*1024))MB, needed: \(needed / (1024*1024))MB")
        return available >= needed
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
        // Prevent duplicate downloads
        guard !isBusy else {
            print("AIModelManager: startDownload() skipped — already busy")
            return
        }
        
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
        // Reset state so loadModels() guard allows it
        state = .idle
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
        // Prevent duplicate loads
        guard !isModelReady && !isBusy else {
            print("AIModelManager: loadModels() skipped — already \(isModelReady ? "ready" : "busy")")
            return
        }
        
        let totalModels = AIModelManager.modelFileNames.count
        state = .loadingModels(current: 0, total: totalModels)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Pre-flight memory check
            if !self.checkAvailableMemoryForLoading() {
                print("AIModelManager: Insufficient memory to start loading")
                DispatchQueue.main.async {
                    self.state = .error(.lowMemory)
                }
                return
            }
            
            self.memoryWarningsDuringLoad = 0
            var models = [String: MLModel]()
            
            for (index, fileName) in AIModelManager.modelFileNames.enumerated() {
                DispatchQueue.main.async {
                    self.state = .loadingModels(current: index, total: totalModels)
                }
                
                let fileURL = self.modelsDirectoryURL.appendingPathComponent(fileName)
                
                // Load each model inside autoreleasepool to release intermediate memory
                var loadError: Error? = nil
                autoreleasepool {
                    do {
                        let model = try self.loadSingleModel(at: fileURL)
                        models[fileName] = model
                    } catch {
                        loadError = error
                    }
                }
                
                if let error = loadError {
                    print("AIModelManager: ❌ Failed to load \(fileName): \(error)")
                    DispatchQueue.main.async {
                        self.state = .error(.modelLoadFailed("\(fileName): \(error.localizedDescription)"))
                    }
                    return
                }
                
                // Check memory AFTER load completes (spike has recovered)
                let freeAfterLoad = self.getAvailableMemory()
                if freeAfterLoad < 100 * 1024 * 1024 { // less than 100MB free after recovery
                    print("AIModelManager: ⚠️ Only \(freeAfterLoad / (1024*1024))MB free after loading \(fileName) - aborting remaining models")
                    models.removeAll()
                    DispatchQueue.main.async {
                        self.state = .error(.lowMemory)
                    }
                    return
                }
                
                // Brief pause between models to let system stabilize
                Thread.sleep(forTimeInterval: 0.3)
            }
            
            // Final memory check after all models loaded
            let freeAfter = self.getAvailableMemory()
            print("AIModelManager: All models loaded. Free memory: \(freeAfter / (1024*1024))MB")
            
            // Initialize tokenizer
            let tokenizer = GemmaTokenizer(modelDirectory: self.modelsDirectoryURL)
            
            // Initialize inference engine (iOS 18+ only)
            var engine: Any? = nil
            if #available(iOS 18.0, *) {
                let embedModel = models[AIModelManager.modelFileNames[0]]!
                let ffnModels = [
                    models[AIModelManager.modelFileNames[1]]!,
                    models[AIModelManager.modelFileNames[2]]!,
                    models[AIModelManager.modelFileNames[3]]!
                ]
                let lmHeadModel = models[AIModelManager.modelFileNames[4]]!
                engine = GemmaInferenceEngine(
                    embedModel: embedModel,
                    ffnModels: ffnModels,
                    lmHeadModel: lmHeadModel,
                    contextLength: 4096,
                    slidingWindow: 1024
                )
                print("AIModelManager: Inference engine initialized")
            } else {
                print("AIModelManager: Inference engine requires iOS 18+")
            }
            
            DispatchQueue.main.async {
                if engine != nil {
                    // Engine holds its own references to models.
                    // Don't keep duplicate references in loadedModels to save RAM.
                    self.loadedModels.removeAll()
                } else {
                    self.loadedModels = models
                }
                self.tokenizer = tokenizer
                self.inferenceEngine = engine
                self.state = .ready
                let finalFree = self.getAvailableMemory()
                print("AIModelManager: ✅ All models loaded. Free: \(finalFree / (1024*1024))MB, app used: \(self.getAppUsedMemory() / (1024*1024))MB, mem warnings during load: \(self.memoryWarningsDuringLoad)")
            }
        }
    }
    
    private func loadSingleModel(at url: URL) throws -> MLModel {
        let fileName = url.lastPathComponent
        let freeBefore = getAvailableMemory()
        print("AIModelManager: [LOAD] Starting \(fileName) - free: \(freeBefore / (1024*1024))MB, app used: \(getAppUsedMemory() / (1024*1024))MB")
        
        let config = MLModelConfiguration()
        // Use CPU+NeuralEngine only (matching ANEMLL reference).
        // .all includes GPU which doubles memory buffers unnecessarily.
        if #available(iOS 16.0, *) {
            config.computeUnits = .cpuAndNeuralEngine
        } else {
            config.computeUnits = .all
        }
        
        // Multi-function CoreML models (like Gemma 3n) require
        // specifying functionName on iOS 18+ / macOS 15+.
        // Try without functionName first, then retry with known function names.
        do {
            print("AIModelManager: [LOAD] \(fileName) - calling MLModel(contentsOf:)...")
            let model = try MLModel(contentsOf: url, configuration: config)
            let freeAfter = getAvailableMemory()
            let deltaMB = Int64(freeBefore / (1024*1024)) - Int64(freeAfter / (1024*1024))
            print("AIModelManager: [LOAD] \(fileName) - OK, free: \(freeAfter / (1024*1024))MB (delta: \(deltaMB > 0 ? "-" : "+")\(abs(deltaMB))MB)")
            return model
        } catch {
            let errorDesc = "\(error)"
            print("AIModelManager: [LOAD] \(fileName) - first attempt failed: \(errorDesc)")
            
            guard errorDesc.contains("multi-function") || errorDesc.contains("multifunction") ||
                  errorDesc.contains("multi_function") || errorDesc.contains("function") else {
                throw error
            }
            
            print("AIModelManager: [LOAD] \(fileName) - multi-function detected, trying functionName...")
            
            if #available(iOS 18.0, *) {
                let functionNames = ["main", "predict", "forward"]
                for funcName in functionNames {
                    let mfConfig = MLModelConfiguration()
                    if #available(iOS 16.0, *) {
                        mfConfig.computeUnits = .cpuAndNeuralEngine
                    } else {
                        mfConfig.computeUnits = .all
                    }
                    mfConfig.functionName = funcName
                    do {
                        print("AIModelManager: [LOAD] \(fileName) - trying functionName=\"\(funcName)\"...")
                        let model = try MLModel(contentsOf: url, configuration: mfConfig)
                        let freeAfter = getAvailableMemory()
                        print("AIModelManager: [LOAD] \(fileName) - OK with \"\(funcName)\", free: \(freeAfter / (1024*1024))MB")
                        return model
                    } catch {
                        print("AIModelManager: [LOAD] \(fileName) - \"\(funcName)\" failed: \(error)")
                        continue
                    }
                }
                throw AIModelError.modelLoadFailed("No valid function found in \(fileName)")
            } else {
                throw AIModelError.modelLoadFailed("Multi-function models require iOS 18.0+")
            }
        }
    }
    
    // MARK: - Inference
    
    /// Cancel any in-flight inference so a new one can start cleanly.
    func cancelInference() {
        if #available(iOS 18.0, *), let engine = inferenceEngine as? GemmaInferenceEngine {
            engine.isCancelled = true
        }
    }
    
    func runInference(input: String, completion: @escaping (String) -> Void) {
        guard isModelReady else {
            print("AIModelManager: Models not ready for inference")
            completion("")
            return
        }
        
        guard let tokenizer = self.tokenizer else {
            print("AIModelManager: Tokenizer not initialized")
            completion("")
            return
        }
        
        guard #available(iOS 18.0, *), let engine = self.inferenceEngine as? GemmaInferenceEngine else {
            print("AIModelManager: Inference engine not available (requires iOS 18+)")
            completion("")
            return
        }
        
        // Cancel any previous in-flight inference
        engine.isCancelled = true
        
        // Build prompt on main thread (fast)
        let inputTokens = tokenizer.buildPrompt(userMessage: input)
        print("AIModelManager: Prompt tokenized to \(inputTokens.count) tokens")
        
        let stopTokenIds: Set<Int> = [tokenizer.eosTokenId, tokenizer.endOfTurnTokenId]
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Run on engine's serial queue (ensures previous cancelled inference finishes first)
        engine.runGenerate(inputTokens: inputTokens, maxNewTokens: 256, stopTokenIds: stopTokenIds) { outputTokens in
            // Already on main queue
            if outputTokens.isEmpty {
                print("AIModelManager: Inference returned empty (cancelled or error)")
                completion("")
                return
            }
            
            let filteredTokens = outputTokens.filter { !tokenizer.isStopToken($0) }
            let result = tokenizer.decode(filteredTokens)
            
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime
            let tokensPerSec = outputTokens.count > 0 ? Double(outputTokens.count) / elapsed : 0
            print("AIModelManager: Generated \(outputTokens.count) tokens in \(String(format: "%.1f", elapsed))s (\(String(format: "%.1f", tokensPerSec)) t/s)")
            print("AIModelManager: Result: \(result)")
            
            completion(result)
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
