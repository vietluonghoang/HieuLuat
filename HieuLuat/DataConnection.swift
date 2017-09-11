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
    
    static var database: FMDatabase? = nil
    class func databaseSetup() {
        if database == nil {
            let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let dpPath = docsDir.appendingPathComponent("Hieuluat.sqlite")
            let file = FileManager.default
            if(!file.fileExists(atPath: dpPath.path)) {
                let dpPathApp = Bundle.main.path(forResource: "Hieuluat", ofType: "sqlite")
                print("resPath: "+String(describing: dpPathApp))
                do {
                    try file.copyItem(atPath: dpPathApp!, toPath: dpPath.path)
                    print("copyItemAtPath success")
                } catch {
                    print("copyItemAtPath fail")
                }
            }
            database = FMDatabase(path: dpPath.path)
        }
    }
    
    
}
