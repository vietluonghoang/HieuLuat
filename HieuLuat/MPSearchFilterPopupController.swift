//
//  MPSearchViewController.swift
//  HieuLuat
//
//  Created by VietLH on 9/24/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit

class MPSearchFilterPopupController: UIViewController {
    
    //    @IBOutlet var txtKeyword: UITextField!
    //    @IBOutlet var btnSearch: UIButton!
    //    @IBOutlet var lblLoctheo: UILabel!
    @IBOutlet var svLocScrollview: UIScrollView!
    @IBOutlet var lblMucphat: UILabel!
    @IBOutlet var swtMucphat: UISwitch!
    @IBOutlet var viewMucphat: UIView!
    //    @IBOutlet var consMucphatViewHeightEmpty: NSLayoutConstraint!
    @IBOutlet var consMucphatViewWidth: NSLayoutConstraint!
    @IBOutlet var consMucphatViewHeight: NSLayoutConstraint!
    @IBOutlet var lblTu: UILabel!
    @IBOutlet var btnTu: UIButton!
    @IBOutlet var lblDen: UILabel!
    @IBOutlet var btnDen: UIButton!
    @IBOutlet var lblPhuongtien: UILabel!
    @IBOutlet var swtPhuongtien: UISwitch!
    @IBOutlet var viewPhuongtien: UIView!
    @IBOutlet var consPhuongtienViewHeight: NSLayoutConstraint!
    //    @IBOutlet var consPhuongtienViewHeightEmpty: NSLayoutConstraint!
    @IBOutlet var btnOto: UIButton!
    @IBOutlet var btnXemay: UIButton!
    @IBOutlet var btnXechuyendung: UIButton!
    @IBOutlet var btnTauhoa: UIButton!
    @IBOutlet var btnXedap: UIButton!
    @IBOutlet var btnDibo: UIButton!
    @IBOutlet var lblDoituong: UILabel!
    @IBOutlet var swtDoituong: UISwitch!
    @IBOutlet var viewDoituong: UIView!
    @IBOutlet var consDoituongViewHeight: NSLayoutConstraint!
    //    @IBOutlet var consDoituongViewHeightEmpty: NSLayoutConstraint!
    @IBOutlet var lblCanhan: UILabel!
    @IBOutlet var viewCanhan: UIView!
    @IBOutlet var swtCanhan: UISwitch!
    //    @IBOutlet var consCanhanViewHeightEmpty: NSLayoutConstraint!
    @IBOutlet var consCanhanViewHeight: NSLayoutConstraint!
    @IBOutlet var lblChuphuongtien: UILabel!
    @IBOutlet var swtChuphuongtien: UISwitch!
    @IBOutlet var lblCanhanKDVT: UILabel!
    @IBOutlet var swtCanhanKDVT: UISwitch!
    @IBOutlet var lblCanhanGVDLX: UILabel!
    @IBOutlet var swtCanhanGVDLX: UISwitch!
    @IBOutlet var lblCanhanNDK: UILabel!
    @IBOutlet var swtCanhanNDK: UISwitch!
    @IBOutlet var lblCanhanNDX: UILabel!
    @IBOutlet var swtCanhanNDX: UISwitch!
    @IBOutlet var lblTochuc: UILabel!
    @IBOutlet var swtTochuc: UISwitch!
    @IBOutlet var viewTochuc: UIView!
    //    @IBOutlet var consTochucViewHeightEmpty: NSLayoutConstraint!
    @IBOutlet var consTochucViewHeight: NSLayoutConstraint!
    @IBOutlet var lblTochucKDVT: UILabel!
    @IBOutlet var swtTochucKDVT: UISwitch!
    @IBOutlet var lblTochucKDDS: UILabel!
    @IBOutlet var swtTochucKDDS: UISwitch!
    @IBOutlet var lblTochucTPDB: UILabel!
    @IBOutlet var swtTochucTPDB: UISwitch!
    @IBOutlet var lblTochucTTKDVTDS: UILabel!
    @IBOutlet var swtTochucTTKDVTDS: UISwitch!
    @IBOutlet var lblTochucTTQLKTPTDS: UILabel!
    @IBOutlet var swtTochucTTQLKTPTDS: UISwitch!
    @IBOutlet var lblTochucQLKTBTHTDB: UILabel!
    @IBOutlet var swtTochucQLKTBTHTDB: UISwitch!
    @IBOutlet var lblTochucQLKTBTHTDS: UILabel!
    @IBOutlet var swtTochucQLKTBTHTDS: UISwitch!
    @IBOutlet var lblDoanhnghiep: UILabel!
    @IBOutlet var swtDoanhnghiep: UISwitch!
    @IBOutlet var viewDoanhnghiep: UIView!
    
    //    @IBOutlet var consDoanhnghiepViewHeightEmpty: NSLayoutConstraint!
    @IBOutlet var consDoanhnghiepViewHeight: NSLayoutConstraint!
    @IBOutlet var lblDoanhnghiepKDKCHTDS: UILabel!
    @IBOutlet var swtDoanhnghiepKDKCHTDS: UISwitch!
    @IBOutlet var lblDoanhnghiepKDKB: UILabel!
    @IBOutlet var swtDoanhnghiepKDKB: UISwitch!
    @IBOutlet var lblDoanhnghiepKDSXLR: UILabel!
    @IBOutlet var swtDoanhnghiepKDSXLR: UISwitch!
    @IBOutlet var lblDoanhnghiepKDVTDS: UILabel!
    @IBOutlet var swtDoanhnghiepKDVTDS: UISwitch!
    @IBOutlet var lblDoanhnghiepKDXDHH: UILabel!
    @IBOutlet var swtDoanhnghiepKDXDHH: UISwitch!
    @IBOutlet var lblNhanvien: UILabel!
    @IBOutlet var swtNhanvien: UISwitch!
    @IBOutlet var viewNhanvien: UIView!
    
    @IBOutlet var consNhanvienViewHeight: NSLayoutConstraint!
    //    @IBOutlet var consNhanvienViewHeightEmpty: NSLayoutConstraint!
    @IBOutlet var lblNhanvienDKV: UILabel!
    @IBOutlet var swtNhanvienDKV: UISwitch!
    @IBOutlet var lblNhanvienNVTTDK: UILabel!
    @IBOutlet var swtNhanvienNVTTDK: UISwitch!
    @IBOutlet var lblNhanvienGC: UILabel!
    @IBOutlet var swtNhanvienGC: UISwitch!
    @IBOutlet var swtNhanvienKX: UISwitch!
    @IBOutlet var lblNhanvienKX: UILabel!
    @IBOutlet var lblNhanvienTH: UILabel!
    @IBOutlet var swtNhanvienTH: UISwitch!
    @IBOutlet var lblNhanvienPV: UILabel!
    @IBOutlet var swtNhanvienPV: UISwitch!
    @IBOutlet var lblNhanvienDDCT: UILabel!
    @IBOutlet var swtNhanvienDDCT: UISwitch!
    @IBOutlet var lblNhanvienDS: UILabel!
    @IBOutlet var swtNhanvienDS: UISwitch!
    @IBOutlet var lblNhanvienGN: UILabel!
    @IBOutlet var swtNhanvienGN: UISwitch!
    @IBOutlet var lblNhanvienLT: UILabel!
    @IBOutlet var swtNhanvienLT: UISwitch!
    @IBOutlet var lblNhanvienPLT: UILabel!
    @IBOutlet var swtNhanvienPLT: UISwitch!
    @IBOutlet var lblNhanvienTD: UILabel!
    @IBOutlet var swtNhanvienTD: UISwitch!
    @IBOutlet var lblNhanvienTT: UILabel!
    @IBOutlet var swtNhanvienTT: UISwitch!
    @IBOutlet var lblNhanvienDKMD: UILabel!
    @IBOutlet var swtNhanvienDKMD: UISwitch!
    @IBOutlet var lblNhanvienTBCTG: UILabel!
    @IBOutlet var swtNhanvienTBCTG: UISwitch!
    @IBOutlet var lblTrungtam: UILabel!
    @IBOutlet var swtTrungtam: UISwitch!
    @IBOutlet var viewTrungtam: UIView!
    @IBOutlet var consTrungtamViewHeight: NSLayoutConstraint!
    //    @IBOutlet var consTrungtamViewHeightEmpty: NSLayoutConstraint!
    @IBOutlet var lblTrungtamSHLX: UILabel!
    @IBOutlet var swtTrungtamSHLX: UISwitch!
    @IBOutlet var lblTrungtamDK: UILabel!
    @IBOutlet var swtTrungtamDK: UISwitch!
    @IBOutlet var lblCosodaotaolaixe: UILabel!
    @IBOutlet var swtCosodaotaolaixe: UISwitch!
    @IBOutlet var lblGa: UILabel!
    @IBOutlet var swtGa: UISwitch!
    @IBOutlet var btnXong: UIButton!
    
