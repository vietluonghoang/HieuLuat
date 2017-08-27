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
        let resultSet: FMResultSet! = DataConnection.database!.executeQuery(sql, withArgumentsIn: [])!
        var dieukhoanArray = Array<Dieukhoan>()
        if resultSet != nil {
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
        }
        DataConnection.database!.close()
        return dieukhoanArray
    }
    
    class func searchDieukhoan(keyword:String) -> [Dieukhoan] {
        DataConnection.database!.open()
        let kw = keyword.lowercased()
        var appendString = ""
        var appendKeyword: [String] = []
        for k in kw.components(separatedBy: " ") {
            appendString += " dkSearch like ? and"
            appendKeyword.append("%\(k)%")
        }
        
        appendString = appendString.substring(to: appendString.index(appendString.endIndex, offsetBy: -4))
        
        let sql = "select dk.id as dkId, dk.so as dkSo, tieude as dkTieude, dk.noidung as dkNoidung, minhhoa as dkMinhhoa, cha as dkCha, vb.loai as lvbID, lvb.ten as lvbTen, vb.so as vbSo, vanbanid as vbId, vb.ten as vbTen, nam as vbNam, ma as vbMa, vb.noidung as vbNoidung, coquanbanhanh as vbCoquanbanhanhId, cq.ten as cqTen, dk.forSearch as dkSearch from tblChitietvanban as dk join tblVanban as vb on dk.vanbanid=vb.id join tblLoaivanban as lvb on vb.loai=lvb.id join tblCoquanbanhanh as cq on vb.coquanbanhanh=cq.id where"+appendString
        
        let resultSet: FMResultSet! = DataConnection.database!.executeQuery(sql, withArgumentsIn: appendKeyword)!
        
        var dieukhoanArray = Array<Dieukhoan>()
        
        if resultSet != nil {
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
        }
        
        DataConnection.database!.close()
        
        return dieukhoanArray
    }
    
    class func searchDieukhoanByID(keyword:String) -> [Dieukhoan] {
        DataConnection.database!.open()
        
        let sql = "select dk.id as dkId, dk.so as dkSo, tieude as dkTieude, dk.noidung as dkNoidung, minhhoa as dkMinhhoa, cha as dkCha, vb.loai as lvbID, lvb.ten as lvbTen, vb.so as vbSo, vanbanid as vbId, vb.ten as vbTen, nam as vbNam, ma as vbMa, vb.noidung as vbNoidung, coquanbanhanh as vbCoquanbanhanhId, cq.ten as cqTen from tblChitietvanban as dk join tblVanban as vb on dk.vanbanid=vb.id join tblLoaivanban as lvb on vb.loai=lvb.id join tblCoquanbanhanh as cq on vb.coquanbanhanh=cq.id where dkId = ?"
        
        let resultSet: FMResultSet! = DataConnection.database!.executeQuery(sql, withArgumentsIn: [keyword,keyword,keyword,keyword])!
        
        var dieukhoanArray = Array<Dieukhoan>()
        
        if resultSet != nil {
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
        }
        
        DataConnection.database!.close()
        
        return dieukhoanArray
    }
    
    class func searchDieukhoanBySo(keyword:String) -> [Dieukhoan] {
        DataConnection.database!.open()
        
        let sql = "select dk.id as dkId, dk.so as dkSo, tieude as dkTieude, dk.noidung as dkNoidung, minhhoa as dkMinhhoa, cha as dkCha, vb.loai as lvbID, lvb.ten as lvbTen, vb.so as vbSo, vanbanid as vbId, vb.ten as vbTen, nam as vbNam, ma as vbMa, vb.noidung as vbNoidung, coquanbanhanh as vbCoquanbanhanhId, cq.ten as cqTen from tblChitietvanban as dk join tblVanban as vb on dk.vanbanid=vb.id join tblLoaivanban as lvb on vb.loai=lvb.id join tblCoquanbanhanh as cq on vb.coquanbanhanh=cq.id where dkSo = ?"
        
        let resultSet: FMResultSet! = DataConnection.database!.executeQuery(sql, withArgumentsIn: [keyword,keyword,keyword,keyword])!
        
        var dieukhoanArray = Array<Dieukhoan>()
        
        if resultSet != nil {
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
        }
        
        DataConnection.database!.close()
        
        return dieukhoanArray
    }
    
    class func searchChildren(keyword:String) -> [Dieukhoan] {
        DataConnection.database!.open()
        
        let sql = "select dk.id as dkId, dk.so as dkSo, tieude as dkTieude, dk.noidung as dkNoidung, minhhoa as dkMinhhoa, cha as dkCha, vb.loai as lvbID, lvb.ten as lvbTen, vb.so as vbSo, vanbanid as vbId, vb.ten as vbTen, nam as vbNam, ma as vbMa, vb.noidung as vbNoidung, coquanbanhanh as vbCoquanbanhanhId, cq.ten as cqTen from tblChitietvanban as dk join tblVanban as vb on dk.vanbanid=vb.id join tblLoaivanban as lvb on vb.loai=lvb.id join tblCoquanbanhanh as cq on vb.coquanbanhanh=cq.id where dkCha = ?"
        
        let resultSet: FMResultSet! = DataConnection.database!.executeQuery(sql, withArgumentsIn: [keyword,keyword,keyword,keyword])!
        
        var dieukhoanArray = Array<Dieukhoan>()
        
        if resultSet != nil {
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
        }
        
        DataConnection.database!.close()
        
        return dieukhoanArray
    }
}

