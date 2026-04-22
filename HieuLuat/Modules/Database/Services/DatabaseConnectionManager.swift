//
//  DatabaseConnectionManager.swift
//  HieuLuat
//
//  Created by AI Assistant on 4/22/26.
//  Copyright © 2026 VietLH. All rights reserved.
//

import Foundation
import FMDB

// MARK: - Database Errors

enum DatabaseError: Error, LocalizedError {
    case connectionFailed(String)
    case queryFailed(String)
    case invalidDatabase
    case versionMismatch(current: Int, required: Int)
    case deletionFailed(String)
    case copyFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed(let msg):
            return "Failed to connect to database: \(msg)"
        case .queryFailed(let msg):
            return "Database query failed: \(msg)"
        case .invalidDatabase:
            return "Database file is invalid or corrupted"
        case .versionMismatch(let current, let required):
            return "Database version mismatch (current: \(current), required: \(required))"
        case .deletionFailed(let msg):
            return "Failed to delete database: \(msg)"
        case .copyFailed(let msg):
            return "Failed to copy database: \(msg)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .connectionFailed:
            return "Please restart the app and try again."
        case .queryFailed:
            return "The database may be corrupted. Try clearing app data."
        case .invalidDatabase:
            return "Please reinstall the application."
        case .versionMismatch:
            return "Updating database to latest version..."
        case .deletionFailed, .copyFailed:
            return "Please check storage permissions and try again."
        }
    }
}

// MARK: - Database Connection Manager

class DatabaseConnectionManager {
    
    static let shared = DatabaseConnectionManager()
    
    private let requiredDatabaseVersion = GeneralSettings.getRequiredDatabaseVersion
    private var database: FMDatabase?
    private var isInitializing = false
    private var currentVersion = 0
    private var isReady = false
    
    private let queue = DispatchQueue(label: "com.hieuluat.database", attributes: .concurrent)
    
    private init() {
        Logger.info("Database manager initialized", category: .database)
    }
    
    // MARK: - Public Methods
    
    /// Get or create database connection
    func getInstance() throws -> FMDatabase {
        var db: FMDatabase?
        
        queue.sync {
            db = self.database
        }
        
        if !isReady {
            do {
                try initializeDatabase()
            } catch {
                Logger.error("Failed to initialize database", error: error, category: .database)
                throw error
            }
            
            if database != nil {
                isReady = true
            }
        }
        
        if database == nil || !database!.isOpen {
            do {
                try openDatabase()
            } catch {
                Logger.error("Failed to open database", error: error, category: .database)
                throw error
            }
        }
        
        guard let database = database else {
            Logger.critical("Database is nil after initialization", category: .database)
            throw DatabaseError.invalidDatabase
        }
        
        return database
    }
    
