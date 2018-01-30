//
//  Queries.swift
//  HieuLuat
//
//  Created by VietLH on 8/26/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit
import FMDB

class Queries: NSObject {
    
    static var physicalMemorySize: UInt64 {
        get{
            return self.physicalMemorySize
        }
        set(v){
            self.physicalMemorySize = getPhysicalMemorySize();
        }
    }
    
    static var rawSqlQuery: String {
        get {
            return "select distinct dk.id as dkId, dk.so as dkSo, tieude as dkTieude, dk.noidung as dkNoidung, minhhoa as dkMinhhoa, cha as dkCha, vb.loai as lvbID, lvb.ten as lvbTen, vb.so as vbSo, vanbanid as vbId, vb.ten as vbTen, nam as vbNam, ma as vbMa, vb.noidung as vbNoidung, coquanbanhanh as vbCoquanbanhanhId, cq.ten as cqTen, dk.forSearch as dkSearch from tblChitietvanban as dk join tblVanban as vb on dk.vanbanid=vb.id join tblLoaivanban as lvb on vb.loai=lvb.id join tblCoquanbanhanh as cq on vb.coquanbanhanh=cq.id where "
        }
        set(v) {
            self.rawSqlQuery = v
        }
    }
    
    class func insert(dieukhoan:Dieukhoan) {
        //        Utils.database!.open()
        //        let sql = "INSERT INTO Person (id, name, age) VALUES (?, ?, ?)"
        //        Utils.database!.executeUpdate(sql, withArgumentsIn: [person.id!,person.name!, person.age!])
        //        Utils.database!.close()
    }
    
    class func update(dieukhoan:Dieukhoan) {
        //        Utils.database!.open()
        //        let sql = "UPDATE Person SET name = ?, age = ? WHERE id = ?"
        //        Utils.database!.executeUpdate(sql,  withArgumentsIn: [person.name!, person.age!, person.id!])
        //        Utils.database!.close()
    }
    
    class func delete(dieukhoan:Dieukhoan) {
        //        Utils.database!.open()
        //        let sql = "DELETE FROM Person WHERE id = ?"
        //        Utils.database!.executeUpdate(sql, withArgumentsIn: [person.id!])
        //        Utils.database!.close()
    }
    
    class func deleteAll() {
        //        Utils.database!.open()
        //        let sql = "DELETE FROM Person"
        //        Utils.database!.executeUpdate(sql, withArgumentsIn: nil)
        //        Utils.database!.close()
    }
    
    class func selectAllDieukhoan() -> [Dieukhoan] {
        DataConnection.database!.open()
        let sql = "SELECT * FROM tblChitietvanban"
        let resultSet: FMResultSet! = DataConnection.database!.executeQuery(setRecordsCap(query: sql), withArgumentsIn: [])!
        var dieukhoanArray = Array<Dieukhoan>()
        if resultSet != nil {
            dieukhoanArray = generateDieukhoanList(resultSet: resultSet)
        }
        DataConnection.database!.close()
        return dieukhoanArray
    }
    
    class func searchDieukhoan(keyword:String, vanbanid: [String]) -> [Dieukhoan] {
        DataConnection.database!.open()
        
        let specificVanban = generateWhereClauseForVanbanid(vanbanid: vanbanid, vanbanIdColumnName: "vbId")
        let appendString = generateWhereClauseForKeywordsWithDifferentAccentType(keyword: keyword, targetColumn: "dkSearch")
        let appendKeyword = [String]()
        
        let sql = "\(rawSqlQuery) (\(appendString)) \(specificVanban)"
        
        let resultSet: FMResultSet! = DataConnection.database!.executeQuery(setRecordsCap(query: sql), withArgumentsIn: appendKeyword)!
        
        var dieukhoanArray = Array<Dieukhoan>()
        
        if resultSet != nil {
            dieukhoanArray = generateDieukhoanList(resultSet: resultSet)
        }
        
        DataConnection.database!.close()
        
        return dieukhoanArray
    }
    
    class func searchDieukhoanByQuery(query:String, vanbanid: [String]) -> [Dieukhoan] {
        DataConnection.database!.open()
        let specificVanban = generateWhereClauseForVanbanid(vanbanid: vanbanid, vanbanIdColumnName: "vbId")
        let appendKeyword = [String]()
        let sql = query.lowercased() + specificVanban
        
        let resultSet: FMResultSet! = DataConnection.database!.executeQuery(setRecordsCap(query: sql), withArgumentsIn: appendKeyword)!
        
        var dieukhoanArray = Array<Dieukhoan>()
        