    @IBOutlet var consBtnOtoWidth: NSLayoutConstraint!
    @IBOutlet var consBtnXemayWidth: NSLayoutConstraint!
    @IBOutlet var consBtnXechuyendungWidth: NSLayoutConstraint!
    @IBOutlet var consBtnTauhoaWidth: NSLayoutConstraint!
    @IBOutlet var consBtnXedapWidth: NSLayoutConstraint!
    @IBOutlet var consBtnDiboWidth: NSLayoutConstraint!
    @IBOutlet var consScrollviewWidth: NSLayoutConstraint!
    
    
    var root = MPSearchTableController()
    var appearanceUtil = AppearanceUtil()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        consScrollviewWidth.constant = self.view.frame.size.width
        consMucphatViewWidth.constant = self.view.frame.size.width
        // Do any additional setup after loading the view.
        initFilters()
        
        //temporarily hidden Doituong filters
        lblDoituong.isHidden = true
        swtDoituong.isHidden = true
        
        //enable this initialization will cause the layout to be broken (wider than actual size)
        //        initPhuongtienButtons()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initFilters() {
        if root.searchFilters["Mucphat"]!["den"]!["chon"] != "0" && root.searchFilters["Mucphat"]!["tu"]!["chon"] != "0" {
            enableMucphatFilter(enable: true)
            btnTu.setTitle("\(root.searchFilters["Mucphat"]!["tu"]!["chon"]!)", for: .normal)
            btnDen.setTitle("\(root.searchFilters["Mucphat"]!["den"]!["chon"]!)", for: .normal)
        }else{
            enableMucphatFilter(enable: false)
        }
        
