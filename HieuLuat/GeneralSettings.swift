//
//  GeneralSettings.swift
//  HieuLuat
//
//  Created by VietLH on 11/19/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import Foundation

class GeneralSettings {
    //get mucphatRange by using vanbanId
    private static let mucphatRangePerVanban = [6:["50.000","60.000","80.000","100.000","200.000","250.000","300.000","400.000","500.000","600.000","800.000","1.000.000","1.200.000","1.500.000","1.600.000","2.000.000","3.000.000","4.000.000","5.000.000","6.000.000","7.000.000","7.500.000","8.000.000","10.000.000","12.000.000","14.000.000","15.000.000","16.000.000","18.000.000","20.000.000","25.000.000","28.000.000","30.000.000","32.000.000","36.000.000","40.000.000","50.000.000","56.000.000","64.000.000","70.000.000","200.000.000"], 2:["50.000","60.000","80.000","100.000","120.000","200.000","300.000","400.000","500.000","600.000","800.000","1.000.000","1.200.000","500.000","1.600.000","2.000.000","2.500.000","3.000.000","4.000.000","5.000.000","6.000.000","7.000.000","8.000.000","10.000.000","12.000.000","14.000.000","15.000.000","16.000.000","18.000.000","20.000.000","25.000.000","28.000.000","30.000.000","32.000.000","36.000.000","37.500.000","40.000.000","50.000.000","52.500.000","56.000.000","64.000.000","70.000.000","75.000.000","80.000.000","150.000.000"]]
    
    //get tamgiuPhuongtienDieukhoanID by using vanbanId
    private static var tamgiuPhuongtienDieukhoanID = [6:"6592", 2:"2820"]
    
    //based data for Vanban
    private static var vanbanInfo = [Int64:Vanban]()
    private static var maxVanbanId = 0 //check if the maximum value of vanbanId
    
    //condition check for allowing multiple shape plate select
    private static var allowMultipleShapePlateSelect = false
    
    //These are links to partners
    private static var fbWeThoong = [URL(string: "fb://profile/224587561051762"),URL(string: "http://fb.me/wethoong")]
    private static var fbCongdonghieuluat = [URL(string: "fb://profile/2262780957320858"),URL(string: "https://www.facebook.com/groups/congdonghieuluat/")]
    private static var emailWeThoong = "wethoong@gmail.com"
    
    //    private static var currentDBVersion = 0
    private static var minimumAppVersion = "1.0"
    private static var enableInappNotif = false
    private static var enableBannerAds = false
    private static var enableInterstitialAds = false
    private static var minimumAdsInterval = 300 //in seconds
    private static var interstitialAdsOpenTime = 0
    
    //default timestamp for showing ads checking
    private static var lastAppOpenTimestamp = 0
    private static var lastInterstitialAdsOpenTimestamp = 0
    
    private static var defaultConnectionTries = 30
    private static var adsOptout = false //true means the user will not see Ads
    
    //these settings must be updated before making build
    private static var requiredDBVersion = 10
    private static var developementMode = true
    private static var defaultActiveQC41Id = 7 //this would be used for the search of querying the lastest road sign
    private static var defaultActiveNDXPId = 6 //this would be used for the search of querying the latest NDXP
    
    
    static var remainingConnectionTries: Int {
        get{
            return self.defaultConnectionTries
        }
        set(v){
            self.defaultConnectionTries = v;
        }
    }
    
    static var getActiveQC41Id: Int64 {
        get{
            return Int64(self.defaultActiveQC41Id)
        }
        set(v){
            self.defaultActiveQC41Id = Int(v);
        }
    }
    
    static var getActiveNDXPId: Int64 {
        get{
            return Int64(self.defaultActiveNDXPId)
        }
        set(v){
            self.defaultActiveNDXPId = Int(v);
        }
    }
    
    static var getVanbanIdMax: Int {
        get{
            return self.maxVanbanId
        }
        set(v){
            self.maxVanbanId = v;
        }
    }
    
    static var getRequiredDatabaseVersion: Int {
        get{
            return self.requiredDBVersion
        }
        set(v){
            self.requiredDBVersion = v;
        }
    }
    
    class func getMucphatRange(vanbanId: Int64) -> [String] {
        return mucphatRangePerVanban[Int(vanbanId)]!
    }
    
