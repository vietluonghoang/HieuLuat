//
//  BosungKhacphuc.swift
//  HieuLuat
//
//  Created by VietLH on 1/2/18.
//  Copyright © 2018 VietLH. All rights reserved.
//

import Foundation
class BosungKhacphuc: NSObject {
    var dieukhoanLienquan: Dieukhoan
    var dieukhoanQuydinh: Dieukhoan
    var noidung: String
    
    init(dieukhoanLienquan: Dieukhoan, dieukhoanQuydinh: Dieukhoan, noidung: String) {
        self.dieukhoanLienquan = dieukhoanLienquan
        self.dieukhoanQuydinh = dieukhoanQuydinh
        self.noidung = noidung
    }
    
//    init(dieukhoanLienquanId: Int64, dieukhoanQuydinhId: Int64) {
//        
//    }
    
    func getDieukhoanLienquan() -> Dieukhoan {
        return self.dieukhoanLienquan
    }
    
    func setDieukhoanLienquan(dieukhoanLienquan: Dieukhoan) {
        self.dieukhoanLienquan = dieukhoanLienquan
    }
    
    func getDieukhoanQuydinh() -> Dieukhoan {
        return dieukhoanQuydinh
    }
    
    func setDieukhoanQuydinh(dieukhoanQuydinh: Dieukhoan) {
        self.dieukhoanQuydinh = dieukhoanQuydinh
    }
    
    func getNoidung() -> String {
        return self.noidung
    }
    
    func setNoidung(noidung: String) {
        self.noidung = String(describing: noidung.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
