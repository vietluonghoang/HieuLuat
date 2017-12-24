//
//  SearchFor.swift
//  HieuLuat
//
//  Created by VietLH on 8/26/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import Foundation

class SearchFor {
    func regexSearch(pattern:String, searchIn:String) -> [String] {
        do {
            let input = searchIn.lowercased()
            
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
            let nsString = input as NSString
            
            return matches.map{ nsString.substring(with: $0.range)}
        } catch {
            print("Error with RegEx")
            return [""]
        }
    }
    
    func isStringExisted(str:String, strArr:[String]) -> Bool {
        
        for key in strArr {
            if key == str {
                return true
            }
        }
        return false
    }
    
    func getAncestersID(dieukhoan:Dieukhoan, vanbanId: [String]) -> String {
        var ancesters = ""
        if DataConnection.database == nil {
            DataConnection.databaseSetup()
        }
        
        if dieukhoan.getCha() == 0 {
            ancesters = "\(dieukhoan.getId())"
        }else{
            ancesters = "\(dieukhoan.getCha())"
            var parents = Queries.searchDieukhoanByID(keyword: "\(dieukhoan.getCha())",vanbanid: vanbanId)
            while parents[0].getCha() != 0 {
                ancesters = "\(parents[0].getCha())-"+ancesters
                parents = Queries.searchDieukhoanByID(keyword: "\(parents[0].getCha())",vanbanid: vanbanId)
            }
            
        }
        return ancesters
    }
    
    func getAncesters(dieukhoan:Dieukhoan, vanbanId: [String]) -> [Dieukhoan] {
        var dk = dieukhoan
        var ancesters = [Dieukhoan]()
        if DataConnection.database == nil {
            DataConnection.databaseSetup()
        }
        while dk.getCha() != 0 {
            dk = Queries.searchDieukhoanByID(keyword: "\(dk.getCha())",vanbanid: vanbanId)[0]
            ancesters.append(dk)
        }
        return ancesters
    }
    
    func getAncestersNumber(dieukhoan:Dieukhoan, vanbanId: [String]) -> String {
        var ancesters = ""
        var dk = dieukhoan
        if DataConnection.database == nil {
            DataConnection.databaseSetup()
        }
        while dk.getCha() != 0 {
            let parent = Queries.searchDieukhoanByID(keyword: "\(dk.getCha())",vanbanid: vanbanId)[0]
            dk = parent
            ancesters += dk.getSo()+"/"
        }
        return ancesters
    }
    
    func getDieunay(currentDieukhoan: Dieukhoan, vanbanId: [String]) -> Dieukhoan {
        var trackingDieukhoan = currentDieukhoan
        while !trackingDieukhoan.getSo().lowercased().contains("điều") {
            if(trackingDieukhoan.getCha() != 0){
                trackingDieukhoan = Queries.searchDieukhoanByID(keyword: "\(trackingDieukhoan.getCha())",vanbanid: vanbanId)[0]
            }else{
                return trackingDieukhoan
            }
        }
        return trackingDieukhoan
    }
    
    func getKhoannay(currentDieukhoan: Dieukhoan, vanbanId: [String]) -> Dieukhoan {
        var trackingDieukhoan = currentDieukhoan
        var prevTrackingDieukhoan = currentDieukhoan
        while !trackingDieukhoan.getSo().lowercased().contains("điều") {
            prevTrackingDieukhoan = trackingDieukhoan
            if(trackingDieukhoan.getCha() != 0){
                trackingDieukhoan = Queries.searchDieukhoanByID(keyword: "\(trackingDieukhoan.getCha())",vanbanid: vanbanId)[0]
            }else{
                return prevTrackingDieukhoan
            }
        }
        return prevTrackingDieukhoan
    }
}