        if resultSet != nil {
            dieukhoanArray = generateDieukhoanList(resultSet: resultSet)
        }
        
        DataConnection.database!.close()
        
        return dieukhoanArray
    }
    
    class func searchDieukhoanByID(keyword:String,vanbanid:[String]) -> [Dieukhoan] {
        DataConnection.database!.open()
        let specificVanban = generateWhereClauseForVanbanid(vanbanid: vanbanid, vanbanIdColumnName: "vbId")
        let sql = rawSqlQuery + " dkId = ? "+specificVanban
        
        let resultSet: FMResultSet! = DataConnection.database!.executeQuery(setRecordsCap(query: sql), withArgumentsIn: [keyword,keyword,keyword,keyword])!
        
        var dieukhoanArray = Array<Dieukhoan>()
        
        if resultSet != nil {
            dieukhoanArray = generateDieukhoanList(resultSet: resultSet)
        }
        
        DataConnection.database!.close()
        
        return dieukhoanArray
    }
    
    class func searchDieukhoanBySo(keyword:String,vanbanid:[String]) -> [Dieukhoan] {
        DataConnection.database!.open()
        let specificVanban = generateWhereClauseForVanbanid(vanbanid: vanbanid, vanbanIdColumnName: "vbId")
        let sql = rawSqlQuery + "(dkSo = ? or dk.forsearch like ? or dk.forsearch like ?)" + specificVanban
        
        let resultSet: FMResultSet! = DataConnection.database!.executeQuery(setRecordsCap(query: sql), withArgumentsIn: [keyword,"\(keyword) %","\(keyword). %"])!
        
        var dieukhoanArray = Array<Dieukhoan>()
        
        if resultSet != nil {
            dieukhoanArray = generateDieukhoanList(resultSet: resultSet)
        }
        
        DataConnection.database!.close()
        
        return dieukhoanArray
    }
    
    class func searchChildren(keyword:String,vanbanid:[String]) -> [Dieukhoan] {
        DataConnection.database!.open()
        let specificVanban = generateWhereClauseForVanbanid(vanbanid: vanbanid, vanbanIdColumnName: "vbId")
        var searchArgurment = ""
        var searchKeyword = ""
        searchKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if(searchKeyword.characters.count == 0){
            searchArgurment = "is null"
        }else{
            searchArgurment = "= ?"
        }
        
        let sql = rawSqlQuery + "dkCha "+searchArgurment+specificVanban
        
        let resultSet: FMResultSet! = DataConnection.database!.executeQuery(setRecordsCap(query: sql), withArgumentsIn: [keyword,keyword,keyword,keyword])!
        
        var dieukhoanArray = Array<Dieukhoan>()
        
        if resultSet != nil {
            dieukhoanArray = generateDieukhoanList(resultSet: resultSet)
        }
        
        DataConnection.database!.close()
        
        return dieukhoanArray
    }
    
    class func getAllRelatedDieukhoan(dieukhoanId: Int64) -> [Dieukhoan] {
        DataConnection.database!.open()
        let sql = rawSqlQuery + " dkId in (select dieukhoanId from tblRelatedDieukhoan where relatedDieukhoanId = \(dieukhoanId)) or dkId in (select relatedDieukhoanId from tblRelatedDieukhoan where dieukhoanId = \(dieukhoanId))"
        
        let resultSet: FMResultSet! = DataConnection.database!.executeQuery(sql, withArgumentsIn: [])!
        
        var dieukhoanArray = Array<Dieukhoan>()
        
        if resultSet != nil {
            dieukhoanArray = generateDieukhoanList(resultSet: resultSet)
        }
        
        DataConnection.database!.close()
        
        return dieukhoanArray
    }
    
