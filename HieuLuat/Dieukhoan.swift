//
//  Dieukhoan.swift
//  HieuLuat
//
//  Created by VietLH on 8/26/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import Foundation

class Dieukhoan: NSObject {
    var id:Int64
    var so:String
    var tieude:String
    var noidung:String
    var minhhoa:[String]=[]
    var cha:Int64
    var vanban:Vanban
    var hinhphatbosung = ""
    var bienphapkhacphuc = ""
    var sortPoint: Int16 = 0
    
    //    init(id:Int64,so:String,tieude:String,noidung:String,minhhoa:[String],cha:Int64,vanbanid:Int64) {
    //        self.id=id
    //        self.so=so
    //        self.tieude=tieude
    //        self.noidung=noidung
    //        self.minhhoa=minhhoa
    //        self.cha=cha
    //        self.vanbanid=vanbanid
    //    }
    
    init(id:Int64,so:String,tieude:String,noidung:String,minhhoa:String,cha:Int64,vanban:Vanban) {
        self.id=id
        self.so=String(describing: so.trimmingCharacters(in: .whitespacesAndNewlines))
        self.tieude=String(describing: tieude.trimmingCharacters(in: .whitespacesAndNewlines))
        self.noidung=String(describing: noidung.trimmingCharacters(in: .whitespacesAndNewlines))
        self.cha=cha
        self.vanban=vanban
        for mh in minhhoa.components(separatedBy: ";") {
            self.minhhoa.append(String(describing: mh.trimmingCharacters(in: .whitespacesAndNewlines)))
        }
        self.sortPoint = 0
    }
    
    init(id:Int64,cha:Int64,vanban:Vanban) {
        self.id=id
        self.cha=cha
        self.vanban=vanban
        self.so=""
        self.tieude=""
        self.noidung=""
        self.sortPoint = 0
    }
    
    func getId() -> Int64 {
        return id
    }
    
    func setId(id:Int64) {
        self.id=id
    }
    
    func getSo() -> String {
        return so
    }
    
    func setSo(so:String) {
        self.so=String(describing: so.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func getTieude() -> String {
        return tieude
    }
    
    func setTieude(tieude:String) {
        self.tieude=String(describing: tieude.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func getNoidung() -> String {
        return noidung
    }
    
    func setNoidung(noidung:String) {
        self.noidung=String(describing: noidung.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func getHinhphatbosung() -> String {
        return hinhphatbosung
    }
    
    func setHinhphatbosung(hinhphatbosung:String) {
        self.hinhphatbosung=String(describing: hinhphatbosung.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func getBienphapkhacphuc() -> String {
        return bienphapkhacphuc
    }
    
    func setBienphapkhacphuc(bienphapkhacphuc:String) {
        self.bienphapkhacphuc=String(describing: bienphapkhacphuc.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func getMinhhoa() -> [String] {
        return minhhoa
    }
    
    func setMinhhoa(minhhoa:[String]) {
        self.minhhoa=minhhoa
    }
    
    func addMinhhoa(minhhoa:String) {
        self.minhhoa.append(String(describing: minhhoa.trimmingCharacters(in: .whitespacesAndNewlines)))
    }
    
    func getCha() -> Int64 {
        return cha
    }
    
    func setCha(cha:Int64) {
        self.cha=cha
    }
    
    func getVanban() -> Vanban {
        return vanban
    }
    
    func setVanban(vanban:Vanban) {
        self.vanban=vanban
    }
    
    func getSortPoint() -> Int16 {
        return sortPoint
    }
    
    func setSortPoint(sortPoint:Int16) {
        self.sortPoint=sortPoint
    }
}

