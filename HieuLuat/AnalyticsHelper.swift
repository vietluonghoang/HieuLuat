//
//  AnalyticsHelper.swift
//  HieuLuat
//
//  Created by VietLH on 8/26/22.
//  Copyright © 2022 VietLH. All rights reserved.
//

import Foundation
import FirebaseAnalytics

class AnalyticsHelper{
    
    private static var idForVendor = ""
    private static var adsId = ""
    private static var dbVersion = 0
    public static let SCREEN_NAME_TRACUUVANBAN = "TracuuVanban"
    public static let SCREEN_NAME_TRACUUMUCPHAT = "TracuuMucphat"
    public static let SCREEN_NAME_TRACUUBIENBAO = "TracuuBienbao"
    public static let SCREEN_NAME_TRACUUVACHKEDUONG = "TracuuVachkeduong"
    public static let SCREEN_NAME_HUONGDANLUAT = "Huongdanluat"
    public static let SCREEN_NAME_CHUNGTOI = "AboutUs"
    public static let SCREEN_NAME_UNDERCONSTRUCTION = "Underconstruction"
    public static let SCREEN_NAME_UPDATEVERSION = "UpdateVersion"
    
    //these parameters are cross-updated by DeviceInfoCollector. Always make sure that it runs first before sending any analytics event
    
    class func sendAnalyticEvent(eventName: String, params: [String: String]) {
        var parsingParams = [String:String]()
        if (!idForVendor.isEmpty) {
            parsingParams["idforvendor"] = idForVendor
        }
        parsingParams["dbVersion"] = "\(dbVersion)"
        if (!adsId.isEmpty) {
            parsingParams["adsid"] = adsId
        }
        
        var payload = "\(eventName) &/idforvendor*\(parsingParams["idforvendor"]!)//adsid*\(String(describing: parsingParams["adsid"]!))//dbVersion*\(parsingParams["dbVersion"]!)/"
        if (!params.isEmpty) {
            for (key, value) in params{
                payload += "/" + key + "*" + value + "/"
                parsingParams[key] = value
            }
        }
        Analytics.logEvent(eventName, parameters: parsingParams)
        print("+++++ analytics tracking sent: " + payload);
    }
    
    class func updateDatabaseVersion(versionNumber: Int){
        dbVersion = versionNumber
    }
    class func updateIdForVendor(id: String){
        idForVendor = id
    }
    class func updateAdsId(aId: String){
        adsId = aId
    }
}