    class func getAllHinhphatbosung(dieukhoanId: Int64) -> [BosungKhacphuc] {
        DataConnection.database!.open()
        let sql = "select distinct dk.id as dkId, dk.so as dkSo, dk.tieude as dkTieude, dk.noidung as dkNoidung, dk.minhhoa as dkMinhhoa, dk.cha as dkCha, vb.loai as lvbID, lvb.ten as lvbTen, vb.so as vbSo, dk.vanbanid as vbId, vb.ten as vbTen, vb.nam as vbNam, vb.ma as vbMa, vb.noidung as vbNoidung, vb.coquanbanhanh as vbCoquanbanhanhId, cq.ten as cqTen, dk.forSearch as dkSearch, rdk.id as rdkId, rdk.so as rdkSo, rdk.tieude as rdkTieude, rdk.noidung as rdkNoidung, rdk.minhhoa as rdkMinhhoa, rdk.cha as rdkCha, rvb.loai as rlvbID, rlvb.ten as rlvbTen, rvb.so as rvbSo, rdk.vanbanid as rvbId, rvb.ten as rvbTen, rvb.nam as rvbNam, rvb.ma as rvbMa, rvb.noidung as rvbNoidung, rvb.coquanbanhanh as rvbCoquanbanhanhId, rcq.ten as rcqTen, rdk.forSearch as rdkSearch, hp.noidung as noidung from tblChitietvanban as dk join tblVanban as vb on dk.vanbanid=vb.id join tblLoaivanban as lvb on vb.loai=lvb.id join tblCoquanbanhanh as cq on vb.coquanbanhanh=cq.id join tblHinhphatbosung as hp on dk.id = hp.dieukhoanId join tblChitietvanban as rdk on hp.dieukhoanQuydinhId = rdk.id join tblVanban as rvb on rdk.vanbanid=rvb.id join tblLoaivanban as rlvb on rvb.loai=rlvb.id join tblCoquanbanhanh as rcq on rvb.coquanbanhanh=rcq.id where hp.dieukhoanId = \(dieukhoanId)"
        
        let resultSet: FMResultSet! = DataConnection.database!.executeQuery(sql, withArgumentsIn: [])!
        
        var bosungKhacphucArray = Array<BosungKhacphuc>()
        
        if resultSet != nil {
            bosungKhacphucArray = generateBosungKhacphucList(resultSet: resultSet)
        }
        
        DataConnection.database!.close()
        
        return bosungKhacphucArray
    }
    
    class func getAllBienphapkhacphuc(dieukhoanId: Int64) -> [BosungKhacphuc] {
        DataConnection.database!.open()
        let sql = "select distinct dk.id as dkId, dk.so as dkSo, dk.tieude as dkTieude, dk.noidung as dkNoidung, dk.minhhoa as dkMinhhoa, dk.cha as dkCha, vb.loai as lvbID, lvb.ten as lvbTen, vb.so as vbSo, dk.vanbanid as vbId, vb.ten as vbTen, vb.nam as vbNam, vb.ma as vbMa, vb.noidung as vbNoidung, vb.coquanbanhanh as vbCoquanbanhanhId, cq.ten as cqTen, dk.forSearch as dkSearch, rdk.id as rdkId, rdk.so as rdkSo, rdk.tieude as rdkTieude, rdk.noidung as rdkNoidung, rdk.minhhoa as rdkMinhhoa, rdk.cha as rdkCha, rvb.loai as rlvbID, rlvb.ten as rlvbTen, rvb.so as rvbSo, rdk.vanbanid as rvbId, rvb.ten as rvbTen, rvb.nam as rvbNam, rvb.ma as rvbMa, rvb.noidung as rvbNoidung, rvb.coquanbanhanh as rvbCoquanbanhanhId, rcq.ten as rcqTen, rdk.forSearch as rdkSearch, kp.noidung as noidung from tblChitietvanban as dk join tblVanban as vb on dk.vanbanid=vb.id join tblLoaivanban as lvb on vb.loai=lvb.id join tblCoquanbanhanh as cq on vb.coquanbanhanh=cq.id join tblBienphapkhacphuc as kp on dk.id = kp.dieukhoanId join tblChitietvanban as rdk on kp.dieukhoanQuydinhId = rdk.id join tblVanban as rvb on rdk.vanbanid=rvb.id join tblLoaivanban as rlvb on rvb.loai=rlvb.id join tblCoquanbanhanh as rcq on rvb.coquanbanhanh=rcq.id where kp.dieukhoanId = \(dieukhoanId)"
        
        let resultSet: FMResultSet! = DataConnection.database!.executeQuery(sql, withArgumentsIn: [])!
        
        var bosungKhacphucArray = Array<BosungKhacphuc>()
        
        if resultSet != nil {
            bosungKhacphucArray = generateBosungKhacphucList(resultSet: resultSet)
        }
        
        DataConnection.database!.close()
        
        return bosungKhacphucArray
    }
    
    class func searchMucphatInfo(id: String) -> String {
        DataConnection.database!.open()
        
        //there is an 'typo' in the create table query then the column named 'tochucDen' became 'tuchucDen'
        
        let sql = "select distinct canhanTu, canhanDen, tochucTu, tuchucDen from tblMucphat where dieukhoanId = ?"
        
