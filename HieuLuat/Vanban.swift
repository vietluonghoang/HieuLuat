//
//  Vanban.swift
//  HieuLuat
//
//  Created by VietLH on 8/26/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import Foundation

class Vanban: NSObject {
    var id:Int64
    var ten:String
    var loai:Loaivanban
    var so:String
    var nam:String
    var ma:String
    var coquanbanhanh:Coquanbanhanh
    var noidung:String
    var tenRutgon: String
    var hieuluc: String
    var vanbanThaytheId: Int64
    
    
    
    init(id:Int64,ten:String,loai:Loaivanban,so:String,nam:String,ma:String,coquanbanhanh:Coquanbanhanh,noidung:String, hieuluc: String, vanbanThaytheId: Int64, tenRutgon: String) {
        self.id=id
        self.ten=String(describing: ten.trimmingCharacters(in: .whitespacesAndNewlines))
        self.loai=loai
        self.so=String(describing: so.trimmingCharacters(in: .whitespacesAndNewlines))
        self.nam=String(describing: nam.trimmingCharacters(in: .whitespacesAndNewlines))
        self.ma=String(describing: ma.trimmingCharacters(in: .whitespacesAndNewlines))
        self.coquanbanhanh=coquanbanhanh
        self.noidung=String(describing: noidung.trimmingCharacters(in: .whitespacesAndNewlines))
        self.hieuluc = String(describing: hieuluc.trimmingCharacters(in: .whitespacesAndNewlines))
        self.tenRutgon = String(describing: tenRutgon.trimmingCharacters(in: .whitespacesAndNewlines))
        self.vanbanThaytheId = vanbanThaytheId
    }
    
    init(id:Int64,ten:String,loai:Loaivanban,so:String,nam:String,ma:String,coquanbanhanh:Coquanbanhanh,noidung:String) {
        self.id=id
        self.ten=String(describing: ten.trimmingCharacters(in: .whitespacesAndNewlines))
        self.loai=loai
        self.so=String(describing: so.trimmingCharacters(in: .whitespacesAndNewlines))
        self.nam=String(describing: nam.trimmingCharacters(in: .whitespacesAndNewlines))
        self.ma=String(describing: ma.trimmingCharacters(in: .whitespacesAndNewlines))
        self.coquanbanhanh=coquanbanhanh
        self.noidung=String(describing: noidung.trimmingCharacters(in: .whitespacesAndNewlines))
        self.hieuluc = ""
        self.tenRutgon = ""
        self.vanbanThaytheId = 0
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
    
    func getTen() -> String {
        return ten
    }
    
    func setTen(ten:String) {
        self.ten=String(describing: ten.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func getNoidung() -> String {
        return noidung
    }
    
    func setNoidung(noidung:String) {
        self.noidung=String(describing: noidung.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func getNam() -> String {
        return nam
    }
    
    func setNam(nam:String) {
        self.nam=String(describing: nam.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func getLoai() -> Loaivanban {
        return loai
    }
    
    func setLoai(loai:Loaivanban) {
        self.loai=loai
    }
    
    func getCoquanbanhanh() -> Coquanbanhanh {
        return coquanbanhanh
    }
    
    func setCoquanbanhanh(coquanbanhanh:Coquanbanhanh) {
        self.coquanbanhanh=coquanbanhanh
    }
    
    func getMa() -> String {
        return ma
    }
    
    func setma(ma:String) {
        self.ma=String(describing: ma.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func getHieuluc() -> String {
        return hieuluc
    }
    
    func setHieuluc(hieuluc:String) {
        self.hieuluc = String(describing: hieuluc.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func getTenRutgon() -> String {
        return tenRutgon
    }
    
    func setTenRutgon(tenRutgon:String) {
        self.tenRutgon = String(describing: tenRutgon.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func getVanbanThaytheId() -> Int64 {
        return vanbanThaytheId
    }
    
    func setVanbanThaytheId(vanbanThaytheId:Int64) {
        self.vanbanThaytheId = vanbanThaytheId
    }
}
