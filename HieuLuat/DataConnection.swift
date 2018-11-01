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
    static let databaseVersion = 3
    static var isDatabaseUpdated = false
    static var database: FMDatabase? = nil
    class func databaseSetup() {
        if database == nil {
            let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let dpPath = docsDir.appendingPathComponent("Hieuluat.sqlite")
            let file = FileManager.default
            if(!file.fileExists(atPath: dpPath.path)) {
                copyDatabase(file: file, dpPath: dpPath)
                database = FMDatabase(path: dpPath.path)
                do {
                    database!.open()
                    try database!.executeUpdate("PRAGMA user_version = \(databaseVersion)", values: nil)
                    database!.close()
                    isDatabaseUpdated = true
                }catch {
                    print("Error on updating user_version")
                }
            }else {
                database = FMDatabase(path: dpPath.path)
                if !isDatabaseUpdated {
                    var currentVersion = 0
                    do {
                        database!.open()
                        let resultSet: FMResultSet! = try database!.executeQuery("pragma user_version", values: nil)
                        while resultSet.next() {
                            currentVersion = Int(resultSet.int(forColumn: "user_version"))
                        }
                        database!.close()
                    }catch {
                        print("Error on getting user_version")
                    }
                    
                    if databaseVersion > currentVersion {
                        do {
                            try file.removeItem(at: dpPath)
                        }catch {
                            print("Error on getting user_version")
                        }
                        copyDatabase(file: file, dpPath: dpPath)
                        database = FMDatabase(path: dpPath.path)
                        do {
                            database!.open()
                            try database!.executeUpdate("PRAGMA user_version = \(databaseVersion)", values: nil)
                            database!.close()
                            isDatabaseUpdated = true
                        }catch {
                            print("Error on updating user_version")
                        }
                    }else {
                        isDatabaseUpdated = true
                    }
                }
            }
        }
    }
    
    private class func copyDatabase(file: FileManager, dpPath: URL){
        let dpPathApp = Bundle.main.path(forResource: "Hieuluat", ofType: "sqlite")
        print("resPath: "+String(describing: dpPathApp))
        do {
            try file.copyItem(atPath: dpPathApp!, toPath: dpPath.path)
            print("copyItemAtPath success")
        } catch {
            print("copyItemAtPath fail")
        }
    }
    
}
