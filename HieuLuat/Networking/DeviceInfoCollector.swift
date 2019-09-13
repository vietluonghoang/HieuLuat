//
//  DeviceInfoCollector.swift
//  HieuLuat
//
//  Created by VietLH on 9/12/19.
//  Copyright © 2019 VietLH. All rights reserved.
//

import Foundation
import UIKit

class DeviceInfoCollector {
    var idForVendor = ""
    var adsId = ""
    var deviceName = ""
    var osName = "iOS"
    var osVersion = ""
    var appVersion = ""
    var appVersionNumber = ""
    
    private func getIdForVendor() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    private func getDeviceName() -> String {
        return UIDevice.current.model
    }
    
    private func getOSVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    private func getAppVersion() -> String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    private func getAppVersionNumber() -> String {
        return Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    }
    
    func getDeviceInfo() -> [String:String] {
        var info = [String:String]()
        info["idforvendor"] = getIdForVendor()
        info["adsid"] = getIdForVendor() //not sure if it's correct
        info["devicename"] = getDeviceName()
        info["osname"] = osName
        info["osversion"] = getOSVersion()
        info["appversion"] = getAppVersion()
        info["appversionnumber"] = getAppVersionNumber()
        
        return info
    }
}
