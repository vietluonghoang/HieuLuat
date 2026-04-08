//
//  DataConnection.swift
//  HieuLuat
//
//  Created by VietLH on 8/26/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit
import FMDB

class DataConnection: NSObject {
    // Before using instance(), you should call init()
    class func init() {
        loadAIModel()
    }
    private static let requiredDatabaseVersion = GeneralSettings.getRequiredDatabaseVersion
    private static var database: FMDatabase? = nil
    private static var isInitializing = false
    private static var currentVersion = 0
    private static var isReady = false

    class func instance() -> FMDatabase {
        // Load AI model
        loadAIModel()
        if !isReady {
            if database == nil || requiredDatabaseVersion > getCurrentDBVersion() {
                DataConnection.initDataConnection()
            }
            if database != nil {
                isReady = true
            }
        }
        if database != nil && !database!.isOpen {
            database!.open()
        }
        if database == nil {
            print("[DataConnection] ERROR: database is nil, creating new instance")
            database = FMDatabase(path: getDatabaseFileSourcePath())
            database!.open()
            isReady = true
        }
        return database!
    }
    
    private class func initDataConnection() {
        if isInitializing {
            return
        }
        isInitializing = true
        
        print("[DataConnection] Initializing database...")
        let file = FileManager.default
        if !isDatabaseFileExisted(){
            copyDatabase(destinationPath: getDatabaseFileSourcePath())
        } else {
            if requiredDatabaseVersion > getCurrentDBVersion() {
                print("[DataConnection] Database outdated (v\(getCurrentDBVersion()) < v\(requiredDatabaseVersion)), replacing...")
                do {
                    try file.removeItem(at: URL(fileURLWithPath: getDatabaseFileSourcePath()))
                    copyDatabase(destinationPath: getDatabaseFileSourcePath())
                }catch {
                    print("[DataConnection] Error removing old database: \(error.localizedDescription)")
                }
            }else {
                database = FMDatabase(path: getDatabaseFileSourcePath())
            }
        }
        isInitializing = false
        print("[DataConnection] Database ready (v\(getCurrentDBVersion()))")
    }
    
    class func forceInitializeDatabase(){
        isInitializing = true
        print("[DataConnection] Force initializing database...")
        let file = FileManager.default
        do {
            try file.removeItem(at: URL(fileURLWithPath: getDatabaseFileSourcePath()))
            database = FMDatabase(path: getDatabaseFileSourcePath())
            updateDatabaseVersion(db: database!, newVersion: requiredDatabaseVersion)
            isInitializing = false
        }catch {
            print("[DataConnection] Error on force removing old database: \(error.localizedDescription)")
            isInitializing = false
        }
    }
    
    private class func copyDatabase(destinationPath: String){
        let file = FileManager.default
        let dpPathApp = Bundle.main.path(forResource: "Hieuluat", ofType: "sqlite")
        do {
            try file.copyItem(atPath: dpPathApp!, toPath: destinationPath)
            database = FMDatabase(path: getDatabaseFileSourcePath())
            updateDatabaseVersion(db: database!, newVersion: requiredDatabaseVersion)
        } catch {
            print("[DataConnection] Error copying database: \(error.localizedDescription)")
        }
    }
    
    private class func isDatabaseFileExisted() -> Bool {
        return FileManager.default.fileExists(atPath: getDatabaseFileSourcePath())
    }
    
    private class func getDatabaseFileSourcePath() -> String {
        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docsDir.appendingPathComponent("Hieuluat.sqlite").path
    }
    
    class func getCurrentDBVersion() -> Int {
        if currentVersion != 0 {
            return currentVersion
        } else {
            let db = FMDatabase(path: getDatabaseFileSourcePath())
            var curVersion = 0
            do {
                db.open()
                let resultSet: FMResultSet! = try db.executeQuery("pragma user_version", values: nil)
                while resultSet.next() {
                    curVersion = Int(resultSet.int(forColumn: "user_version"))
                    currentVersion = curVersion
                    AnalyticsHelper.updateDatabaseVersion(versionNumber: curVersion)
                }
                db.close()
            }catch {
                print("[DataConnection] Error getting user_version: \(error.localizedDescription)")
            }
            return curVersion
        }
        }
    }
    
    private class func updateDatabaseVersion (db: FMDatabase, newVersion: Int){
        do {
            try db.execute("PRAGMA user_version = \(newVersion)")
        }catch {
            print("[DataConnection] Error on update database version: \(error.localizedDescription)")
        }
    }
}

    private class func loadAIModel() {
        // Implement loading AI model using llama.cpp
        let aiModelPath = AppConfiguration.Configuration.aimodelpath.rawValue
        let value = Bundle.main.object(forInfoDictionaryKey: aiModelPath) as? String
        if let modelPath = value {
            // Load model using llama.cpp
            print("Loading AI model from \(modelPath)")
        } else {
            print("AI model path is not configured")
        }
        let aiModelPath = AppConfiguration.getString(forKey: .aimodelpath)
        if aiModelPath != nil {
            // Load model using llama.cpp
            print("Loading AI model from \(aiModelPath!)")
        } else {
            print("AI model path is not configured")
        }
    }
