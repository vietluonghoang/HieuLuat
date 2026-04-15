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
    
    private static let modelsFolderName = "AIModels"
    private static let metaFileName = "meta.yaml"
    private static let minimumRequiredDiskSpaceBytes: UInt64 = 9 * 1024 * 1024 * 1024 // 9GB
    private static let minimumRAMBytes: UInt64 = 5 * 1024 * 1024 * 1024 // 5GB RAM — AI feature temporarily disabled
    private static let userDefaultsModelVersionKey = "ai_model_version"
    private static let userDefaultsOptedInKey = "ai_model_opted_in"
    
    // MARK: - Properties
    
    private var loadedModels: [String: MLModel] = [:]
    private var remoteModelUrl: String?
    private var remoteModelVersion: String?
    private(set) var modelConfig: AIModelConfig?
    private var tokenizer: AITokenizer?
    private var inferenceEngine: AIInferenceEngine?
    
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
    private var readyTimestamp: Date = .distantPast
    private static let memoryWarningGracePeriod: TimeInterval = 30 // seconds after load
    
    @objc private func handleMemoryWarning() {
        NSLog("AIModelManager: ⚠️ Memory warning (state: \(state))")
        switch state {
        case .ready:
            // ANE compilation after load causes a temporary memory spike.
            // Ignore memory warnings within a grace period after models become ready.
            let elapsed = Date().timeIntervalSince(readyTimestamp)
            if elapsed < AIModelManager.memoryWarningGracePeriod {
                NSLog("AIModelManager: Ignoring memory warning — within %.0fs grace period after load", elapsed)
                return
            }
            // First try evicting cached prefill models before full unload
            if #available(iOS 18.0, *), let qwenEngine = inferenceEngine as? QwenInferenceEngine {
                qwenEngine.evictPrefillModels()
                NSLog("AIModelManager: Evicted prefill models to free memory")
            } else if detectBackend() == .llama {
                NSLog("AIModelManager: Unloading Llama model to free memory")
                LlamaBridge.shared.freeModel()
                inferenceEngine = nil
                state = .idle
            } else {
                NSLog("AIModelManager: Unloading models to free memory")
                inferenceEngine?.isCancelled = true
                inferenceEngine = nil
                loadedModels.removeAll()
                state = .idle
            }
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
                                    reason: "Thiết bị cần ít nhất \(AIModelManager.minimumRAMBytes / (1024*1024*1024))GB RAM để chạy AI. Thiết bị hiện có \(totalRAM / (1024*1024))MB.")
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
        let backend = detectBackend()
        
        if backend == .llama {
            let fileManager = FileManager.default
            let files = try? fileManager.contentsOfDirectory(atPath: modelsDirectoryURL.path)
            return files?.contains(where: { $0.hasSuffix(".gguf") }) == true
        }

        // Load config from meta.yaml if not already loaded
        if modelConfig == nil {
            let metaURL = modelsDirectoryURL.appendingPathComponent(AIModelManager.metaFileName)
            modelConfig = AIModelConfig.load(from: metaURL)
        }
        
        guard let config = modelConfig else {
            // No meta.yaml — models not available
            return false
        }
        
        let fileManager = FileManager.default
        for fileName in config.allModelFileNames {
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
    
    func clearModelsDirectory() {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: modelsDirectoryURL.path) {
            do {
                let contents = try fileManager.contentsOfDirectory(atPath: modelsDirectoryURL.path)
                for file in contents {
                    try fileManager.removeItem(at: modelsDirectoryURL.appendingPathComponent(file))
                }
                print("AIModelManager: Models directory cleared")
            } catch {
                print("AIModelManager: Failed to clear models directory: \(error.localizedDescription)")
            }
        } else {
            try? fileManager.createDirectory(at: modelsDirectoryURL, withIntermediateDirectories: true)
        }
    }

    func startDownload() {
        // Prevent duplicate downloads
        guard !isBusy else {
            print("AIModelManager: startDownload() skipped — already busy")
            return
        }
        
        // Clean up old models before starting new download
        clearModelsDirectory()
        
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
    
    func detectBackend() -> AIModelBackend {
        let fileManager = FileManager.default
        let path = modelsDirectoryURL.path
        let files = try? fileManager.contentsOfDirectory(atPath: path)
        NSLog("AIModelManager: [DETECT] Checking backend in %@. Files: %@", path, files?.description ?? "nil")
        
        if files?.contains(where: { $0.hasSuffix(".gguf") }) == true {
            NSLog("AIModelManager: [DETECT] Detected .gguf file, returning .llama")
            return .llama
        }
        NSLog("AIModelManager: [DETECT] No .gguf file found, returning .coreML")
        return .coreML
    }

    func loadModels() {
        // Prevent duplicate loads
        guard !isModelReady && !isBusy else {
            print("AIModelManager: loadModels() skipped — already \(isModelReady ? "ready" : "busy")")
            return
        }
        
        let backend = detectBackend()
        
        if backend == .llama {
            modelConfig = AIModelConfig.dummyForLlama()
        } else {
            // Load config from meta.yaml
            let metaURL = modelsDirectoryURL.appendingPathComponent(AIModelManager.metaFileName)
            modelConfig = AIModelConfig.load(from: metaURL)
        }
        
        guard let config = modelConfig else {
            print("AIModelManager: ❌ Configuration not found (meta.yaml missing for CoreML)")
            state = .error(.modelLoadFailed("Configuration not found"))
            return
        }
        
        if backend == .llama {
            NSLog("AIModelManager: [LOAD] Llama backend detected")
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                
                // Find .gguf file
                let files = try? FileManager.default.contentsOfDirectory(atPath: self.modelsDirectoryURL.path)
                guard let ggufFile = files?.first(where: { $0.hasSuffix(".gguf") }) else {
                    DispatchQueue.main.async { self.state = .error(.modelLoadFailed("No GGUF file found")) }
                    return
                }
                
                let ggufURL = self.modelsDirectoryURL.appendingPathComponent(ggufFile)
                LlamaBridge.shared.loadModel(path: ggufURL.path)
                
                let tokenizer = AITokenizerFactory.create(for: config, modelDirectory: self.modelsDirectoryURL)
                NSLog("AIModelManager: Tokenizer created: %@", String(describing: type(of: tokenizer)))
                
                var engine: AIInferenceEngine? = nil
                if #available(iOS 18.0, *) {
                    engine = AIInferenceEngineFactory.create(for: config, backend: .llama, tokenizer: tokenizer)
                    NSLog("AIModelManager: Engine created (iOS 18+): %@", engine == nil ? "nil" : String(describing: type(of: engine!)))
                } else {
                    NSLog("AIModelManager: iOS < 18.0, engine creation skipped")
                }
                
                DispatchQueue.main.async {
                    self.tokenizer = tokenizer
                    self.inferenceEngine = engine
                    self.readyTimestamp = Date()
                    NSLog("AIModelManager: [Llama] State set to .ready (tokenizer=%@, engine=%@)",
                          String(describing: type(of: tokenizer)),
                          engine == nil ? "nil" : String(describing: type(of: engine!)))
                    self.state = .ready
                }
            }
            return
        }

        let modelFileNames = config.allModelFileNames
        let totalModels = modelFileNames.count
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
            
            let ffnFileNames = Set(config.ffnChunkFileNames)
            // For Qwen (multi-function), skip FFN loading here — engine loads on demand
            let skipFFN = config.modelType == .qwen
            
            for (index, fileName) in modelFileNames.enumerated() {
                DispatchQueue.main.async {
                    self.state = .loadingModels(current: index, total: totalModels)
                }
                
                // Skip FFN models for Qwen — they'll be loaded on-demand by the engine
                if skipFFN && ffnFileNames.contains(fileName) {
                    NSLog("AIModelManager: [LOAD] Skipping %@ — Qwen FFN loaded on-demand by engine", fileName)
                    continue
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
                    NSLog("AIModelManager: ❌ Failed to load %@: %@", fileName, "\(error)")
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
            
            // For multi-function FFN models (e.g. Qwen), the engine loads
            // prefill/infer functions on-demand from URLs to save memory.
            // For single-function models (e.g. Gemma), use the pre-loaded models.
            var ffnModelsForEngine: [MLModel] = []
            var ffnURLsForEngine: [URL]? = nil
            let isMultiFunction = config.modelType == .qwen
            
            if isMultiFunction {
                // Qwen: pass FFN URLs so engine can load prefill/infer on demand.
                // Don't pre-load FFN models — saves ~2GB of RAM.
                ffnURLsForEngine = config.ffnChunkFileNames.map {
                    self.modelsDirectoryURL.appendingPathComponent($0)
                }
                NSLog("AIModelManager: Qwen multi-function — FFN will be loaded on-demand (%d chunks)", ffnURLsForEngine!.count)
            } else {
                // Gemma/Llama: use models already loaded in the first pass
                for ffnName in config.ffnChunkFileNames {
                    if let existingModel = models[ffnName] {
                        ffnModelsForEngine.append(existingModel)
                    } else {
                        NSLog("AIModelManager: ❌ No FFN model available for %@", ffnName)
                        DispatchQueue.main.async {
                            self.state = .error(.modelLoadFailed("No FFN model for \(ffnName)"))
                        }
                        return
                    }
                }
            }
            
            // Initialize tokenizer via factory (based on model type)
            let tokenizer = AITokenizerFactory.create(for: config, modelDirectory: self.modelsDirectoryURL)
            
            // Initialize inference engine via factory (iOS 18+ only)
            var engine: AIInferenceEngine? = nil
            if #available(iOS 18.0, *) {
                let embedModel = models[config.embeddingsFileName]!
                let lmHeadModel = models[config.lmHeadFileName]!
                
                engine = AIInferenceEngineFactory.create(
                    for: config,
                    backend: .coreML,
                    embedModel: embedModel,
                    ffnModels: ffnModelsForEngine,
                    lmHeadModel: lmHeadModel,
                    ffnURLs: ffnURLsForEngine
                )
                NSLog("AIModelManager: Inference engine initialized (type: %@, multiFunction: %d)",
                      "\(config.modelType)", isMultiFunction ? 1 : 0)
            } else {
                NSLog("AIModelManager: Inference engine requires iOS 18+")
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
                self.readyTimestamp = Date()
                self.state = .ready
                let finalFree = self.getAvailableMemory()
                NSLog("AIModelManager: ✅ All models loaded. Free: %luMB, app used: %luMB, tokenizer: %@, engine: %@",
                      finalFree / (1024*1024),
                      self.getAppUsedMemory() / (1024*1024),
                      String(describing: type(of: tokenizer)),
                      engine == nil ? "nil" : String(describing: type(of: engine!)))
            }
        }
    }
    
    private func loadSingleModel(at url: URL, functionName: String? = nil) throws -> MLModel {
        let fileName = url.lastPathComponent
        let funcLabel = functionName.map { " (func: \($0))" } ?? ""
        let freeBefore = getAvailableMemory()
        NSLog("AIModelManager: [LOAD] Starting %@%@ - free: %luMB", fileName, funcLabel, freeBefore / (1024*1024))
        
        let config = MLModelConfiguration()
        if #available(iOS 16.0, *) {
            config.computeUnits = .cpuAndNeuralEngine
        } else {
            config.computeUnits = .all
        }
        
        // If a specific function name is requested, set it
        if #available(iOS 18.0, *), let funcName = functionName {
            config.functionName = funcName
        }
        
        do {
            let model = try MLModel(contentsOf: url, configuration: config)
            let freeAfter = getAvailableMemory()
            NSLog("AIModelManager: [LOAD] %@%@ - OK, free: %luMB", fileName, funcLabel, freeAfter / (1024*1024))
            return model
        } catch {
            let errorDesc = "\(error)"
            NSLog("AIModelManager: [LOAD] %@%@ - failed: %@", fileName, funcLabel, errorDesc)
            
            // If no explicit function name was given and it's a multi-function error,
            // try known function names
            if functionName == nil,
               (errorDesc.contains("multi-function") || errorDesc.contains("function")) {
                NSLog("AIModelManager: [LOAD] %@ - multi-function detected, trying known function names...", fileName)
                
                if #available(iOS 18.0, *) {
                    // Try the actual ANEMLL function names first, then common ones
                    let candidates = ["infer", "prefill", "main", "predict", "forward"]
                    for funcName in candidates {
                        let mfConfig = MLModelConfiguration()
                        if #available(iOS 16.0, *) {
                            mfConfig.computeUnits = .cpuAndNeuralEngine
                        } else {
                            mfConfig.computeUnits = .all
                        }
                        mfConfig.functionName = funcName
                        do {
                            NSLog("AIModelManager: [LOAD] %@ - trying functionName=\"%@\"...", fileName, funcName)
                            let model = try MLModel(contentsOf: url, configuration: mfConfig)
                            NSLog("AIModelManager: [LOAD] %@ - OK with \"%@\"", fileName, funcName)
                            return model
                        } catch {
                            NSLog("AIModelManager: [LOAD] %@ - \"%@\" failed: %@", fileName, funcName, "\(error)")
                            continue
                        }
                    }
                }
                throw AIModelError.modelLoadFailed("No valid function found in \(fileName)")
            }
            
            throw error
        }
    }
    
    // MARK: - Inference
    
    /// Cancel any in-flight inference so a new one can start cleanly.
    /// The engine's serial queue ensures the cancelled run finishes before the next starts.
    func cancelInference() {
        inferenceEngine?.isCancelled = true
    }
    
    func runInference(input: String, completion: @escaping (String) -> Void) {
         NSLog("AIModelManager: runInference() CALLED with input=\(input.prefix(50))... isModelReady=%d", isModelReady ? 1 : 0)
         NSLog("AIModelManager: runInference called, isModelReady=%d, tokenizer=%@, engine=%@",
               isModelReady ? 1 : 0,
               tokenizer == nil ? "nil" : String(describing: type(of: tokenizer!)),
               inferenceEngine == nil ? "nil" : String(describing: type(of: inferenceEngine!)))
        
        guard isModelReady else {
            NSLog("AIModelManager: Models not ready for inference")
            completion("")
            return
        }
        
        guard let tokenizer = self.tokenizer else {
            NSLog("AIModelManager: Tokenizer not initialized")
            completion("")
            return
        }
        
        guard let engine = self.inferenceEngine else {
            NSLog("AIModelManager: Inference engine not available")
            completion("")
            return
        }
        
        // Cancel any previous in-flight inference (generation ID bump handles the rest)
        engine.isCancelled = true
        
        let stopTokenIds = tokenizer.stopTokenIds
        
        if detectBackend() == .llama, let llamaEngine = engine as? LlamaInferenceEngine {
            // Build prompt
            let inputTokens = tokenizer.buildPrompt(userMessage: input)
            let formattedPrompt = tokenizer.decode(inputTokens)
            
            NSLog("AIModelManager: Using Llama engine (prompt length: %d)", formattedPrompt.count)
            
            llamaEngine.runGenerate(prompt: formattedPrompt, maxNewTokens: 10, stopTokenIds: stopTokenIds) { outputTokens in
                let result = tokenizer.decode(outputTokens)
                completion(result)
            }
        } else {
            // Build prompt on main thread (fast)
            let inputTokens = tokenizer.buildPrompt(userMessage: input)
            NSLog("AIModelManager: Prompt tokenized to %d tokens", inputTokens.count)
            
            let startTime = CFAbsoluteTimeGetCurrent()
            
            engine.runGenerate(inputTokens: inputTokens, maxNewTokens: 10, stopTokenIds: stopTokenIds) { outputTokens in
                // Already on main queue
                if outputTokens.isEmpty {
                    NSLog("AIModelManager: Inference returned empty (cancelled or error)")
                    completion("")
                    return
                }
                
                let filteredTokens = outputTokens.filter { !tokenizer.isStopToken($0) }
                let result = tokenizer.decode(filteredTokens)
                
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
