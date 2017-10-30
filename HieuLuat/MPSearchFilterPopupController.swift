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
    @IBOutlet var consMucphatViewHeightEmpty: NSLayoutConstraint!
    @IBOutlet var consMucphatViewHeight: NSLayoutConstraint!
    @IBOutlet var lblTu: UILabel!
    @IBOutlet var btnTu: UIButton!
    @IBOutlet var lblDen: UILabel!
    @IBOutlet var btnDen: UIButton!
    @IBOutlet var lblPhuongtien: UILabel!
    @IBOutlet var swtPhuongtien: UISwitch!
    @IBOutlet var viewPhuongtien: UIView!
    @IBOutlet var consPhuongtienViewHeight: NSLayoutConstraint!
    @IBOutlet var consPhuongtienViewHeightEmpty: NSLayoutConstraint!
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
    @IBOutlet var consDoituongViewHeightEmpty: NSLayoutConstraint!
    @IBOutlet var lblCanhan: UILabel!
    @IBOutlet var viewCanhan: UIView!
    @IBOutlet var swtCanhan: UISwitch!
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
    @IBOutlet var lblTochucKDVT: UIView!
    @IBOutlet var swtTochucKDVT: UIView!
    @IBOutlet var lblTochucKDDS: UIView!
    @IBOutlet var swtTochucKDDS: UIView!
    @IBOutlet var lblTochucTPDB: UIView!
    @IBOutlet var swtTochucTPDB: UIView!
    @IBOutlet var lblTochucTTKDVTDS: UIView!
    @IBOutlet var swtTochucTTKDVTDS: UIView!
    @IBOutlet var lblTochucTTQLKTPTDS: UIView!
    @IBOutlet var swtTochucTTQLKTPTDS: UIView!
    @IBOutlet var lblTochucQLKTBTHTDB: UIView!
    @IBOutlet var swtTochucQLKTBTHTDB: UIView!
    @IBOutlet var lblTochucQLKTBTHTDS: UIView!
    @IBOutlet var swtTochucQLKTBTHTDS: UIView!
    @IBOutlet var lblDoanhnghiep: UILabel!
    @IBOutlet var swtDoanhnghiep: UISwitch!
    @IBOutlet var viewDoanhnghiep: UIView!
    @IBOutlet var lblDoanhnghiepKDKCHTDS: UIView!
    @IBOutlet var swtDoanhnghiepKDKCHTDS: UIView!
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
    @IBOutlet var lblTrungtamSHLX: UILabel!
    @IBOutlet var swtTrungtamSHLX: UISwitch!
    @IBOutlet var lblTrungtamDK: UILabel!
    @IBOutlet var swtTrungtamDK: UISwitch!
    @IBOutlet var lblCosodaotaolaixe: UILabel!
    @IBOutlet var swtCosodaotaolaixe: UISwitch!
    @IBOutlet var lblGa: UILabel!
    @IBOutlet var swtGa: UISwitch!
    @IBOutlet var btnXong: UIButton!
    
    var root = MPSearchTableController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initFilters()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initFilters() {
        enableMucphatFilter(enable: false)
        enablePhuongtienFilter(enable: false)
        enableDoituongFilter(enable: false)
    }
    
    @IBAction func swtMucphatAction(_ sender: Any) {
        enableMucphatFilter(enable: swtMucphat.isOn)
    }
    
    @IBAction func swtPhuongtienAction(_ sender: Any) {
        enablePhuongtienFilter(enable: swtPhuongtien.isOn)
    }
    
    @IBAction func swtDoituongAction(_ sender: Any) {
        enableDoituongFilter(enable: swtDoituong.isOn)
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
        updateMucphatView()
    }
    
    func updateMucphatView() {
        if swtMucphat.isOn {
            consMucphatViewHeight.isActive = true
            consMucphatViewHeightEmpty.isActive = false
            viewMucphat.isHidden = false
        }else{
            consMucphatViewHeight.isActive = false
            consMucphatViewHeightEmpty.isActive = true
            viewMucphat.isHidden = true
        }
    }
    
    func enablePhuongtienFilter(enable: Bool) {
        if enable {
            swtPhuongtien.isOn = true
        }else{
            swtPhuongtien.isOn = false
        }
        updatePhuongtienView()
    }
    
    func updatePhuongtienView() {
        if swtPhuongtien.isOn {
            consPhuongtienViewHeight.isActive = true
            consPhuongtienViewHeightEmpty.isActive = false
            viewPhuongtien.isHidden = false
        }else{
            consPhuongtienViewHeight.isActive = false
            consPhuongtienViewHeightEmpty.isActive = true
            viewPhuongtien.isHidden = true
        }
    }
    
    func enableDoituongFilter(enable: Bool) {
        if enable {
            swtDoituong.isOn = true
        }else{
            swtDoituong.isOn = false
        }
        updateDoituongView()
    }
    
    func updateDoituongView() {
        if swtDoituong.isOn {
            consDoituongViewHeight.isActive = true
            consDoituongViewHeightEmpty.isActive = false
            viewDoituong.isHidden = false
        }else{
            consDoituongViewHeight.isActive = false
            consDoituongViewHeightEmpty.isActive = true
            viewDoituong.isHidden = true
        }
    }
    
    func updateMucphatTu(tu: String) {
        btnTu.setTitle(tu, for: UIControlState.normal)
    }
    
    func updateMucphatDen(den: String) {
        btnDen.setTitle(den, for: UIControlState.normal)
    }
    
    @IBAction func btnXongAction(_ sender: Any) {
        //Xong button
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