        let resultSet: FMResultSet! = DataConnection.database!.executeQuery(sql, withArgumentsIn: [id])!
        var result = ""
        if resultSet != nil {
            while resultSet.next() {
                let cnTu = resultSet.string(forColumn: "canhanTu")!
                let cnDen = resultSet.string(forColumn: "canhanDen")!
                let tcTu = resultSet.string(forColumn: "tochucTu")!
                let tcDen = resultSet.string(forColumn: "tuchucDen")!
                if tcTu != "" && tcDen != "" {
                    result = "cá nhân: \(cnTu) - \(cnDen)\ntổ chức: \(tcTu) - \(tcDen)"
                }else{
                    if cnDen != "" {
                        if cnTu != "" {
                            result = "\(cnTu) - \(cnDen)"
                        }else{
                            result = "đến \(cnDen)"
                        }
                    }
                }
            }
        }
        
        DataConnection.database!.close()
        
        return result
        
    }
    
    class func searchPhuongtienInfo(id: String) -> String {
        DataConnection.database!.open()
        
        let sql = "select distinct oto, otoTai, maykeo, xechuyendung, tau, moto, xeganmay, xemaydien, xedapmay, xedap, xedapdien, xethoso, sucvat, xichlo, dibo from tblPhuongtien where dieukhoanId = ?"
        
        let resultSet: FMResultSet! = DataConnection.database!.executeQuery(sql, withArgumentsIn: [id])!
        var result = ""
        if resultSet != nil {
            while resultSet.next() {
                let oto = resultSet.string(forColumn: "oto")!
                let otoTai = resultSet.string(forColumn: "otoTai")!
                let maykeo = resultSet.string(forColumn: "maykeo")!
                let xechuyendung = resultSet.string(forColumn: "xechuyendung")!
                let tau = resultSet.string(forColumn: "tau")!
                let moto = resultSet.string(forColumn: "moto")!
                let xeganmay = resultSet.string(forColumn: "xeganmay")!
                let xemaydien = resultSet.string(forColumn: "xemaydien")!
                let xedapmay = resultSet.string(forColumn: "xedapmay")!
                let xedap = resultSet.string(forColumn: "xedap")!
                let xedapdien = resultSet.string(forColumn: "xedapdien")!
                let xethoso = resultSet.string(forColumn: "xethoso")!
                let sucvat = resultSet.string(forColumn: "sucvat")!
                let xichlo = resultSet.string(forColumn: "xichlo")!
                let dibo = resultSet.string(forColumn: "dibo")!
                if oto != "0" || otoTai != "0" {
                    result += "Ô tô (ô tô tải, rơ moóc), "
                }
                if maykeo != "0" || xechuyendung != "0" {
                    result += "Máy kéo (xe chuyên dùng), "
                }
                if moto != "0" || xeganmay != "0" || xemaydien != "0" {
                    result += "Xe máy, "
                }
                if xedapmay != "0" || xedap != "0" || xedapdien != "0" || xethoso != "0" || sucvat != "0" || xichlo != "0" {
                    result += "Xe thô sơ (xe súc vật kéo), "
                }
                if tau != "0" {
                    result += "Tàu hoả, "
                }
                if dibo != "0" {
                    result += "Người đi bộ, "
                }
            }
        }
        
        DataConnection.database!.close()
        if result.characters.count >= 2 {
            result = result.substring(to: result.index(result.endIndex, offsetBy: -2))
        }
        return result
    }
    
    class func searchLinhvucInfo(id: String) -> String {
        DataConnection.database!.open()
        
        let sql = "select distinct duongbo, duongsat from tblLinhvuc where dieukhoanId = ?"
        
        let resultSet: FMResultSet! = DataConnection.database!.executeQuery(sql, withArgumentsIn: [id])!
        var result = ""
        if resultSet != nil {
            while resultSet.next() {
                let duongbo = resultSet.string(forColumn: "duongbo")!
                let duongsat = resultSet.string(forColumn: "duongsat")!
                if duongbo != "0"  && duongsat != "0"{
                    result = "Đường bộ, Đường sắt"
                }else{
                    if duongsat != "0" {
                        result = "Đường sắt"
                    }
                    if duongbo != "0" {
                        result = "Đường bộ"
                    }
                }
            }
        }
        
        DataConnection.database!.close()
        
        return result
    }
    
    //TODO: implement doituong info
    class func searchDoituongInfo(id: String) -> String {
        DataConnection.database!.open()
        
