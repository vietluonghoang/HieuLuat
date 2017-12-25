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
    let nd46Id = "2"
    let qc41Id = "1"
    let tt01Id = "3"
    let lgtId = "4"
    let lxlvphcId = "5"
    
//    static var mucphatRange: [String] {
//        get{
//            return self.mucphatRange
//        }
//        set(v){
//            self.mucphatRange = v;
//        }
//    }
//    
//    static var nd46Id: String {
//        get{
//            return self.nd46Id
//        }
//        set(v){
//            self.nd46Id = v;
//        }
//    }
//    
//    static var qc41Id: String {
//        get{
//            return self.qc41Id
//        }
//        set(v){
//            self.qc41Id = v;
//        }
//    }
//    static var tt01Id: String {
//        get{
//            return self.tt01Id
//        }
//        set(v){
//            self.tt01Id = v;
//        }
//    }
//    static var lgtId: String {
//        get{
//            return self.lgtId
//        }
//        set(v){
//            self.lgtId = v;
//        }
//    }
//    static var lxlvphcId: String {
//        get{
//            return self.lxlvphcId
//        }
//        set(v){
//            self.lxlvphcId = v;
//        }
//    }
    
    func getMucphatRange() -> [String] {
        return mucphatRange
    }
    func getND46ID() -> String {
        return nd46Id
    }
    func getTT01ID() -> String {
        return tt01Id
    }
    func getLGTID() -> String {
        return lgtId
    }
    func getLXLVPHCID() -> String {
        return lxlvphcId
    }
    func getQC41ID() -> String {
        return qc41Id
    }
    
    func getRecordCapByRam(ram: UInt64) -> Int16 {
        if ram <= 1 {
            return 250
        }
        if ram <= 2 {
            return 500
        }
        if ram <= 3 {
            return 750
        }
        if ram <= 4 {
            return 1000
        }
        
        //no cap if more than 4GB RAM
        return 0
    }
}
