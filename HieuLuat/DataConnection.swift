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
    private static let databaseVersion = GeneralSettings.getDatabaseVersion
    private static var database: FMDatabase? = nil
    private static var isInitializing = false
    
    class func instance() -> FMDatabase {
        if database == nil {
            DataConnection.initDataConnection()
        }
        return database!
    }
    
    private class func initDataConnection() {
        if isInitializing {
            print("------- database is in the progress of initializing ------")
            return
        }else{
            isInitializing = true
        }
        
        print("=========================================================\n------- Starting the progress of initializing database ------\n=========================================================")
        let file = FileManager.default
        if !isDatabaseFileExisted(){
            copyDatabase(destinationPath: getDatabaseFileSourcePath())
        } else {
            if databaseVersion > getCurrentDBVersion() {
                print("===== Database file is outdated")
                do {
                    print("===== Removing old database file")
                    try file.removeItem(at: URL(fileURLWithPath: getDatabaseFileSourcePath()))
                }catch {
                    print("######## Error on removing old database: \(error.localizedDescription)")
                }
                copyDatabase(destinationPath: getDatabaseFileSourcePath())
                
            }else {
                print("===== Database file is up to date")
            }
        }
        
        database = FMDatabase(path: getDatabaseFileSourcePath())
        updateDatabaseVersion(db: database!, newVersion: databaseVersion)
        isInitializing = false
        print("=========================================================\n------- Finishing the progress of initializing database ------\n=========================================================")
    }
    
    class func forceInitializeDatabase(){
        isInitializing = true
        print("=========================================================\n------- Forcing the progress of initializing database ------\n=========================================================")
        let file = FileManager.default
        do {
            print("===== Removing old database file")
            try file.removeItem(at: URL(string: getDatabaseFileSourcePath())!)
        }catch {
            print("######## Error on removing old database")
        }
        database = FMDatabase(path: getDatabaseFileSourcePath())
        updateDatabaseVersion(db: database!, newVersion: databaseVersion)
        isInitializing = false
        print("=========================================================\n------- Finished forcing the progress of initializing database ------\n=========================================================")
    }
    
    private class func copyDatabase(destinationPath: String){
        let file = FileManager.default
        print("===== Copying Database file")
        let dpPathApp = Bundle.main.path(forResource: "Hieuluat", ofType: "sqlite")
        print("+++resPath: \(dpPathApp ?? "failed to get path")")
        do {
            try file.copyItem(atPath: dpPathApp!, toPath: destinationPath)
            print("+++copyItemAtPath success")
        } catch {
            print("######## copyItemAtPath fail")
        }
    }
    
    private class func isDatabaseFileExisted() -> Bool {
        let file = FileManager.default
        if(!file.fileExists(atPath: getDatabaseFileSourcePath())) {
            print("===== Database file doest not exist")
            return false
        }else{
            print("===== Database file already existed")
            return true
        }
    }
    
    private class func getDatabaseFileSourcePath() -> String {
        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dbFileInDocumentPath = docsDir.appendingPathComponent("Hieuluat.sqlite")
        return dbFileInDocumentPath.path
    }
    
    private class func getCurrentDBVersion() -> Int {
        let db = FMDatabase(path: getDatabaseFileSourcePath())
        var currentVersion = 0
        do {
            print("===== Getting current Database version")
            db.open()
            let resultSet: FMResultSet! = try db.executeQuery("pragma user_version", values: nil)
            while resultSet.next() {
                currentVersion = Int(resultSet.int(forColumn: "user_version"))
            }
            db.close()
        }catch {
            print("######## Error on getting user_version")
        }
        return currentVersion
    }
    
    private class func updateDatabaseVersion (db: FMDatabase, newVersion: Int){
        do{
            db.open()
            try database!.executeUpdate("PRAGMA user_version = \(newVersion)", values: nil)
            db.close()
        }catch {
            print("######## Error on updating user_version")
        }
    }
}