        let sql = "select distinct canhan, tochuc, doanhnghiep, trungtam, daotao, nguoidieukhien, nguoingoitrenxe, nguoiduoctro, giaovien, ga, chuphuongtien, nhanvien, dangkiemvien, laitau, truongdon, truongtau, dieukhienmaydon, trucban, duaxe, kinhdoanh, vanchuyen, vantai, hanhkhach, hanghoa, ketcau, hatang, luukho, laprap, xepdo, quanly, thuphi, dangkiem, sathach, dichvu, hotro, ghepnoi, gacchan, khamxe, thuham, phucvu, baoquan, sanxuat, hoancai, phuchoi, khaithac, baotri from tblKeywords where dieukhoanId = ?"
        
        let resultSet: FMResultSet! = DataConnection.database!.executeQuery(sql, withArgumentsIn: [id])!
        var result = ""
        if resultSet != nil {
            while resultSet.next() {
                let canhan = resultSet.string(forColumn: "canhan")!
                let tochuc = resultSet.string(forColumn: "tochuc")!
                let doanhnghiep = resultSet.string(forColumn: "doanhnghiep")!
                let trungtam = resultSet.string(forColumn: "trungtam")!
                let daotao = resultSet.string(forColumn: "daotao")!
                let nguoidieukhien = resultSet.string(forColumn: "nguoidieukhien")!
                let nguoingoitrenxe = resultSet.string(forColumn: "nguoingoitrenxe")!
                let nguoiduoctro = resultSet.string(forColumn: "nguoiduoctro")!
                let giaovien = resultSet.string(forColumn: "giaovien")!
                let ga = resultSet.string(forColumn: "ga")!
                let chuphuongtien = resultSet.string(forColumn: "chuphuongtien")!
                let nhanvien = resultSet.string(forColumn: "nhanvien")!
                let dangkiemvien = resultSet.string(forColumn: "dangkiemvien")!
                let laitau = resultSet.string(forColumn: "laitau")!
                let truongdon = resultSet.string(forColumn: "truongdon")!
                let truongtau = resultSet.string(forColumn: "truongtau")!
                let dieukhienmaydon = resultSet.string(forColumn: "dieukhienmaydon")!
                let trucban = resultSet.string(forColumn: "trucban")!
                let duaxe = resultSet.string(forColumn: "duaxe")!
                let kinhdoanh = resultSet.string(forColumn: "kinhdoanh")!
                let vantai = resultSet.string(forColumn: "vantai")!
                let hanghoa = resultSet.string(forColumn: "hanghoa")!
                let ketcau = resultSet.string(forColumn: "ketcau")!
                let hatang = resultSet.string(forColumn: "hatang")!
                let laprap = resultSet.string(forColumn: "laprap")!
                let xepdo = resultSet.string(forColumn: "xepdo")!
                let quanly = resultSet.string(forColumn: "quanly")!
                let thuphi = resultSet.string(forColumn: "thuphi")!
                let dangkiem = resultSet.string(forColumn: "dangkiem")!
                let sathach = resultSet.string(forColumn: "sathach")!
                let hotro = resultSet.string(forColumn: "hotro")!
                let ghepnoi = resultSet.string(forColumn: "ghepnoi")!
                let gacchan = resultSet.string(forColumn: "gacchan")!
                let khamxe = resultSet.string(forColumn: "khamxe")!
                let thuham = resultSet.string(forColumn: "thuham")!
                let phucvu = resultSet.string(forColumn: "phucvu")!
                let baoquan = resultSet.string(forColumn: "baoquan")!
                let sanxuat = resultSet.string(forColumn: "sanxuat")!
                let luukho = resultSet.string(forColumn: "luukho")!
                let hoancai = resultSet.string(forColumn: "hoancai")!
                let phuchoi = resultSet.string(forColumn: "phuchoi")!
                let khaithac = resultSet.string(forColumn: "khaithac")!
                let baotri = resultSet.string(forColumn: "baotri")!
                let hanhkhach = resultSet.string(forColumn: "hanhkhach")!
                let vanchuyen = resultSet.string(forColumn: "vanchuyen")!
                let dichvu = resultSet.string(forColumn: "dichvu")!
                
                if ga != "0" {
                    result += "Ga, "
                }
                if daotao != "0" {
                    result += "Cơ sở đào tạo Lái xe, "
                }
                if nhanvien != "0" && ghepnoi != "0" {
                    result += "Nhân viên ghép nối đầu máy, toa xe, "
                }
                if nhanvien != "0" && gacchan != "0" {
                    result += "Nhân viên gác chắn, "
                }
                if nhanvien != "0" && khamxe != "0" {
                    result += "NNhân viên khám xe, "
                }
                if nhanvien != "0" && khamxe != "0" && thuham != "0" {
                    result += "Nhân viên khám xe Phụ trách thử hãm, "
                }
                if nhanvien != "0" && phucvu != "0" {
                    result += "Nhân viên Phục vụ, "
                }
                //                if nhanvien != "0" && dieudo != "0" {
                //                    result += "Nhân viên điều độ chạy tàu, "
                //                }
                //                if nhanvien != "0" && ghepnoi != "0" {
                //                    result += "Nhân viên đường sắt, "
                //                }
                
                //                if dibo != "0" {
                //                    result += "Người đi bộ, "
                //                }
                if dangkiemvien != "0" {
                    result += "Đăng kiểm viên, "
                }
                if nhanvien != "0" && trungtam != "0" && dangkiem != "0" {
                    result += "Nhân viên nghiệp vụ của Trung tâm Đăng kiểm, "
                }
                if laitau != "0"{
                    result += "Lái tàu (Phụ Lái tàu), "
                }
                if truongdon != "0" {
                    result += "Trưởng dồn, "
                }
                if truongtau != "0" {
                    result += "Trưởng tàu, "
                }
                if dieukhienmaydon != "0" {
                    result += "Điều khiển máy dồn, "
                }
                if trucban != "0" {
                    result += "Trực ban chạy tàu ga, "
                }
                if canhan != "0" {
                    result += "Cá nhân, "
                }
                if chuphuongtien != "0" {
                    result += "Chủ phương tiện, "
                }
                if canhan != "0" && (kinhdoanh != "0" || hotro != "0") && vantai != "0" {
                    result += "Cá nhân kinh doanh vận tải, dịch vụ hỗ trợ vận tải, "
                }
                if giaovien != "0" {
                    result += "Giáo viên dạy Lái xe, "
                }
                if duaxe != "0" {
                    result += "Người đua xe, "
                }
                if nguoidieukhien != "0" {
                    result += "Người Điều khiển phương tiện, "
                }
                if nguoiduoctro != "0" || nguoingoitrenxe != "0" {
                    result += "Người được chở (người ngồi trên xe), "
                }
                if doanhnghiep != "0" && kinhdoanh != "0" && ketcau != "0" && hatang != "0"{
                    result += "Doanh nghiệp kinh doanh kết cấu hạ tầng đường sắt (đường bộ), "
                }
                if doanhnghiep != "0" && (luukho != "0" || baoquan != "0") && kinhdoanh != "0" && hanghoa != "0" {
                    result += "Doanh nghiệp kinh doanh lưu kho, bảo quản hàng hóa, "
                }
                if doanhnghiep != "0" && kinhdoanh != "0" && (sanxuat != "0" || laprap != "0" || hoancai != "0" || phuchoi != "0") {
                    result += "Doanh nghiệp kinh doanh sản xuất, lắp ráp, hoán cải, Phục hồi phương tiện giao thông, "
                }
                if doanhnghiep != "0" && kinhdoanh != "0" && vantai != "0" {
                    result += "Doanh nghiệp kinh doanh vận tải đường sắt, "
                }
                if doanhnghiep != "0" && kinhdoanh != "0" && xepdo != "0" && hanghoa != "0" {
                    result += "Doanh nghiệp kinh doanh xếp, dỡ hàng hóa, "
                }
                if trungtam != "0" && sathach != "0" {
                    result += "Trung tâm sát hạch Lái xe, "
                }
                if trungtam != "0" && dangkiem != "0" {
                    result += "Trung tâm Đăng kiểm, "
                }
                if tochuc != "0" && (kinhdoanh != "0" || hotro != "0") && vantai != "0" {
                    result += "Tổ chức kinh doanh vận tải, dịch vụ hỗ trợ vận tải, "
                }
                if tochuc != "0" && quanly != "0" && kinhdoanh != "0" {
                    result += "Tổ chức quản lý, kinh doanh đường sắt, "
                }
                if tochuc != "0" && thuphi != "0" {
                    result += "Tổ chức thu phí đường bộ, "
                }
                if tochuc != "0" && quanly != "0" && khaithac != "0" {
                    result += "Tổ chức Trực tiếp quản lý, khai thác phương tiện giao thông đường sắt, "
                }
                if tochuc != "0" && quanly != "0" && khaithac != "0" && baotri != "0" && ketcau != "0" && hatang != "0" {
                    result += "Tổ chức được giao quản lý, khai thác, bảo trì kết cấu hạ tầng giao thông đường bộ (đường sắt), "
                }
            }
        }
        
