//
//  Logger.swift
//  HieuLuat
//
//  Created by AI Assistant on 4/22/26.
//  Copyright © 2026 VietLH. All rights reserved.
//

import Foundation
import os.log

/// Centralized logging system for the entire application
class Logger {
    
    enum LogLevel {
        case debug
        case info
        case warning
        case error
        case critical
        
        var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            case .critical: return .fault
            }
        }
    }
    
    enum Category: String {
        case database = "Database"
        case aiModel = "AIModel"
        case inference = "Inference"
        case network = "Network"
        case ui = "UI"
        case analytics = "Analytics"
        case search = "Search"
        case general = "General"
    }
    
    private static let subsystem = "com.hieuluat.app"
    
    private static func createLog(category: Category) -> OSLog {
        return OSLog(subsystem: subsystem, category: category.rawValue)
    }
    
    // MARK: - Logging Methods
    
    static func log(_ message: String,
                    level: LogLevel = .info,
                    category: Category = .general,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line) {
        let log = createLog(category: category)
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let prefix = "[\(fileName):\(line) \(function)]"
        
        #if DEBUG
        let debugMessage = "\(prefix) \(message)"
        os_log("%{public}@", log: log, type: level.osLogType, debugMessage)
        print("[\(category.rawValue)][\(level)] \(debugMessage)")
        #else
        os_log("%{public}@", log: log, type: level.osLogType, message)
        #endif
    }
    
    // MARK: - Convenience Methods
    
    static func debug(_ message: String,
                      category: Category = .general,
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
        log(message, level: .debug, category: category, file: file, function: function, line: line)
    }
    
    static func info(_ message: String,
                     category: Category = .general,
                     file: String = #file,
                     function: String = #function,
                     line: Int = #line) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }
    
    static func warning(_ message: String,
                        category: Category = .general,
                        file: String = #file,
                        function: String = #function,
                        line: Int = #line) {
        log(message, level: .warning, category: category, file: file, function: function, line: line)
    }
    
    static func error(_ message: String,
                      error: Error? = nil,
                      category: Category = .general,
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
        let fullMessage = error.map { "\(message) - \($0.localizedDescription)" } ?? message
        log(fullMessage, level: .error, category: category, file: file, function: function, line: line)
    }
    
    static func critical(_ message: String,
                         error: Error? = nil,
                         category: Category = .general,
                         file: String = #file,
                         function: String = #function,
                         line: Int = #line) {
        let fullMessage = error.map { "\(message) - \($0.localizedDescription)" } ?? message
        log(fullMessage, level: .critical, category: category, file: file, function: function, line: line)
    }
}