    /// Reset database to factory state
    func resetDatabase() throws {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            do {
                Logger.info("Force initializing database...", category: .database)
                
                let filePath = self.getDatabasePath()
                let fileManager = FileManager.default
                
                if fileManager.fileExists(atPath: filePath) {
                    try fileManager.removeItem(atPath: filePath)
                    Logger.debug("Old database removed", category: .database)
                }
                
                self.database = FMDatabase(path: filePath)
                try self.copyDatabase(to: filePath)
                self.updateDatabaseVersion(newVersion: self.requiredDatabaseVersion)
                self.isReady = true
                
                Logger.info("Database reset completed", category: .database)
            } catch {
                Logger.error("Database reset failed", error: error, category: .database)
            }
        }
    }
    
    /// Get current database version
    func getCurrentVersion() -> Int {
        if currentVersion != 0 {
            return currentVersion
        }
        
        do {
            let filePath = getDatabasePath()
            let db = FMDatabase(path: filePath)
            
            defer { db.close() }
            
            guard db.open() else {
                Logger.error("Failed to open database for version check", category: .database)
                return 0
            }
            
            let resultSet = try db.executeQuery("pragma user_version", withArgumentsIn: [])
            
            if resultSet.next() {
                currentVersion = Int(resultSet.int(forColumn: "user_version"))
                Logger.debug("Current DB version: \(currentVersion)", category: .database)
            }
            
        } catch {
            Logger.error("Failed to get database version", error: error, category: .database)
        }
        
        return currentVersion
    }
    
    // MARK: - Private Methods
    
    private func initializeDatabase() throws {
        guard !isInitializing else {
            Logger.debug("Database already initializing, skipping", category: .database)
            return
        }
        
        isInitializing = true
        defer { isInitializing = false }
        
        let filePath = getDatabasePath()
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: filePath) {
            Logger.info("Database not found, copying from bundle...", category: .database)
            try copyDatabase(to: filePath)
        } else {
            let currentVersion = getCurrentVersion()
            if requiredDatabaseVersion > currentVersion {
                Logger.warning("Database outdated (v\(currentVersion) < v\(requiredDatabaseVersion)), replacing...", category: .database)
                
                do {
                    try fileManager.removeItem(atPath: filePath)
                    try copyDatabase(to: filePath)
                } catch {
                    Logger.error("Failed to update database", error: error, category: .database)
                    throw DatabaseError.copyFailed(error.localizedDescription)
                }
            } else {
                database = FMDatabase(path: filePath)
                Logger.debug("Database version OK", category: .database)
            }
        }
        
        Logger.info("Database initialization complete (v\(getCurrentVersion()))", category: .database)
    }
    
    private func openDatabase() throws {
        guard let db = database else {
            Logger.error("Attempt to open nil database", category: .database)
            throw DatabaseError.invalidDatabase
        }
        
        guard db.open() else {
            Logger.error("Failed to open database", category: .database)
            throw DatabaseError.connectionFailed("Database open failed")
        }
        
        Logger.debug("Database connection opened", category: .database)
    }
    
    private func copyDatabase(to destinationPath: String) throws {
        guard let bundlePath = Bundle.main.path(forResource: "Hieuluat", ofType: "sqlite") else {
            Logger.error("Database not found in bundle", category: .database)
            throw DatabaseError.copyFailed("Bundle database not found")
        }
        
        let fileManager = FileManager.default
        
        do {
            try fileManager.copyItem(atPath: bundlePath, toPath: destinationPath)
            database = FMDatabase(path: destinationPath)
            
            try openDatabase()
            updateDatabaseVersion(newVersion: requiredDatabaseVersion)
            
            Logger.info("Database copied from bundle to \(destinationPath)", category: .database)
        } catch {
            Logger.error("Failed to copy database from bundle", error: error, category: .database)
            throw DatabaseError.copyFailed(error.localizedDescription)
        }
    }
    
    private func updateDatabaseVersion(newVersion: Int) {
        currentVersion = newVersion
        Logger.debug("Database version updated to \(newVersion)", category: .database)
    }
    
    private func getDatabasePath() -> String {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent("Hieuluat.sqlite").path
    }
}

// MARK: - Safe Query Wrapper

extension DatabaseConnectionManager {
    
    /// Execute a safe query with error handling
    func executeQuery(
        _ sql: String,
        parameters: [Any]? = nil
    ) throws -> FMResultSet {
        let db = try getInstance()
        
        do {
            let resultSet = try db.executeQuery(sql, withArgumentsIn: parameters ?? [])
            Logger.debug("Query executed: \(sql)", category: .database)
            return resultSet
        } catch {
            Logger.error("Query execution failed: \(sql)", error: error, category: .database)
            throw DatabaseError.queryFailed(error.localizedDescription)
        }
    }
    
    /// Execute an update/insert/delete with error handling
    func executeUpdate(
        _ sql: String,
        parameters: [Any]? = nil
    ) throws {
        let db = try getInstance()
        
        do {
            try db.executeUpdate(sql, withArgumentsIn: parameters ?? [])
            Logger.debug("Update executed: \(sql)", category: .database)
        } catch {
            Logger.error("Update execution failed: \(sql)", error: error, category: .database)
            throw DatabaseError.queryFailed(error.localizedDescription)
        }
    }
}