        DataConnection.database!.close()
        
        if result.characters.count >= 2 {
            result = result.substring(to: result.index(result.endIndex, offsetBy: -2))
        }
        
        return result
    }
    
    class func appendDieukhoan(dieukhoan: Dieukhoan, dkArr: [Dieukhoan]) -> [Dieukhoan] {
        var dieukhoanArray = dkArr
        for dk in dieukhoanArray {
            if dieukhoan.getId() == dk.getId() {
                return dieukhoanArray
            }
        }
        dieukhoanArray.append(dieukhoan)
        return dieukhoanArray
    }
    class func getPhysicalMemorySize() -> UInt64 {
        return ProcessInfo.processInfo.physicalMemory / UInt64(1024.0 * 1024.0 * 1024.0)
    }
    
    class func setRecordsCap(query: String) -> String {
        let cap = GeneralSettings().getRecordCapByRam(ram: getPhysicalMemorySize())
        
        //if cap equals 0, it means no cap
        if cap == 0 {
            return query
        }
        return  "\(query) limit \(cap)"
    }
    
    class func convertKeywordsForDifferentAccentType(keyword: String) -> [String] {
        var convertedKeyword = ""
        
        var vnChars = ["á", "à", "ả", "ã", "ạ", "a", "ấ", "ầ", "ẩ", "ẫ", "ậ", "â", "ắ", "ằ", "ẳ", "ẵ", "ặ", "ă", "é", "è", "ẻ", "ẽ", "ẹ", "e", "ế", "ề", "ể", "ễ", "ệ", "ê", "í", "ì", "ỉ", "ĩ", "ị", "i", "ó", "ò", "ỏ", "õ", "ọ", "o", "ố", "ồ", "ổ", "ỗ", "ộ", "ô", "ớ", "ờ", "ở", "ỡ", "ợ", "ơ", "ú", "ù", "ủ", "ũ", "ụ", "u", "ứ", "ừ", "ử", "ữ", "ự", "ư", "ý", "ỳ", "ỷ", "ỹ", "ỵ", "y"]
        
