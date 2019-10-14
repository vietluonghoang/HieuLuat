//
//  GeneralSettings.swift
//  HieuLuat
//
//  Created by VietLH on 11/19/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import Foundation

class GeneralSettings {
    let mucphatRange = ["50.000","60.000","80.000","100.000","120.000","200.000","300.000","400.000","500.000","600.000","800.000","1.000.000","1.200.000","500.000","1.600.000","2.000.000","2.500.000","3.000.000","4.000.000","5.000.000","6.000.000","7.000.000","8.000.000","10.000.000","12.000.000","14.000.000","15.000.000","16.000.000","18.000.000","20.000.000","25.000.000","28.000.000","30.000.000","32.000.000","36.000.000","37.500.000","40.000.000","50.000.000","52.500.000","56.000.000","64.000.000","70.000.000","75.000.000","80.000.000","150.000.000"]
    private static var nd46Id = "2"
    private static var qc41Id = "1"
    private static var tt01Id = "3"
    private static var lgtId = "4"
    private static var lxlvphcId = "5"
    let danhsachvanban  = ["nd46","qc41","tt01","lgtdb","lxlvphc"]
    private static var vanbanInfo = [String:[String:String]]()
    private static var tamgiuPhuongtienDieukhoanID = "2820"
    private static var allowMultipleShapePlateSelect = false
    private static var fbWeThoong = [URL(string: "fb://profile/224587561051762"),URL(string: "http://fb.me/wethoong")]
    private static var fbCongdonghieuluat = [URL(string: "fb://profile/2262780957320858"),URL(string: "https://www.facebook.com/groups/congdonghieuluat/")]
    private static var emailWeThoong = "wethoong@gmail.com"
    
    private static var minimumAppVersion = "1.0"
    private static var enableInappNotif = false
    private static var enableBannerAds = false
    private static var enableInterstitialAds = false
    private static var minimumAdsInterval = 300 //in seconds
    private static var interstitialAdsOpenTime = 0
    
    private static var lastAppOpenTimestamp = 0
    private static var lastInterstitialAdsOpenTimestamp = 0
    
    private static var dbVersion = 3
    private static var adEnabled = true
    private static var developementMode = true
    
    //    static var mucphatRange: [String] {
    //        get{
    //            return self.mucphatRange
    //        }
    //        set(v){
    //            self.mucphatRange = v;
    //        }
    //    }
    //
    
    static var getDatabaseVersion: Int {
        get{
            return self.dbVersion
        }
        set(v){
            self.dbVersion = v;
        }
    }
    
    static var getNd46Id: String {
        get{
            return self.nd46Id
        }
        set(v){
            self.nd46Id = v;
        }
    }
    
    static var getQc41Id: String {
        get{
            return self.qc41Id
        }
        set(v){
            self.qc41Id = v;
        }
    }
    static var getTt01Id: String {
        get{
            return self.tt01Id
        }
        set(v){
            self.tt01Id = v;
        }
    }
    static var getLgtId: String {
        get{
            return self.lgtId
        }
        set(v){
            self.lgtId = v;
        }
    }
    static var getLxlvphcId: String {
        get{
            return self.lxlvphcId
        }
        set(v){
            self.lxlvphcId = v;
        }
    }
    
    func getMucphatRange() -> [String] {
        return mucphatRange
    }
    
    static var isAllowMultipleShapePlateSelect: Bool {
        get{
            return self.allowMultipleShapePlateSelect
        }
        set(v){
            self.allowMultipleShapePlateSelect = v;
        }
    }
    
    static var tamgiuPhuongtienParentID: String {
        get{
            return self.tamgiuPhuongtienDieukhoanID
        }
        set(v){
            self.tamgiuPhuongtienDieukhoanID = v;
        }
    }
    
    static var isAdEnabled: Bool {
        get{
            return self.adEnabled
        }
        set(v){
            self.adEnabled = v;
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
    
    class func getVanbanInfo(name: String, info: String) -> String{
        var value = vanbanInfo[name]
        
        if value == nil{
            var vbInfo = [String:String]()
            switch (name.lowercased()){
            case "nd46":
                vbInfo["id"] = nd46Id
                vbInfo["fullName"] = "Nghị định 46 - 2016"
                break;
            case "qc41":
                vbInfo["id"] = qc41Id
                vbInfo["fullName"] = "Quy chuẩn 41 - 2016"
                break;
            case "tt01":
                vbInfo["id"] = tt01Id
                vbInfo["fullName"] = "Thông tư 01 - 2016"
                break;
            case "lgtdb":
                vbInfo["id"] = lgtId
                vbInfo["fullName"] = "Luật giao thông 2008"
                break;
            case "lxlvphc":
                vbInfo["id"] = lxlvphcId
                vbInfo["fullName"] = "Luật xử lý vi phạm hành chính 2012"
                break;
            default:
                break;
            }
            vanbanInfo[name] = vbInfo
            return vanbanInfo[name]![info]!
        } else {
            return value![info]!
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
