//
//  AIModelDownloader.swift
//  HieuLuat
//
//  Created by AI Assistant on 3/27/26.
//  Copyright © 2026 VietLH. All rights reserved.
//

import UIKit

protocol AIModelDownloaderDelegate: AnyObject {
    func downloader(_ downloader: AIModelDownloader, didUpdateProgress progress: Double, speed: Double, downloadedBytes: Int64, totalBytes: Int64)
    func downloader(_ downloader: AIModelDownloader, didFinishDownloadingTo location: URL)
    func downloader(_ downloader: AIModelDownloader, didFailWithError error: Error)
}

class AIModelDownloader: NSObject, URLSessionDownloadDelegate {

    weak var delegate: AIModelDownloaderDelegate?

    var backgroundCompletionHandler: (() -> Void)?

    private var backgroundSession: URLSession!
    private var downloadTask: URLSessionDownloadTask?
    private var resumeData: Data?
    private var downloadStartTime: Date = Date()
    private var lastBytesWritten: Int64 = 0
    private var lastUpdateTime: Date = Date()

    // Sliding window for smooth speed calculation
    private var speedSamples: [(time: Date, bytes: Int64)] = []
    private let speedWindowDuration: TimeInterval = 2.0

    // Throttle delegate callbacks to max 2 per second
    private var lastCallbackTime: Date = .distantPast
    private let callbackInterval: TimeInterval = 0.5

    private var resumeDataFileURL: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("aimodel_download_resume.dat")
    }

    override init() {
        super.init()

        let config = URLSessionConfiguration.background(withIdentifier: "com.hieuluat.aimodel.download")
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        backgroundSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    // MARK: - Public Methods

    func startDownload(from url: URL) {
        cleanUpResumeDataFile()
        resumeData = nil
        speedSamples.removeAll()
        downloadStartTime = Date()
        lastUpdateTime = Date()
        lastBytesWritten = 0

        downloadTask = backgroundSession.downloadTask(with: url)
        downloadTask?.resume()
    }

    func pauseDownload() {
        downloadTask?.cancel(byProducingResumeData: { [weak self] data in
            guard let self = self else { return }
            self.resumeData = data
            self.saveResumeDataToDisk()
        })
        downloadTask = nil
    }

    func resumeDownload() {
        if resumeData == nil {
            loadResumeDataFromDisk()
        }

        guard let data = resumeData else { return }

        speedSamples.removeAll()
        lastUpdateTime = Date()
        lastBytesWritten = 0

        downloadTask = backgroundSession.downloadTask(withResumeData: data)
        downloadTask?.resume()
        resumeData = nil
        cleanUpResumeDataFile()
    }

    func cancelDownload() {
        downloadTask?.cancel()
        downloadTask = nil
        resumeData = nil
        cleanUpResumeDataFile()
        speedSamples.removeAll()
    }

    // MARK: - Resume Data Persistence

    private func saveResumeDataToDisk() {
        guard let data = resumeData else { return }
        do {
            try data.write(to: resumeDataFileURL, options: .atomic)
        } catch {
            print("AIModelDownloader: Failed to save resume data - \(error.localizedDescription)")
        }
    }

    private func loadResumeDataFromDisk() {
        guard FileManager.default.fileExists(atPath: resumeDataFileURL.path) else { return }
        do {
            resumeData = try Data(contentsOf: resumeDataFileURL)
        } catch {
            print("AIModelDownloader: Failed to load resume data - \(error.localizedDescription)")
        }
    }

    private func cleanUpResumeDataFile() {
        try? FileManager.default.removeItem(at: resumeDataFileURL)
    }

    // MARK: - Speed Calculation

    private func calculateSpeed(currentBytes: Int64) -> Double {
        let now = Date()
        speedSamples.append((time: now, bytes: currentBytes))

        // Remove samples outside the sliding window
        let cutoff = now.addingTimeInterval(-speedWindowDuration)
        speedSamples.removeAll { $0.time < cutoff }

        guard let oldest = speedSamples.first,
              speedSamples.count > 1 else {
            return 0
        }

        let elapsed = now.timeIntervalSince(oldest.time)
        guard elapsed > 0 else { return 0 }

        let bytesInWindow = currentBytes - oldest.bytes
        let bytesPerSecond = Double(bytesInWindow) / elapsed
        let megabytesPerSecond = bytesPerSecond / (1024.0 * 1024.0)
        return megabytesPerSecond
    }

    // MARK: - URLSessionDownloadDelegate

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {

        let now = Date()
        guard now.timeIntervalSince(lastCallbackTime) >= callbackInterval else { return }
        lastCallbackTime = now

        let progress: Double
        if totalBytesExpectedToWrite > 0 {
            progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        } else {
            progress = 0
        }

        let speed = calculateSpeed(currentBytes: totalBytesWritten)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.downloader(self,
                                      didUpdateProgress: progress,
                                      speed: speed,
                                      downloadedBytes: totalBytesWritten,
                                      totalBytes: totalBytesExpectedToWrite)
        }
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {

        let fileManager = FileManager.default
        do {
            let appSupportDir = try fileManager.url(for: .applicationSupportDirectory,
                                                     in: .userDomainMask,
                                                     appropriateFor: nil,
                                                     create: true)
            let tempDestination = appSupportDir.appendingPathComponent("aimodel_download_temp.zip")

            if fileManager.fileExists(atPath: tempDestination.path) {
                try fileManager.removeItem(at: tempDestination)
            }
            try fileManager.moveItem(at: location, to: tempDestination)

            cleanUpResumeDataFile()

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.downloader(self, didFinishDownloadingTo: tempDestination)
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.downloader(self, didFailWithError: error)
            }
        }
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {

        guard let error = error else { return }

        let nsError = error as NSError
        if let data = nsError.userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
            resumeData = data
            saveResumeDataToDisk()
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.downloader(self, didFailWithError: error)
        }
    }

    // MARK: - Background Session Handling

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async { [weak self] in
            self?.backgroundCompletionHandler?()
            self?.backgroundCompletionHandler = nil
        }
    }
}