    static var isAllowMultipleShapePlateSelect: Bool {
        get{
            return self.allowMultipleShapePlateSelect
        }
        set(v){
            self.allowMultipleShapePlateSelect = v;
        }
    }
    
    class func getTamgiuPhuongtienParentID(vanbanId: Int64) -> String {
        if tamgiuPhuongtienDieukhoanID[Int(vanbanId)] == nil {
            return ""
        }
        return tamgiuPhuongtienDieukhoanID[Int(vanbanId)]!
    }
    
    static var isAdsOptout: Bool {
        get{
            if !self.adsOptout {
                //TODO: update optout state
            }
            return self.adsOptout
        }
        set(v){
            self.adsOptout = v;
        }
    }
    
    static var isDevMode: Bool {
        get{
            return self.developementMode
        }
        set(v){
            self.developementMode = v;
        }
    }
    
    static var getFBWethoongLink: [URL] {
        get{
            return self.fbWeThoong as! [URL]
        }
        set(v){
            self.fbWeThoong = v;
        }
    }
    
    static var getFBCongdonghieuluatLink: [URL] {
        get{
            return self.fbCongdonghieuluat as! [URL]
        }
        set(v){
            self.fbCongdonghieuluat = v;
        }
    }
    
    static var getFBLink: [URL]{
        get{
            let number = Int.random(in: 0 ... 1)
            switch number{
            case 0:
                return self.fbWeThoong as! [URL]
            case 1:
                return self.fbCongdonghieuluat as! [URL]
            default:
                return self.fbWeThoong as! [URL]
            }
        }
    }
    
    static var getEmailAddress: String {
        get{
            return self.emailWeThoong
        }
        set(v){
            self.emailWeThoong = v;
        }
    }
    
    class func getVanbanInfo(id: Int64, info: String) -> String{
        let vanban = vanbanInfo[id]
        
        if vanban != nil{
            switch (info.lowercased()){
            case "valid":
                return vanban!.getHieuluc()
            case "shortname":
                return vanban!.getTenRutgon()
            case "fullname":
                return vanban!.getTen()
            case "replace":
                return "\(vanban!.getVanbanThaytheId())"
            default:
                return ""
            }
        } else {
            return ""
        }
    }
    
    class func setVanbanInfo(vanbans: [Vanban]){
        maxVanbanId = 0
        for vb in vanbans {
            vanbanInfo[vb.getId()] = vb
            if vb.getId() > maxVanbanId {
                maxVanbanId = Int(vb.getId())
            }
        }
    }
    
    func getRecordCapByRam(ram: UInt64) -> Int16 {
        if ram <= 1 {
            return 300
        }
        if ram <= 2 {
            return 700
        }
        
        //no cap if more than 2GB RAM
        return 0
    }
    
    //app configuration
    static var minimumAppVersionRequired: String {
        get{
            return self.minimumAppVersion
        }
        set(v){
            self.minimumAppVersion = v;
        }
    }
    
    static var isEnableInappNotif: Bool {
        get{
            return self.enableInappNotif
        }
        set(v){
            self.enableInappNotif = v;
        }
    }
    
    static var isEnableBannerAds: Bool {
        get{
            return self.enableBannerAds
        }
        set(v){
            self.enableBannerAds = v;
        }
    }
    
    static var isEnableInterstitialAds: Bool {
        get{
            return self.enableInterstitialAds
        }
        set(v){
            self.enableInterstitialAds = v;
        }
    }
    
    static var minimumAdsIntervalInSeconds: Int {
        get{
            return self.minimumAdsInterval
        }
        set(v){
            self.minimumAdsInterval = v;
        }
    }
    
    static var getLastAppOpenTimestamp: Int {
        get{
            return self.lastAppOpenTimestamp
        }
        set(v){
            self.lastAppOpenTimestamp = v;
        }
    }
    
    static var getLastInterstitialAdsOpenTimestamp: Int {
        get{
            return self.lastInterstitialAdsOpenTimestamp
        }
        set(v){
            self.lastInterstitialAdsOpenTimestamp = v;
        }
    }
    
    static var getInterstitialAdsOpenTimes: Int {
        get{
            return self.interstitialAdsOpenTime
        }
        set(v){
            self.interstitialAdsOpenTime = v;
        }
    }
}
