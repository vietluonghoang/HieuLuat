//
//  AIModelUnzipper.swift
//  HieuLuat
//
//  Created by AI Assistant on 3/27/26.
//  Copyright © 2026 VietLH. All rights reserved.
//

import Foundation
import ZIPFoundation

protocol AIModelUnzipperDelegate: AnyObject {
    func unzipper(_ unzipper: AIModelUnzipper, didUpdateProgress progress: Double)
    func unzipper(_ unzipper: AIModelUnzipper, didFinishUnzippingTo destination: URL)
    func unzipper(_ unzipper: AIModelUnzipper, didFailWithError error: Error)
}

class AIModelUnzipper {
    
    enum UnzipError: LocalizedError {
        case fileNotFound(URL)
        case corruptedZip
        case diskFull
        case missingModelFiles([String])
        
        var errorDescription: String? {
            switch self {
            case .fileNotFound(let url):
                return "Zip file not found at: \(url.path)"
            case .corruptedZip:
                return "The zip file is corrupted and cannot be extracted."
            case .diskFull:
                return "Not enough disk space to extract the model files."
            case .missingModelFiles(let files):
                return "Missing model files after extraction: \(files.joined(separator: ", "))"
            }
        }
    }
    
    weak var delegate: AIModelUnzipperDelegate?
    
    // MARK: - Public
    
    /// Unzips the file at `source` into `destination` on a background queue.
    /// Progress and completion are reported on the main thread via the delegate.
    func unzip(fileAt source: URL, to destination: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            guard FileManager.default.fileExists(atPath: source.path) else {
                self.notifyError(UnzipError.fileNotFound(source))
                return
            }
            
            do {
                // Create destination directory if needed
                try FileManager.default.createDirectory(at: destination,
                                                        withIntermediateDirectories: true)
                
                // Unzip with progress tracking
                let progress = Progress()
                let observation = progress.observe(\.fractionCompleted) { [weak self] prog, _ in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.delegate?.unzipper(self, didUpdateProgress: prog.fractionCompleted)
                    }
                }
                
                try FileManager.default.unzipItem(at: source, to: destination, progress: progress)
                
                observation.invalidate()
                
                // Verify meta.yaml exists and all model files it references are present
                let missingFiles = self.verifyModelFiles(in: destination)
                if !missingFiles.isEmpty {
                    throw UnzipError.missingModelFiles(missingFiles)
                }
                
                // Delete the source zip file
                try FileManager.default.removeItem(at: source)
                
                DispatchQueue.main.async {
                    self.delegate?.unzipper(self, didFinishUnzippingTo: destination)
                }
                
            } catch let error as NSError where error.domain == NSCocoaErrorDomain
                        && error.code == NSFileWriteOutOfSpaceError {
                self.notifyError(UnzipError.diskFull)
            } catch let error as NSError where error.domain == NSCocoaErrorDomain
                        && error.code == NSFileReadCorruptFileError {
                self.notifyError(UnzipError.corruptedZip)
            } catch is Archive.ArchiveError {
                self.notifyError(UnzipError.corruptedZip)
            } catch {
                self.notifyError(error)
            }
        }
    }
    
    // MARK: - Private
    
    private func verifyModelFiles(in directory: URL) -> [String] {
        let fileManager = FileManager.default
        
        // First, check that meta.yaml exists
        let metaURL = directory.appendingPathComponent("meta.yaml")
        guard fileManager.fileExists(atPath: metaURL.path),
              let config = AIModelConfig.load(from: metaURL) else {
            return ["meta.yaml"]
        }
        
        // Verify all model files listed in meta.yaml
        var missing: [String] = []
        for fileName in config.allModelFileNames {
            let filePath = directory.appendingPathComponent(fileName)
            if !fileManager.fileExists(atPath: filePath.path) {
                missing.append(fileName)
            }
        }
        
        return missing
    }
    
    private func notifyError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.unzipper(self, didFailWithError: error)
        }
    }
}