        let splittedStr = keyword.components(separatedBy: " ")
        
        for sStr in splittedStr {
            var matchChars = [Int16]()
            var matchAccents = [Int16]()
            for char in sStr.characters {
                var count = 0
                for vnC in vnChars {
                    if char == vnC.characters.first {
                        matchChars.append(Int16(count/6))
                        matchAccents.append(Int16(count%6))
                    }
                    count += 1
                }
            }
            var index = 0
            var newKeyword = sStr
            for chr in matchChars {
                newKeyword = newKeyword.replacingOccurrences(of: vnChars[Int((chr*6)+matchAccents[index])], with: vnChars[Int((chr*6)+(matchAccents[matchAccents.count - (index + 1)]))])
                index += 1
            }
            convertedKeyword += "\(newKeyword) "
        }
        var newKeys = [String]()
        newKeys.append(keyword)
        newKeys.append(convertedKeyword)
        return newKeys
    }
    
    class func generateWhereClauseForKeywordsWithDifferentAccentType(keyword: String, targetColumn: String) -> String {
        var appendString = ""
        let kw = convertKeywordsForDifferentAccentType(keyword: keyword.lowercased())
        for k in kw {
            var str = ""
            for key in k.components(separatedBy: " ") {
                str += "\(targetColumn) like '%\(key)%' and "
            }
            str = str.substring(to: str.index(str.endIndex, offsetBy: -5))
            appendString += "(\(str)) or "
        }
        appendString = appendString.substring(to: appendString.index(appendString.endIndex, offsetBy: -4))
        return appendString
    }
    
    class func generateWhereClauseForVanbanid(vanbanid: [String], vanbanIdColumnName: String) -> String {
        var specificVanban = ""
        if vanbanid.count > 0 {
            specificVanban = " and ("
            for id in vanbanid {
                if id.characters.count > 0 {
                    specificVanban = specificVanban + "\(vanbanIdColumnName) = "+id.trimmingCharacters(in: .whitespacesAndNewlines) + " or "
                }
            }
            specificVanban = specificVanban.substring(to: specificVanban.index(specificVanban.endIndex, offsetBy: -4)) + ")"
        }
        return specificVanban
    }
    
    class func generateDieukhoanList(resultSet: FMResultSet) -> [Dieukhoan] {
        var dieukhoanArray = Array<Dieukhoan>()
        
