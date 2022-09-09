//
//  AnalyticsHelper.swift
//  HieuLuat
//
//  Created by VietLH on 8/26/22.
//  Copyright © 2022 VietLH. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import AppTrackingTransparency
import AdSupport
import FirebaseInstallations

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
        print("+++ Sending analytics to Firebase.....")
        var parsingParams = [String:String]()
        if (!idForVendor.isEmpty) {
            parsingParams["idforvendor"] = idForVendor
        }
        parsingParams["dbVersion"] = "\(dbVersion)"
        if (!adsId.isEmpty) {
            parsingParams["adsid"] = adsId
        }
        
        var payload = "\(eventName) &/idforvendor*\(idForVendor)//adsid*\(adsId)//dbVersion*\(parsingParams["dbVersion"]!)/"
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
    class func updateAdsId(adsId: String){
        self.adsId = adsId
    }
    
    class func generateIdForVendor() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    class func getIdForVendor() -> String {
        return self.idForVendor
    }
    class func getAdsId() -> String{
        return self.adsId
    }
    //NEWLY ADDED PERMISSIONS FOR iOS 14
    class func requestPermission() {
        //update id for vender
        updateIdForVendor(id: generateIdForVendor())
        
        //request to access ads id. In the case if the user denies to grant the access, we'll use Firebase installation id
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // Tracking authorization dialog was shown
                    // and we are authorized
                    print("Authorized")
                    
                    // Now that we are authorized we can get the IDFA
                    print("Updating ads id: \(ASIdentifierManager.shared().advertisingIdentifier)")
                    self.updateAdsId(adsId: ASIdentifierManager.shared().advertisingIdentifier.uuidString)
                case .denied:
                    // Tracking authorization dialog was
                    // shown and permission is denied
                    print("Denied")
                    getFireBaseInstallationId()
                case .notDetermined:
                    // Tracking authorization dialog has not been shown
                    print("Not Determined")
                    getFireBaseInstallationId()
                case .restricted:
                    print("Restricted")
                    getFireBaseInstallationId()
                @unknown default:
                    print("Unknown")
                    getFireBaseInstallationId()
                }
            }
        }else{
            updateAdsId(adsId: ASIdentifierManager.shared().advertisingIdentifier.uuidString)
        }
    }
    
    class func getFireBaseInstallationId(){
        //if ads tracking is not enable, use Firebase Installation id instead
        Installations.installations().installationID { [self] (id, error) in
            if let error = error {
                print("Error fetching id: \(error)\nAssigning defaultID.....")
                self.updateAdsId(adsId: "undefinedID") //assigning "undefinedID" to adsID to avoid leaving it blank
                return
            }
            guard let aId = id else { return }
            print("Installation ID: \(aId)")
            //once the installation id is set, update it to adsID
            self.updateAdsId(adsId: aId)
        }
    }
}
