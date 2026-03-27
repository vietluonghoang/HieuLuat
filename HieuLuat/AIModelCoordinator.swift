//
//  AIModelCoordinator.swift
//  HieuLuat
//
//  Created by AI Assistant on 3/27/26.
//  Copyright © 2026 VietLH. All rights reserved.
//

import UIKit
import Network
import FirebaseRemoteConfig

class AIModelCoordinator: NSObject {
    
    static let shared = AIModelCoordinator()
    
    private let manager = AIModelManager.shared
    private let downloader = AIModelDownloader()
    private let unzipper = AIModelUnzipper()
    private let overlay = AIModelOverlayWindow.shared
    
    private override init() {
        super.init()
        downloader.delegate = self
        unzipper.delegate = self
        
        overlay.onCancel = { [weak self] in
            self?.cancelDownload()
        }
        overlay.onRetry = { [weak self] in
            self?.retryDownload()
        }
    }
    
    // MARK: - Public
    
    func checkAndPromptIfNeeded(from viewController: UIViewController) {
        guard manager.shouldPromptUser() else {
            if manager.checkModelAvailability() && !manager.isModelReady {
                overlay.show()
                listenForModelState()
                manager.loadModels()
            } else if !manager.checkModelAvailability() {
                // User opted in but model not fully downloaded (app was killed mid-download)
                startFullPipeline()
            }
            return
        }
        
        let alert = UIAlertController(
            title: "AI Search",
            message: "Bạn có muốn kích hoạt AI Search hỗ trợ tìm kiếm? (Cần tải khoảng 4GB dữ liệu)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Kích hoạt", style: .default) { [weak self] _ in
            self?.manager.userDidOptIn()
            self?.startFullPipeline()
        })
        alert.addAction(UIAlertAction(title: "Để sau", style: .cancel, handler: nil))
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func startFullPipeline() {
        manager.fetchRemoteModelConfig()
        
        if manager.checkModelAvailability() {
            manager.loadModels()
            listenForModelState()
            return
        }
        
        if !manager.checkDiskSpace() {
            let alert = UIAlertController(
                title: "Không đủ dung lượng",
                message: "Thiết bị cần ít nhất 9GB dung lượng trống để tải và cài đặt mô hình AI.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            topViewController()?.present(alert, animated: true, completion: nil)
            return
        }
        
        // Check if on cellular data and warn user
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            monitor.cancel()
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if path.usesInterfaceType(.cellular) && !path.usesInterfaceType(.wifi) {
                    self.showCellularWarning()
                } else {
                    self.beginDownload()
                }
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .utility))
    }
    
    private func showCellularWarning() {
        let alert = UIAlertController(
            title: "Đang dùng dữ liệu di động",
            message: "Bạn đang sử dụng mạng di động (4G/5G). Mô hình AI có dung lượng khoảng 4GB, có thể tiêu tốn nhiều dữ liệu. Bạn có muốn tiếp tục?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tiếp tục tải", style: .destructive) { [weak self] _ in
            self?.beginDownload()
        })
        alert.addAction(UIAlertAction(title: "Đợi WiFi", style: .cancel, handler: nil))
        topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    private func beginDownload() {
        overlay.show()
        listenForModelState()
        manager.startDownload()
        
        // Try to resume a previous interrupted download first
        if downloader.hasResumeData {
            print("AIModelCoordinator: Resuming interrupted download...")
            downloader.resumeDownload()
            return
        }
        
        guard let urlString = getModelURL(), let url = URL(string: urlString) else {
            overlay.showError(message: "Không tìm thấy URL tải mô hình từ cấu hình.")
            return
        }
        
        downloader.startDownload(from: url)
    }
    
    func cancelDownload() {
        downloader.cancelDownload()
        overlay.dismiss()
        manager.downloadFailed(error: "User cancelled")
    }
    
    func retryDownload() {
        startFullPipeline()
    }
    
    // MARK: - Private
    
    private func getModelURL() -> String? {
        let remoteConfig = FirebaseRemoteConfig.RemoteConfig.remoteConfig()
        return remoteConfig.configValue(forKey: "aiModelUrl").stringValue
    }
    
    private func listenForModelState() {
        NotificationCenter.default.removeObserver(self, name: .AIModelStateDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange(_:)),
            name: .AIModelStateDidChange,
            object: nil
        )
    }
    
    @objc private func handleStateChange(_ notification: Notification) {
        guard let state = notification.userInfo?["state"] as? AIModelState else { return }
        
        switch state {
        case .loadingModels(let current, let total):
            overlay.updateLoadingModels(current: current, total: total)
        case .ready:
            overlay.showSuccess()
            NotificationCenter.default.removeObserver(self, name: .AIModelStateDidChange, object: nil)
        case .error(let error):
            var message = "Đã xảy ra lỗi."
            switch error {
            case .networkUnavailable:
                message = "Không có kết nối mạng."
            case .insufficientStorage:
                message = "Không đủ dung lượng trống."
            case .downloadFailed(let detail):
                message = "Tải thất bại: \(detail)"
            case .unzipFailed(let detail):
                message = "Giải nén thất bại: \(detail)"
            case .modelLoadFailed(let detail):
                message = "Nạp mô hình thất bại: \(detail)"
            case .checksumMismatch:
                message = "File mô hình bị lỗi."
            case .lowMemory:
                message = "Thiết bị thiếu bộ nhớ RAM."
            }
            overlay.showError(message: message)
        default:
            break
        }
    }
    
    private func topViewController() -> UIViewController? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              var top = window.rootViewController else {
            return nil
        }
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}

// MARK: - AIModelDownloaderDelegate

extension AIModelCoordinator: AIModelDownloaderDelegate {
    
    func downloader(_ downloader: AIModelDownloader, didUpdateProgress progress: Double, speed: Double, downloadedBytes: Int64, totalBytes: Int64) {
        let downloadedMB = Double(downloadedBytes) / (1024.0 * 1024.0)
        let totalMB = Double(totalBytes) / (1024.0 * 1024.0)
        
        manager.updateDownloadProgress(progress: progress, speed: speed)
        overlay.updateDownloadProgress(progress: progress, speed: speed, downloadedMB: downloadedMB, totalMB: totalMB)
    }
    
    func downloader(_ downloader: AIModelDownloader, didFinishDownloadingTo location: URL) {
        let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let modelsDir = appSupportURL.appendingPathComponent("AIModels")
        
        unzipper.unzip(fileAt: location, to: modelsDir)
    }
    
    func downloader(_ downloader: AIModelDownloader, didFailWithError error: Error) {
        let nsError = error as NSError
        if nsError.code == NSURLErrorCancelled {
            return
        }
        manager.downloadFailed(error: error.localizedDescription)
    }
}

// MARK: - AIModelUnzipperDelegate

extension AIModelCoordinator: AIModelUnzipperDelegate {
    
    func unzipper(_ unzipper: AIModelUnzipper, didUpdateProgress progress: Double) {
        manager.updateUnzipProgress(progress: progress)
        overlay.updateUnzipProgress(progress: progress)
    }
    
    func unzipper(_ unzipper: AIModelUnzipper, didFinishUnzippingTo destination: URL) {
        manager.downloadAndUnzipCompleted()
    }
    
    func unzipper(_ unzipper: AIModelUnzipper, didFailWithError error: Error) {
        manager.unzipFailed(error: error.localizedDescription)
    }
}