        while resultSet.next() {
            var cha = resultSet.string(forColumn: "dkCha")
            if(cha==nil){
                cha="0"
            }
            let lvb = Loaivanban(id: Int64(resultSet.string(forColumn: "lvbId")!)!, ten: resultSet.string(forColumn: "lvbTen")!)
            let cq = Coquanbanhanh(id: Int64(resultSet.string(forColumn: "vbCoquanbanhanhid")!)!, ten: resultSet.string(forColumn: "cqTen")!)
            let vb = Vanban(id: Int64(resultSet.string(forColumn: "vbId")!)!, ten: resultSet.string(forColumn: "vbTen")!, loai: lvb, so: resultSet.string(forColumn: "vbSo")!, nam: resultSet.string(forColumn: "vbNam")!, ma: resultSet.string(forColumn: "vbMa")!, coquanbanhanh: cq, noidung: resultSet.string(forColumn: "vbNoidung")!)
            let dieukhoan = Dieukhoan(id: Int64(resultSet.string(forColumn: "dkId")!)!, so: resultSet.string(forColumn: "dkSo")!, tieude: resultSet.string(forColumn: "dkTieude")!, noidung: resultSet.string(forColumn: "dkNoidung")!, minhhoa: resultSet.string(forColumn: "dkMinhhoa")!, cha: Int64(cha!)!, vanban: vb)
            dieukhoanArray.append(dieukhoan)
        }
        
        return dieukhoanArray
    }
    
    class func generateBosungKhacphucList(resultSet: FMResultSet) -> [BosungKhacphuc] {
        var bosungKhacphucArray = Array<BosungKhacphuc>()
        
        while resultSet.next() {
            var cha = resultSet.string(forColumn: "dkCha")
            if(cha==nil){
                cha="0"
            }
            let lvb = Loaivanban(id: Int64(resultSet.string(forColumn: "lvbId")!)!, ten: resultSet.string(forColumn: "lvbTen")!)
            let cq = Coquanbanhanh(id: Int64(resultSet.string(forColumn: "vbCoquanbanhanhid")!)!, ten: resultSet.string(forColumn: "cqTen")!)
            let vb = Vanban(id: Int64(resultSet.string(forColumn: "vbId")!)!, ten: resultSet.string(forColumn: "vbTen")!, loai: lvb, so: resultSet.string(forColumn: "vbSo")!, nam: resultSet.string(forColumn: "vbNam")!, ma: resultSet.string(forColumn: "vbMa")!, coquanbanhanh: cq, noidung: resultSet.string(forColumn: "vbNoidung")!)
            let dieukhoan = Dieukhoan(id: Int64(resultSet.string(forColumn: "dkId")!)!, so: resultSet.string(forColumn: "dkSo")!, tieude: resultSet.string(forColumn: "dkTieude")!, noidung: resultSet.string(forColumn: "dkNoidung")!, minhhoa: resultSet.string(forColumn: "dkMinhhoa")!, cha: Int64(cha!)!, vanban: vb)
            var rcha = resultSet.string(forColumn: "rdkCha")
            if(rcha==nil){
                rcha="0"
            }
            let rlvb = Loaivanban(id: Int64(resultSet.string(forColumn: "rlvbId")!)!, ten: resultSet.string(forColumn: "rlvbTen")!)
            let rcq = Coquanbanhanh(id: Int64(resultSet.string(forColumn: "rvbCoquanbanhanhid")!)!, ten: resultSet.string(forColumn: "rcqTen")!)
            let rvb = Vanban(id: Int64(resultSet.string(forColumn: "rvbId")!)!, ten: resultSet.string(forColumn: "rvbTen")!, loai: rlvb, so: resultSet.string(forColumn: "rvbSo")!, nam: resultSet.string(forColumn: "rvbNam")!, ma: resultSet.string(forColumn: "rvbMa")!, coquanbanhanh: rcq, noidung: resultSet.string(forColumn: "rvbNoidung")!)
            let rdieukhoan = Dieukhoan(id: Int64(resultSet.string(forColumn: "rdkId")!)!, so: resultSet.string(forColumn: "rdkSo")!, tieude: resultSet.string(forColumn: "rdkTieude")!, noidung: resultSet.string(forColumn: "rdkNoidung")!, minhhoa: resultSet.string(forColumn: "rdkMinhhoa")!, cha: Int64(cha!)!, vanban: rvb)
            
            let bosungkhacphuc = BosungKhacphuc(dieukhoanLienquan: dieukhoan, dieukhoanQuydinh: rdieukhoan, noidung: resultSet.string(forColumn: "noidung")!)
            
            bosungKhacphucArray.append(bosungkhacphuc)
        }
        
        return bosungKhacphucArray
    }
}