        if root.searchFilters["Phuongtien"]!["Oto"]!["chon"] != "0" || root.searchFilters["Phuongtien"]!["Xemay"]!["chon"] != "0" || root.searchFilters["Phuongtien"]!["Xechuyendung"]!["chon"] != "0" || root.searchFilters["Phuongtien"]!["Tauhoa"]!["chon"] != "0" || root.searchFilters["Phuongtien"]!["Xedap"]!["chon"] != "0" || root.searchFilters["Phuongtien"]!["Dibo"]!["chon"] != "0" {
            enablePhuongtienFilter(enable: true)
            initPhuongtienButtons()
        }else{
            enablePhuongtienFilter(enable: false)
        }
        //        if root.searchFilters["Doituong"]!["Canhan"]!["Chuphuongtien"] != "0" || root.searchFilters["Doituong"]!["Canhan"]!["NDK"] != "0" || root.searchFilters["Doituong"]!["Canhan"]!["NDX"] != "0" || root.searchFilters["Doituong"]!["Canhan"]!["GVDLX"] != "0" || root.searchFilters["Doituong"]!["Canhan"]!["KDVT"] != "0" || root.searchFilters["Doituong"]!["Tochuc"]!["KDVT"] != "0" || root.searchFilters["Doituong"]!["Tochuc"]!["KDDS"] != "0" || root.searchFilters["Doituong"]!["Tochuc"]!["TPDB"] != "0" || root.searchFilters["Doituong"]!["Tochuc"]!["TTKDVTDS"] != "0" || root.searchFilters["Doituong"]!["Tochuc"]!["QLKTPTDS"] != "0" || root.searchFilters["Doituong"]!["Tochuc"]!["QLKTBTHTDB"] != "0" || root.searchFilters["Doituong"]!["Tochuc"]!["QLKTBTHTDS"] != "0" || root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDKB"] != "0" || root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDSXLR"] != "0" || root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDVTDS"] != "0" || root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDXDHH"] != "0" || root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDKCHTDS"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["DKV"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["NVTTDK"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["GC"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["KX"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["TH"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["PV"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["DDCT"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["DS"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["GN"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["LT"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["PLT"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["TD"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["TT"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["DKMD"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["TBCTG"] != "0" || root.searchFilters["Doituong"]!["Trungtam"]!["SHLX"] != "0" || root.searchFilters["Doituong"]!["Trungtam"]!["DK"] != "0" || root.searchFilters["Doituong"]!["Cosodaotaolaixe"]!["chon"] != "0" || root.searchFilters["Doituong"]!["Ga"]!["chon"] != "0" {
        //            enableDoituongFilter(enable: true)
        //        }else{
        enableDoituongFilter(enable: false)
        //        }
    }
    
    func initPhuongtienButtons() {
        let buttonWidth = (self.view.frame.size.width/3) - 3
        consBtnOtoWidth.constant = buttonWidth
        updatePhuongtienButtonState(button: btnOto, state: root.searchFilters["Phuongtien"]!["Oto"]!["chon"] != "0")
        consBtnXemayWidth.constant = buttonWidth
        updatePhuongtienButtonState(button: btnXemay, state: root.searchFilters["Phuongtien"]!["Xemay"]!["chon"] != "0")
        consBtnXechuyendungWidth.constant = buttonWidth
        updatePhuongtienButtonState(button: btnXechuyendung, state: root.searchFilters["Phuongtien"]!["Xechuyendung"]!["chon"] != "0")
        consBtnTauhoaWidth.constant = buttonWidth
        updatePhuongtienButtonState(button: btnTauhoa, state: root.searchFilters["Phuongtien"]!["Tauhoa"]!["chon"] != "0")
        consBtnXedapWidth.constant = buttonWidth
        updatePhuongtienButtonState(button: btnXedap, state: root.searchFilters["Phuongtien"]!["Xedap"]!["chon"] != "0")
        consBtnDiboWidth.constant = buttonWidth
        updatePhuongtienButtonState(button: btnDibo, state: root.searchFilters["Phuongtien"]!["Dibo"]!["chon"] != "0")
        consScrollviewWidth.constant = self.view.frame.size.width
        
    }
    
    @IBAction func btnOtoAction(_ sender: Any) {
        updatePhuongtienButtonState(button: btnOto, state: root.searchFilters["Phuongtien"]!["Oto"]!["chon"] == "0")
        if root.searchFilters["Phuongtien"]!["Oto"]!["chon"] == "0" {
            root.searchFilters["Phuongtien"]!["Oto"]!["chon"] = "1"
        }else{
            root.searchFilters["Phuongtien"]!["Oto"]!["chon"] = "0"
        }
    }
    
    @IBAction func btnXemayAction(_ sender: Any) {
        updatePhuongtienButtonState(button: btnXemay, state: root.searchFilters["Phuongtien"]!["Xemay"]!["chon"] == "0")
        if root.searchFilters["Phuongtien"]!["Xemay"]!["chon"] == "0" {
            root.searchFilters["Phuongtien"]!["Xemay"]!["chon"] = "1"
        }else{
            root.searchFilters["Phuongtien"]!["Xemay"]!["chon"] = "0"
        }
    }
    
    @IBAction func btnXechuyendungAction(_ sender: Any) {
        updatePhuongtienButtonState(button: btnXechuyendung, state: root.searchFilters["Phuongtien"]!["Xechuyendung"]!["chon"] == "0")
        if root.searchFilters["Phuongtien"]!["Xechuyendung"]!["chon"] == "0" {
            root.searchFilters["Phuongtien"]!["Xechuyendung"]!["chon"] = "1"
        }else{
            root.searchFilters["Phuongtien"]!["Xechuyendung"]!["chon"] = "0"
        }
    }
    
    @IBAction func btnTauhoaAction(_ sender: Any) {
        updatePhuongtienButtonState(button: btnTauhoa, state: root.searchFilters["Phuongtien"]!["Tauhoa"]!["chon"] == "0")
        if root.searchFilters["Phuongtien"]!["Tauhoa"]!["chon"] == "0" {
            root.searchFilters["Phuongtien"]!["Tauhoa"]!["chon"] = "1"
        }else{
            root.searchFilters["Phuongtien"]!["Tauhoa"]!["chon"] = "0"
        }
    }
    
    @IBAction func btnXedapAction(_ sender: Any) {
        updatePhuongtienButtonState(button: btnXedap, state: root.searchFilters["Phuongtien"]!["Xedap"]!["chon"] == "0")
        if root.searchFilters["Phuongtien"]!["Xedap"]!["chon"] == "0" {
            root.searchFilters["Phuongtien"]!["Xedap"]!["chon"] = "1"
        }else{
            root.searchFilters["Phuongtien"]!["Xedap"]!["chon"] = "0"
        }
    }
    
    @IBAction func btnDiboAction(_ sender: Any) {
        updatePhuongtienButtonState(button: btnDibo, state: root.searchFilters["Phuongtien"]!["Dibo"]!["chon"] == "0")
        if root.searchFilters["Phuongtien"]!["Dibo"]!["chon"] == "0" {
            root.searchFilters["Phuongtien"]!["Dibo"]!["chon"] = "1"
        }else{
            root.searchFilters["Phuongtien"]!["Dibo"]!["chon"] = "0"
        }
    }
    
    @IBAction func swtMucphatAction(_ sender: Any) {
        enableMucphatFilter(enable: swtMucphat.isOn)
        if !swtMucphat.isOn {
            root.searchFilters["Mucphat"]!["den"]!["chon"] = "0"
            root.searchFilters["Mucphat"]!["tu"]!["chon"] = "0"
            updateMucphatTu(tu: root.searchFilters["Mucphat"]!["tu"]!["chon"]!)
            updateMucphatDen(den: root.searchFilters["Mucphat"]!["den"]!["chon"]!)
        }
        grayoutOptionText(label: lblMucphat, enable: swtMucphat.isOn)
    }
    
    @IBAction func swtPhuongtienAction(_ sender: Any) {
        enablePhuongtienFilter(enable: swtPhuongtien.isOn)
        if !swtPhuongtien.isOn {
            root.searchFilters["Phuongtien"]!["Oto"]!["chon"] = "0"
            root.searchFilters["Phuongtien"]!["Xemay"]!["chon"] = "0"
            root.searchFilters["Phuongtien"]!["Xechuyendung"]!["chon"] = "0"
            root.searchFilters["Phuongtien"]!["Tauhoa"]!["chon"] = "0"
            root.searchFilters["Phuongtien"]!["Xedap"]!["chon"] = "0"
            root.searchFilters["Phuongtien"]!["Dibo"]!["chon"] = "0"
        }else{
            initPhuongtienButtons()
        }
        grayoutOptionText(label: lblPhuongtien, enable: swtPhuongtien.isOn)
    }
    
    @IBAction func swtDoituongAction(_ sender: Any) {
        enableDoituongFilter(enable: swtDoituong.isOn)
        grayoutOptionText(label: lblDoituong, enable: swtDoituong.isOn)
    }
    
    @IBAction func swtCanhanAction(_ sender: Any) {
        enableDoituongCanhanFilter(enable: swtCanhan.isOn)
        grayoutOptionText(label: lblCanhan, enable: swtCanhan.isOn)
    }
    
    @IBAction func swtCanhanChuphuongtienAction(_ sender: Any) {
        updateOptionText(label: lblChuphuongtien, enable: swtChuphuongtien.isOn)
        if swtChuphuongtien.isOn {
            root.searchFilters["Doituong"]!["Canhan"]!["Chuphuongtien"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Canhan"]!["Chuphuongtien"] = "0"
        }
    }
    
    @IBAction func swtCanhanNguoidieukhienAction(_ sender: Any) {
        updateOptionText(label: lblCanhanNDK, enable: swtCanhanNDK.isOn)
        if swtCanhanNDK.isOn {
            root.searchFilters["Doituong"]!["Canhan"]!["NDK"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Canhan"]!["NDK"] = "0"
        }
    }
    
    @IBAction func swtCanhanNguoiduaxeAction(_ sender: Any) {
        updateOptionText(label: lblCanhanNDX, enable: swtCanhanNDX.isOn)
        if swtCanhanNDX.isOn {
            root.searchFilters["Doituong"]!["Canhan"]!["NDX"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Canhan"]!["NDX"] = "0"
        }
    }
    
    @IBAction func swtCanhanGiaovienlaixeAction(_ sender: Any) {
        updateOptionText(label: lblCanhanGVDLX, enable: swtCanhanGVDLX.isOn)
        if swtCanhanGVDLX.isOn {
            root.searchFilters["Doituong"]!["Canhan"]!["GVDLX"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Canhan"]!["GVDLX"] = "0"
        }
    }
    
    @IBAction func swtCanhanKDVTAction(_ sender: Any) {
        updateOptionText(label: lblCanhanKDVT, enable: swtCanhanKDVT.isOn)
        if swtCanhanKDVT.isOn {
            root.searchFilters["Doituong"]!["Canhan"]!["KDVT"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Canhan"]!["KDVT"] = "0"
        }
    }
    
    @IBAction func swtTochucAction(_ sender: Any) {
        enableDoituongTochucFilter(enable: swtTochuc.isOn)
        grayoutOptionText(label: lblTochuc, enable: swtTochuc.isOn)
    }
    
    @IBAction func swtTochucKDVTAction(_ sender: Any) {
        updateOptionText(label: lblTochucKDVT, enable: swtTochucKDVT.isOn)
        if swtTochucKDVT.isOn {
            root.searchFilters["Doituong"]!["Tochuc"]!["KDVT"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Tochuc"]!["KDVT"] = "0"
        }
    }
    
    @IBAction func swtTochucQLKDDSAction(_ sender: Any) {
        updateOptionText(label: lblTochucKDDS, enable: swtTochucKDDS.isOn)
        if swtTochucKDDS.isOn {
            root.searchFilters["Doituong"]!["Tochuc"]!["KDDS"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Tochuc"]!["KDDS"] = "0"
        }
    }
    
    @IBAction func swtTochucTPDBAction(_ sender: Any) {
        updateOptionText(label: lblTochucTPDB, enable: swtTochucTPDB.isOn)
        if swtTochucTPDB.isOn {
            root.searchFilters["Doituong"]!["Tochuc"]!["TPDB"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Tochuc"]!["TPDB"] = "0"
        }
    }
    
    @IBAction func swtTochucTTKDDSAction(_ sender: Any) {
        updateOptionText(label: lblTochucTTKDVTDS, enable: swtTochucTTKDVTDS.isOn)
        if swtTochucTTKDVTDS.isOn {
            root.searchFilters["Doituong"]!["Tochuc"]!["TTKDVTDS"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Tochuc"]!["TTKDVTDS"] = "0"
        }
    }
    
    @IBAction func swtTochucQLKTPTDSAction(_ sender: Any) {
        updateOptionText(label: lblTochucTTQLKTPTDS, enable: swtTochucTTQLKTPTDS.isOn)
        if swtTochucTTQLKTPTDS.isOn {
            root.searchFilters["Doituong"]!["Tochuc"]!["QLKTPTDS"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Tochuc"]!["QLKTPTDS"] = "0"
        }
    }
    
    @IBAction func swtTochucQLKTBTHTDSAction(_ sender: Any) {
        updateOptionText(label: lblTochucQLKTBTHTDS, enable: swtTochucQLKTBTHTDS.isOn)
        if swtTochucQLKTBTHTDS.isOn {
            root.searchFilters["Doituong"]!["Tochuc"]!["QLKTBTHTDS"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Tochuc"]!["QLKTBTHTDS"] = "0"
        }
    }
    
    @IBAction func swtTochucQLKTBTHTDBAction(_ sender: Any) {
        updateOptionText(label: lblTochucQLKTBTHTDB, enable: swtTochucQLKTBTHTDB.isOn)
        if swtTochucQLKTBTHTDB.isOn {
            root.searchFilters["Doituong"]!["Tochuc"]!["QLKTBTHTDB"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Tochuc"]!["QLKTBTHTDB"] = "0"
        }
    }
    
    @IBAction func swtDoanhnghiepAction(_ sender: Any) {
        enableDoituongDoanhnghiepFilter(enable: swtDoanhnghiep.isOn)
        grayoutOptionText(label: lblDoanhnghiep, enable: swtDoanhnghiep.isOn)
    }
    
    @IBAction func swtDoanhnghiepKDKBAction(_ sender: Any) {
        updateOptionText(label: lblDoanhnghiepKDKB, enable: swtDoanhnghiepKDKB.isOn)
        if swtDoanhnghiepKDKB.isOn {
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDKB"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDKB"] = "0"
        }
    }
    
    @IBAction func swtDoanhnghiepSXLRAction(_ sender: Any) {
        updateOptionText(label: lblDoanhnghiepKDSXLR, enable: swtDoanhnghiepKDSXLR.isOn)
        if swtDoanhnghiepKDSXLR.isOn {
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDSXLR"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDSXLR"] = "0"
        }
    }
    
    @IBAction func swtDoanhnghiepKDVTDSAction(_ sender: Any) {
        updateOptionText(label: lblDoanhnghiepKDVTDS, enable: swtDoanhnghiepKDVTDS.isOn)
        if swtDoanhnghiepKDVTDS.isOn {
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDVTDS"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDVTDS"] = "0"
        }
    }
    
    @IBAction func swtDoanhnghiepKDXDHHAction(_ sender: Any) {
        updateOptionText(label: lblDoanhnghiepKDXDHH, enable: swtDoanhnghiepKDXDHH.isOn)
        if swtDoanhnghiepKDXDHH.isOn {
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDXDHH"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDXDHH"] = "0"
        }
    }
    
    @IBAction func swtDoanhnghiepKDKCHTDSAction(_ sender: Any) {
        updateOptionText(label: lblDoanhnghiepKDKCHTDS, enable: swtDoanhnghiepKDKCHTDS.isOn)
        if swtDoanhnghiepKDKCHTDS.isOn {
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDKCHTDS"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDKCHTDS"] = "0"
        }
    }
    
    @IBAction func swtNhanvienAction(_ sender: Any) {
        enableDoituongNhanvienFilter(enable: swtNhanvien.isOn)
        grayoutOptionText(label: lblNhanvien, enable: swtNhanvien.isOn)
    }
    
    @IBAction func swtNhanvienDKVAction(_ sender: Any) {
        updateOptionText(label: lblNhanvienDKV, enable: swtNhanvienDKV.isOn)
        if swtNhanvienDKV.isOn {
            root.searchFilters["Doituong"]!["Nhanvien"]!["DKV"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Nhanvien"]!["DKV"] = "0"
        }
    }
    
    @IBAction func swtNhanvienNVDKAction(_ sender: Any) {
        updateOptionText(label: lblNhanvienNVTTDK, enable: swtNhanvienNVTTDK.isOn)
        if swtNhanvienNVTTDK.isOn {
            root.searchFilters["Doituong"]!["Nhanvien"]!["NVTTDK"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Nhanvien"]!["NVTTDK"] = "0"
        }
    }
    
    @IBAction func swtNhanvienGCAction(_ sender: Any) {
        updateOptionText(label: lblNhanvienGC, enable: swtNhanvienGC.isOn)
        if swtNhanvienGC.isOn {
            root.searchFilters["Doituong"]!["Nhanvien"]!["GC"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Nhanvien"]!["GC"] = "0"
        }
    }
    
    @IBAction func swtNhanvienKXAction(_ sender: Any) {
        updateOptionText(label: lblNhanvienKX, enable: swtNhanvienKX.isOn)
        if swtNhanvienKX.isOn {
            root.searchFilters["Doituong"]!["Nhanvien"]!["KX"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Nhanvien"]!["KX"] = "0"
        }
    }
    
    @IBAction func swtNhanvienKXTHAction(_ sender: Any) {
        updateOptionText(label: lblNhanvienTH, enable: swtNhanvienTH.isOn)
        if swtNhanvienTH.isOn {
            root.searchFilters["Doituong"]!["Nhanvien"]!["TH"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Nhanvien"]!["TH"] = "0"
        }
    }
    
    @IBAction func swtNhanvienPVAction(_ sender: Any) {
        updateOptionText(label: lblNhanvienPV, enable: swtNhanvienPV.isOn)
        if swtNhanvienPV.isOn {
            root.searchFilters["Doituong"]!["Nhanvien"]!["PV"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Nhanvien"]!["PV"] = "0"
        }
    }
    
    @IBAction func swtNhanvienDDCTAction(_ sender: Any) {
        updateOptionText(label: lblNhanvienDDCT, enable: swtNhanvienDDCT.isOn)
        if swtNhanvienDDCT.isOn {
            root.searchFilters["Doituong"]!["Nhanvien"]!["DDCT"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Nhanvien"]!["DDCT"] = "0"
        }
    }
    
    @IBAction func swtNhanvienDSAction(_ sender: Any) {
        updateOptionText(label: lblNhanvienDS, enable: swtNhanvienDS.isOn)
        if swtNhanvienDS.isOn {
            root.searchFilters["Doituong"]!["Nhanvien"]!["DS"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Nhanvien"]!["DS"] = "0"
        }
    }
    
    @IBAction func swtNhanvienGNAction(_ sender: Any) {
        updateOptionText(label: lblNhanvienGN, enable: swtNhanvienGN.isOn)
        if swtNhanvienGN.isOn {
            root.searchFilters["Doituong"]!["Nhanvien"]!["GN"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Nhanvien"]!["GN"] = "0"
        }
    }
    
    @IBAction func swtNhanvienLTAction(_ sender: Any) {
        updateOptionText(label: lblNhanvienLT, enable: swtNhanvienLT.isOn)
        if swtNhanvienLT.isOn {
            root.searchFilters["Doituong"]!["Nhanvien"]!["LT"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Nhanvien"]!["LT"] = "0"
        }
    }
    
    @IBAction func swtNhanvienPLTAction(_ sender: Any) {
        updateOptionText(label: lblNhanvienPLT, enable: swtNhanvienPLT.isOn)
        if swtNhanvienPLT.isOn {
            root.searchFilters["Doituong"]!["Nhanvien"]!["PLT"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Nhanvien"]!["PLT"] = "0"
        }
    }
    
    @IBAction func swtNhanvienTDAction(_ sender: Any) {
        updateOptionText(label: lblNhanvienTD, enable: swtNhanvienTD.isOn)
        if swtNhanvienTD.isOn {
            root.searchFilters["Doituong"]!["Nhanvien"]!["TD"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Nhanvien"]!["TD"] = "0"
        }
    }
    
    @IBAction func swtNhanvienTTAction(_ sender: Any) {
        updateOptionText(label: lblNhanvienTT, enable: swtNhanvienTT.isOn)
        if swtNhanvienTT.isOn {
            root.searchFilters["Doituong"]!["Nhanvien"]!["TT"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Nhanvien"]!["TT"] = "0"
        }
    }
    
    @IBAction func swtNhanvienDKMDAction(_ sender: Any) {
        updateOptionText(label: lblNhanvienDKMD, enable: swtNhanvienDKMD.isOn)
        if swtNhanvienDKMD.isOn {
            root.searchFilters["Doituong"]!["Nhanvien"]!["DKMD"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Nhanvien"]!["DKMD"] = "0"
        }
    }
    
    @IBAction func swtNhanvienTBCTAction(_ sender: Any) {
        updateOptionText(label: lblNhanvienTBCTG, enable: swtNhanvienTBCTG.isOn)
        if swtNhanvienTBCTG.isOn {
            root.searchFilters["Doituong"]!["Nhanvien"]!["TBCTG"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Nhanvien"]!["TBCTG"] = "0"
        }
    }
    
    @IBAction func swtTrungtamAction(_ sender: Any) {
        enableDoituongTrungtamFilter(enable: swtTrungtam.isOn)
        grayoutOptionText(label: lblTrungtam, enable: swtTrungtam.isOn)
    }
    
    @IBAction func swtTrungtamSHLXAction(_ sender: Any) {
        updateOptionText(label: lblTrungtamSHLX, enable: swtTrungtamSHLX.isOn)
        if swtTrungtamSHLX.isOn {
            root.searchFilters["Doituong"]!["Trungtam"]!["SHLX"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Trungtam"]!["SHLX"] = "0"
        }
    }
    
    @IBAction func swtTrungtamDKAction(_ sender: Any) {
        updateOptionText(label: lblTrungtamDK, enable: swtTrungtamDK.isOn)
        if swtTrungtamDK.isOn {
            root.searchFilters["Doituong"]!["Trungtam"]!["DK"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Trungtam"]!["DK"] = "0"
        }
    }
    
    @IBAction func swtCosodaotaolaixeAction(_ sender: Any) {
        grayoutOptionText(label: lblCosodaotaolaixe, enable: swtCosodaotaolaixe.isOn)
        if swtCosodaotaolaixe.isOn {
            root.searchFilters["Doituong"]!["Cosodaotaolaixe"]!["chon"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Cosodaotaolaixe"]!["chon"] = "0"
        }
    }
    
    @IBAction func swtGaAction(_ sender: Any) {
        grayoutOptionText(label: lblGa, enable: swtGa.isOn)
        if swtGa.isOn {
            root.searchFilters["Doituong"]!["Ga"]!["chon"] = "1"
        }else{
            root.searchFilters["Doituong"]!["Ga"]!["chon"] = "0"
        }
    }
    
    func updateActiveFilterList(root: MPSearchTableController) {
        self.root = root
    }
    
    func enableMucphatFilter(enable: Bool) {
        if enable {
            swtMucphat.isOn = true
        }else{
            swtMucphat.isOn = false
        }
        grayoutOptionText(label: lblMucphat, enable: swtMucphat.isOn)
        updateMucphatView()
        consScrollviewWidth.constant = self.view.frame.size.width
    }
    
    func updateMucphatView() {
        consMucphatViewHeight.constant = 0
        if swtMucphat.isOn {
            //            consMucphatViewHeight.constant = 200
            consMucphatViewHeight.isActive = false
            //            consMucphatViewHeightEmpty.isActive = false
            viewMucphat.isHidden = false
        }else{
            consMucphatViewHeight.isActive = true
            //            consMucphatViewHeight.isActive = false
            //            consMucphatViewHeightEmpty.isActive = true
            viewMucphat.isHidden = true
        }
    }
    
    func enablePhuongtienFilter(enable: Bool) {
        if enable {
            swtPhuongtien.isOn = true
        }else{
            swtPhuongtien.isOn = false
        }
        grayoutOptionText(label: lblPhuongtien, enable: swtPhuongtien.isOn)
        updatePhuongtienView()
    }
    
    func updatePhuongtienView() {
        consPhuongtienViewHeight.constant = 0
        if swtPhuongtien.isOn {
            consPhuongtienViewHeight.isActive = false
            //            consPhuongtienViewHeightEmpty.isActive = false
            viewPhuongtien.isHidden = false
        }else{
            consPhuongtienViewHeight.isActive = true
            //            consPhuongtienViewHeightEmpty.isActive = true
            viewPhuongtien.isHidden = true
        }
    }
    
    func enableDoituongFilter(enable: Bool) {
        if enable {
            swtDoituong.isOn = true
        }else{
            swtDoituong.isOn = false
        }
        grayoutOptionText(label: lblDoituong, enable: swtDoituong.isOn)
        updateDoituongView()
    }
    
    func updateDoituongView() {
        consDoituongViewHeight.constant = 0
        if swtDoituong.isOn {
            consDoituongViewHeight.isActive = false
            //            consDoituongViewHeightEmpty.isActive = false
            viewDoituong.isHidden = false
            
            //            enableDoituongCanhanFilter(enable: root.searchFilters["Doituong"]!["Canhan"]!["Chuphuongtien"] != "0" || root.searchFilters["Doituong"]!["Canhan"]!["NDK"] != "0" || root.searchFilters["Doituong"]!["Canhan"]!["NDX"] != "0" || root.searchFilters["Doituong"]!["Canhan"]!["GVDLX"] != "0" || root.searchFilters["Doituong"]!["Canhan"]!["KDVT"] != "0")
            //            enableDoituongTochucFilter(enable: root.searchFilters["Doituong"]!["Tochuc"]!["KDVT"] != "0" || root.searchFilters["Doituong"]!["Tochuc"]!["KDDS"] != "0" || root.searchFilters["Doituong"]!["Tochuc"]!["TPDB"] != "0" || root.searchFilters["Doituong"]!["Tochuc"]!["TTKDVTDS"] != "0" || root.searchFilters["Doituong"]!["Tochuc"]!["QLKTPTDS"] != "0" || root.searchFilters["Doituong"]!["Tochuc"]!["QLKTBTHTDB"] != "0" || root.searchFilters["Doituong"]!["Tochuc"]!["QLKTBTHTDS"] != "0")
            //            enableDoituongDoanhnghiepFilter(enable: root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDKB"] != "0" || root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDSXLR"] != "0" || root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDVTDS"] != "0" || root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDXDHH"] != "0" || root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDKCHTDS"] != "0")
            //            enableDoituongNhanvienFilter(enable: root.searchFilters["Doituong"]!["Nhanvien"]!["DKV"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["NVTTDK"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["GC"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["KX"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["TH"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["PV"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["DDCT"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["DS"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["GN"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["LT"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["PLT"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["TD"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["TT"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["DKMD"] != "0" || root.searchFilters["Doituong"]!["Nhanvien"]!["TBCTG"] != "0")
            //            enableDoituongTrungtamFilter(enable: root.searchFilters["Doituong"]!["Trungtam"]!["SHLX"] != "0" || root.searchFilters["Doituong"]!["Trungtam"]!["DK"] != "0")
            //            swtCosodaotaolaixe.isOn = (root.searchFilters["Doituong"]!["Cosodaotaolaixe"]!["chon"] != "0")
            //            swtGa.isOn = (root.searchFilters["Doituong"]!["Ga"]!["chon"] != "0")
        }else{
            consDoituongViewHeight.isActive = true
            //            consDoituongViewHeightEmpty.isActive = true
            viewDoituong.isHidden = true
            
            enableDoituongCanhanFilter(enable: false)
            enableDoituongTochucFilter(enable: false)
            enableDoituongDoanhnghiepFilter(enable: false)
            enableDoituongNhanvienFilter(enable: false)
            enableDoituongTrungtamFilter(enable: false)
            swtCosodaotaolaixe.isOn = false
            swtGa.isOn = false
        }
    }
    
    func enableDoituongCanhanFilter(enable: Bool) {
        if enable {
            swtCanhan.isOn = true
        }else{
            swtCanhan.isOn = false
        }
        updateDoituongCanhanView()
    }
    
    func updateDoituongCanhanView() {
        consCanhanViewHeight.constant = 0
        if swtCanhan.isOn {
            consCanhanViewHeight.isActive = false
            //            consCanhanViewHeightEmpty.isActive = false
            viewCanhan.isHidden = false
        }else{
            consCanhanViewHeight.isActive = true
            //            consCanhanViewHeightEmpty.isActive = true
            viewCanhan.isHidden = true
        }
        updateCanhanChildrenFilters()
        viewCanhan.setNeedsDisplay()
        viewDoituong.setNeedsDisplay()
    }
    
    func enableDoituongTochucFilter(enable: Bool) {
        if enable {
            swtTochuc.isOn = true
        }else{
            swtTochuc.isOn = false
        }
        updateDoituongTochucView()
    }
    
    func updateDoituongTochucView() {
        consTochucViewHeight.constant = 0
        if swtTochuc.isOn {
            consTochucViewHeight.isActive = false
            //            consTochucViewHeightEmpty.isActive = false
            viewTochuc.isHidden = false
        }else{
            consTochucViewHeight.isActive = true
            //            consTochucViewHeightEmpty.isActive = true
            viewTochuc.isHidden = true
        }
        updateTochucChildrenFilters(enable: swtTochuc.isOn)
    }
    
    func enableDoituongDoanhnghiepFilter(enable: Bool) {
        if enable {
            swtDoanhnghiep.isOn = true
        }else{
            swtDoanhnghiep.isOn = false
        }
        updateDoituongDoanhnghiepView()
    }
    
    func updateDoituongDoanhnghiepView() {
        consDoanhnghiepViewHeight.constant = 0
        if swtDoanhnghiep.isOn {
            consDoanhnghiepViewHeight.isActive = false
            //            consDoanhnghiepViewHeightEmpty.isActive = false
            viewDoanhnghiep.isHidden = false
        }else{
            consDoanhnghiepViewHeight.isActive = true
            //            consDoanhnghiepViewHeightEmpty.isActive = true
            viewDoanhnghiep.isHidden = true
        }
        updateDoanhnghiepChildrenFilters(enable: swtDoanhnghiep.isOn)
    }
    
    func enableDoituongNhanvienFilter(enable: Bool) {
        if enable {
            swtNhanvien.isOn = true
        }else{
            swtNhanvien.isOn = false
        }
        updateDoituongNhanvienView()
    }
    
    func updateDoituongNhanvienView() {
        consNhanvienViewHeight.constant = 0
        if swtNhanvien.isOn {
            consNhanvienViewHeight.isActive = false
            //            consNhanvienViewHeightEmpty.isActive = false
            viewNhanvien.isHidden = false
        }else{
            consNhanvienViewHeight.isActive = true
            //            consNhanvienViewHeightEmpty.isActive = true
            viewNhanvien.isHidden = true
        }
        updateNhanvienChildrenFilters(enable: swtNhanvien.isOn)
    }
    
    func enableDoituongTrungtamFilter(enable: Bool) {
        if enable {
            swtTrungtam.isOn = true
        }else{
            swtTrungtam.isOn = false
        }
        updateDoituongTrungtamView()
    }
    
    func updateDoituongTrungtamView() {
        consTrungtamViewHeight.constant = 0
        if swtTrungtam.isOn {
            consTrungtamViewHeight.isActive = false
            //            consTrungtamViewHeightEmpty.isActive = false
            viewTrungtam.isHidden = false
        }else{
            consTrungtamViewHeight.isActive = true
            //            consTrungtamViewHeightEmpty.isActive = true
            viewTrungtam.isHidden = true
        }
        updateTrungtamChildrenFilters(enable: swtTrungtam.isOn)
    }
    
    func updateCanhanChildrenFilters() {
        swtCanhanNDK.isOn = (root.searchFilters["Doituong"]!["Canhan"]!["NDK"] != "0")
        swtCanhanNDX.isOn = (root.searchFilters["Doituong"]!["Canhan"]!["NDX"] != "0")
        swtCanhanKDVT.isOn = (root.searchFilters["Doituong"]!["Canhan"]!["KDVT"] != "0")
        swtCanhanGVDLX.isOn = (root.searchFilters["Doituong"]!["Canhan"]!["GVDLX"] != "0")
        swtChuphuongtien.isOn = (root.searchFilters["Doituong"]!["Canhan"]!["Chuphuongtien"] != "0")
        
        updateOptionText(label: lblCanhanNDK, enable: swtCanhanNDK.isOn)
        updateOptionText(label: lblCanhanNDX, enable: swtCanhanNDX.isOn)
        updateOptionText(label: lblCanhanKDVT, enable: swtCanhanKDVT.isOn)
        updateOptionText(label: lblCanhanGVDLX, enable: swtCanhanGVDLX.isOn)
        updateOptionText(label: lblChuphuongtien, enable: swtChuphuongtien.isOn)
    }
    
    func updateTochucChildrenFilters(enable: Bool){
        if enable {
            swtTochucKDDS.isOn = true
            swtTochucKDVT.isOn = true
            swtTochucTPDB.isOn = true
            swtTochucTTKDVTDS.isOn = true
            swtTochucQLKTBTHTDB.isOn = true
            swtTochucQLKTBTHTDS.isOn = true
            swtTochucTTQLKTPTDS.isOn = true
            
            root.searchFilters["Doituong"]!["Tochuc"]!["KDVT"] = "1"
            root.searchFilters["Doituong"]!["Tochuc"]!["KDDS"] = "1"
            root.searchFilters["Doituong"]!["Tochuc"]!["TPDB"] = "1"
            root.searchFilters["Doituong"]!["Tochuc"]!["TTKDVTDS"] = "1"
            root.searchFilters["Doituong"]!["Tochuc"]!["QLKTPTDS"] = "1"
            root.searchFilters["Doituong"]!["Tochuc"]!["QLKTBTHTDB"] = "1"
            root.searchFilters["Doituong"]!["Tochuc"]!["QLKTBTHTDS"] = "1"
        }else{
            swtTochucKDDS.isOn = false
            swtTochucKDVT.isOn = false
            swtTochucTPDB.isOn = false
            swtTochucTTKDVTDS.isOn = false
            swtTochucQLKTBTHTDB.isOn = false
            swtTochucQLKTBTHTDS.isOn = false
            swtTochucTTQLKTPTDS.isOn = false
            
            root.searchFilters["Doituong"]!["Tochuc"]!["KDVT"] = "0"
            root.searchFilters["Doituong"]!["Tochuc"]!["KDDS"] = "0"
            root.searchFilters["Doituong"]!["Tochuc"]!["TPDB"] = "0"
            root.searchFilters["Doituong"]!["Tochuc"]!["TTKDVTDS"] = "0"
            root.searchFilters["Doituong"]!["Tochuc"]!["QLKTPTDS"] = "0"
            root.searchFilters["Doituong"]!["Tochuc"]!["QLKTBTHTDB"] = "0"
            root.searchFilters["Doituong"]!["Tochuc"]!["QLKTBTHTDS"] = "0"
        }
        
        updateOptionText(label: lblTochucKDDS, enable: swtTochucKDDS.isOn)
        updateOptionText(label: lblTochucKDVT, enable: swtTochucKDVT.isOn)
        updateOptionText(label: lblTochucTPDB, enable: swtTochucTPDB.isOn)
        updateOptionText(label: lblTochucTTKDVTDS, enable: swtTochucTTKDVTDS.isOn)
        updateOptionText(label: lblTochucQLKTBTHTDB, enable: swtTochucQLKTBTHTDB.isOn)
        updateOptionText(label: lblTochucQLKTBTHTDS, enable: swtTochucQLKTBTHTDS.isOn)
        updateOptionText(label: lblTochucTTQLKTPTDS, enable: swtTochucTTQLKTPTDS.isOn)
    }
    
    func updateDoanhnghiepChildrenFilters(enable: Bool) {
        if enable {
            swtDoanhnghiepKDKB.isOn = true
            swtDoanhnghiepKDSXLR.isOn = true
            swtDoanhnghiepKDVTDS.isOn = true
            swtDoanhnghiepKDXDHH.isOn = true
            swtDoanhnghiepKDKCHTDS.isOn = true
            
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDKB"] = "1"
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDSXLR"] = "1"
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDVTDS"] = "1"
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDXDHH"] = "1"
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDKCHTDS"] = "1"
        }else{
            swtDoanhnghiepKDKB.isOn = false
            swtDoanhnghiepKDSXLR.isOn = false
            swtDoanhnghiepKDVTDS.isOn = false
            swtDoanhnghiepKDXDHH.isOn = false
            swtDoanhnghiepKDKCHTDS.isOn = false
            
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDKB"] = "0"
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDSXLR"] = "0"
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDVTDS"] = "0"
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDXDHH"] = "0"
            root.searchFilters["Doituong"]!["Doanhnghiep"]!["KDKCHTDS"] = "0"
        }
        
        updateOptionText(label: lblDoanhnghiepKDKB, enable: swtDoanhnghiepKDKB.isOn)
        updateOptionText(label: lblDoanhnghiepKDSXLR, enable: swtDoanhnghiepKDSXLR.isOn)
        updateOptionText(label: lblDoanhnghiepKDVTDS, enable: swtDoanhnghiepKDVTDS.isOn)
        updateOptionText(label: lblDoanhnghiepKDXDHH, enable: swtDoanhnghiepKDXDHH.isOn)
        updateOptionText(label: lblDoanhnghiepKDKCHTDS, enable: swtDoanhnghiepKDKCHTDS.isOn)
    }
    
    func updateNhanvienChildrenFilters(enable: Bool) {
        if enable {
            swtNhanvienDS.isOn = true
            swtNhanvienGC.isOn = true
            swtNhanvienNVTTDK.isOn = true
            swtNhanvienGN.isOn = true
            swtNhanvienKX.isOn = true
            swtNhanvienLT.isOn = true
            swtNhanvienPV.isOn = true
            swtNhanvienTD.isOn = true
            swtNhanvienTH.isOn = true
            swtNhanvienTT.isOn = true
            swtNhanvienDKV.isOn = true
            swtNhanvienPLT.isOn = true
            swtNhanvienDDCT.isOn = true
            swtNhanvienDKMD.isOn = true
            swtNhanvienTBCTG.isOn = true
            
            root.searchFilters["Doituong"]!["Nhanvien"]!["DKV"] = "1"
            root.searchFilters["Doituong"]!["Nhanvien"]!["NVTTDK"] = "1"
            root.searchFilters["Doituong"]!["Nhanvien"]!["GC"] = "1"
            root.searchFilters["Doituong"]!["Nhanvien"]!["KX"] = "1"
            root.searchFilters["Doituong"]!["Nhanvien"]!["TH"] = "1"
            root.searchFilters["Doituong"]!["Nhanvien"]!["PV"] = "1"
            root.searchFilters["Doituong"]!["Nhanvien"]!["DDCT"] = "1"
            root.searchFilters["Doituong"]!["Nhanvien"]!["DS"] = "1"
            root.searchFilters["Doituong"]!["Nhanvien"]!["GN"] = "1"
            root.searchFilters["Doituong"]!["Nhanvien"]!["LT"] = "1"
            root.searchFilters["Doituong"]!["Nhanvien"]!["PLT"] = "1"
            root.searchFilters["Doituong"]!["Nhanvien"]!["TD"] = "1"
            root.searchFilters["Doituong"]!["Nhanvien"]!["TT"] = "1"
            root.searchFilters["Doituong"]!["Nhanvien"]!["DKMD"] = "1"
            root.searchFilters["Doituong"]!["Nhanvien"]!["TBCTG"] = "1"
        }else{
            swtNhanvienDS.isOn = false
            swtNhanvienGC.isOn = false
            swtNhanvienNVTTDK.isOn = false
            swtNhanvienGN.isOn = false
            swtNhanvienKX.isOn = false
            swtNhanvienLT.isOn = false
            swtNhanvienPV.isOn = false
            swtNhanvienTD.isOn = false
            swtNhanvienTH.isOn = false
            swtNhanvienTT.isOn = false
            swtNhanvienDKV.isOn = false
            swtNhanvienPLT.isOn = false
            swtNhanvienDDCT.isOn = false
            swtNhanvienDKMD.isOn = false
            swtNhanvienTBCTG.isOn = false
            
            root.searchFilters["Doituong"]!["Nhanvien"]!["DKV"] = "0"
            root.searchFilters["Doituong"]!["Nhanvien"]!["NVTTDK"] = "0"
            root.searchFilters["Doituong"]!["Nhanvien"]!["GC"] = "0"
            root.searchFilters["Doituong"]!["Nhanvien"]!["KX"] = "0"
            root.searchFilters["Doituong"]!["Nhanvien"]!["TH"] = "0"
            root.searchFilters["Doituong"]!["Nhanvien"]!["PV"] = "0"
            root.searchFilters["Doituong"]!["Nhanvien"]!["DDCT"] = "0"
            root.searchFilters["Doituong"]!["Nhanvien"]!["DS"] = "0"
            root.searchFilters["Doituong"]!["Nhanvien"]!["GN"] = "0"
            root.searchFilters["Doituong"]!["Nhanvien"]!["LT"] = "0"
            root.searchFilters["Doituong"]!["Nhanvien"]!["PLT"] = "0"
            root.searchFilters["Doituong"]!["Nhanvien"]!["TD"] = "0"
            root.searchFilters["Doituong"]!["Nhanvien"]!["TT"] = "0"
            root.searchFilters["Doituong"]!["Nhanvien"]!["DKMD"] = "0"
            root.searchFilters["Doituong"]!["Nhanvien"]!["TBCTG"] = "0"
        }
        
        updateOptionText(label: lblNhanvienDS, enable: swtNhanvienDS.isOn)
        updateOptionText(label: lblNhanvienGC, enable: swtNhanvienGC.isOn)
        updateOptionText(label: lblNhanvienNVTTDK, enable: swtNhanvienNVTTDK.isOn)
        updateOptionText(label: lblNhanvienGN, enable: swtNhanvienGN.isOn)
        updateOptionText(label: lblNhanvienKX, enable: swtNhanvienKX.isOn)
        updateOptionText(label: lblNhanvienLT, enable: swtNhanvienLT.isOn)
        updateOptionText(label: lblNhanvienPV, enable: swtNhanvienPV.isOn)
        updateOptionText(label: lblNhanvienTD, enable: swtNhanvienTD.isOn)
        updateOptionText(label: lblNhanvienTH, enable: swtNhanvienTH.isOn)
        updateOptionText(label: lblNhanvienTT, enable: swtNhanvienTT.isOn)
        updateOptionText(label: lblNhanvienDKV, enable: swtNhanvienDKV.isOn)
        updateOptionText(label: lblNhanvienPLT, enable: swtNhanvienPLT.isOn)
        updateOptionText(label: lblNhanvienDDCT, enable: swtNhanvienDDCT.isOn)
        updateOptionText(label: lblNhanvienDKMD, enable: swtNhanvienDKMD.isOn)
        updateOptionText(label: lblNhanvienTBCTG, enable: swtNhanvienTBCTG.isOn)
    }
    
    func updateTrungtamChildrenFilters(enable: Bool) {
        if enable {
            swtTrungtamDK.isOn = true
            swtTrungtamSHLX.isOn = true
            
            root.searchFilters["Doituong"]!["Trungtam"]!["SHLX"] = "1"
            root.searchFilters["Doituong"]!["Trungtam"]!["DK"] = "1"
        }else{
            swtTrungtamDK.isOn = false
            swtTrungtamSHLX.isOn = false
            
            root.searchFilters["Doituong"]!["Trungtam"]!["SHLX"] = "0"
            root.searchFilters["Doituong"]!["Trungtam"]!["DK"] = "0"
        }
        updateOptionText(label: lblTrungtamDK, enable: swtTrungtamDK.isOn)
        updateOptionText(label: lblTrungtamSHLX, enable: swtTrungtamSHLX.isOn)
    }
    
    func updateMucphatTu(tu: String) {
        root.searchFilters["Mucphat"]!["tu"]!["chon"] = tu
        btnTu.setTitle(tu, for: UIControlState.normal)
        
        switchMucphatTuDen()
    }
    
    func updateMucphatDen(den: String) {
        btnDen.setTitle(den, for: UIControlState.normal)
        root.searchFilters["Mucphat"]!["den"]!["chon"] = den
        
        switchMucphatTuDen()
    }
    
    func switchMucphatTuDen() {
        if root.searchFilters["Mucphat"]!["den"]!["chon"] != "0" && root.searchFilters["Mucphat"]!["tu"]!["chon"] != "0" {
            let den = Int(root.searchFilters["Mucphat"]!["den"]!["chon"]!.replacingOccurrences(of: ".", with: ""))
            let tu = Int(root.searchFilters["Mucphat"]!["tu"]!["chon"]!.replacingOccurrences(of: ".", with: ""))
            
            if tu! > den! {
                let newTu = root.searchFilters["Mucphat"]!["den"]!["chon"]!
                let newDen = root.searchFilters["Mucphat"]!["tu"]!["chon"]!
                root.searchFilters["Mucphat"]!["den"]!["chon"] = newDen
                root.searchFilters["Mucphat"]!["tu"]!["chon"] = newTu
                btnTu.setTitle(newTu, for: UIControlState.normal)
                btnDen.setTitle(newDen, for: UIControlState.normal)
            }
        }
    }
    
    func updateOptionText(label: UILabel, enable: Bool) {
        if enable {
            if #available(iOS 8.2, *) {
                appearanceUtil.changeLabelText(label: label, font: UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular), color: UIColor.black)
            } else {
                // Fallback on earlier versions
            }
        }else{
            if #available(iOS 8.2, *) {
                appearanceUtil.changeLabelText(label: label, font: UIFont.systemFont(ofSize: 15, weight: UIFontWeightThin), color: UIColor.gray)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func grayoutOptionText(label: UILabel, enable: Bool) {
        if enable {
            appearanceUtil.changeLabelText(label: label, color: UIColor.black)
        }else{
            appearanceUtil.changeLabelText(label: label, color: UIColor.gray)
        }
    }
    
    func updatePhuongtienButtonState(button: UIButton, state: Bool) {
        
        if state {
            button.backgroundColor = UIColor.blue
            button.setTitleColor(UIColor.white, for: .normal)
        }else{
            button.backgroundColor = UIColor.white
            button.setTitleColor(UIColor.blue, for: .normal)
        }
    }
    
    @IBAction func btnXongAction(_ sender: Any) {
        //Xong button
        root.updateFilterLabel()
        root.updateSearchResults(for: (root.searchController))
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "vanbanHome":
            guard segue.destination is VBPLHomeDetailsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
        case "mucphatTu":
            guard let pickerview = segue.destination as? PickerViewSelectPopup else {
                fatalError("Unexpected destination: \(segue.destination)")
                
            }
            
            pickerview.updateMucphat(root: self, target: "tu")
        case "mucphatDen":
            guard let pickerview = segue.destination as? PickerViewSelectPopup else {
                fatalError("Unexpected destination: \(segue.destination)")
                
            }
            
            pickerview.updateMucphat(root: self, target: "den")
            
            //        case "showDieukhoan":
            //            guard let dieukhoanDetails = segue.destination as? VBPLDetailsViewController else {
            //                fatalError("Unexpected destination: \(segue.destination)")
            //            }
            //
            //            guard let selectedDieukhoanCell = sender as? VBPLTableViewCell else {
            //                fatalError("Unexpected sender: \(String(describing: sender))")
            //            }
            //
            //            guard let indexPath = tblView.indexPath(for: selectedDieukhoanCell) else {
            //                fatalError("The selected cell is not being displayed by the table")
            //            }
            //
            //            let selectedDieukhoan = dieukhoanList[indexPath.row]
            //            dieukhoanDetails.updateDetails(dieukhoan: selectedDieukhoan)
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
        
    }
}
