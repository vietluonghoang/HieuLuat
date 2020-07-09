//
//  FilterPopupViewController.swift
//  HieuLuat
//
//  Created by VietLH on 9/6/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit

class FilterPopupViewController: UIViewController {
    @IBOutlet weak var swtQC41: UISwitch!
    @IBOutlet weak var swtTT01: UISwitch!
    @IBOutlet weak var swtND46: UISwitch!
    @IBOutlet var swtLGTDB2008: UISwitch!
    @IBOutlet var swtLXLVPHC2012: UISwitch!
    @IBOutlet var swtTT652020: UISwitch!
    
    var root: VBPLSearchTableController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSwitches()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateActiveFilterList(root: VBPLSearchTableController) {
        self.root = root
    }
    
    func updateSwitches() {
        if(root?.filterSettings["QC41"] == "on"){
            swtQC41.isOn = true
        }else{
            swtQC41.isOn = false
        }
        if(root?.filterSettings["ND46"] == "on"){
            swtND46.isOn = true
        }else{
            swtND46.isOn = false
        }
        if(root?.filterSettings["TT01"] == "on"){
            swtTT01.isOn = true
        }else{
            swtTT01.isOn = false
        }
        if(root?.filterSettings["LGTDB"] == "on"){
            swtLGTDB2008.isOn = true
        }else{
            swtLGTDB2008.isOn = false
        }
        if(root?.filterSettings["LXLVPHC"] == "on"){
            swtLXLVPHC2012.isOn = true
        }else{
            swtLXLVPHC2012.isOn = false
        }
        if(root?.filterSettings["TT652020"] == "on"){
            swtTT652020.isOn = true
        }else{
            swtTT652020.isOn = false
        }
    }
    
    @IBAction func btnXongOnTouchDown(_ sender: Any) {
        root?.updateSearchResults(for: (root?.searchController)!)
        root?.updateFilterLabel()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func swtQC41OnValueChange(_ sender: Any) {
        if (sender as! UISwitch).isOn {
            root?.filterSettings["QC41"] = "on"
        }else{
            root?.filterSettings["QC41"] = "off"
        }
    }
    @IBAction func swtTT01OnValueChange(_ sender: Any) {
        if (sender as! UISwitch).isOn {
            root?.filterSettings["TT01"] = "on"
        }else{
            root?.filterSettings["TT01"] = "off"
        }
    }
    @IBAction func swtND46OnValueChange(_ sender: Any) {
        if (sender as! UISwitch).isOn {
            root?.filterSettings["ND46"] = "on"
        }else{
            root?.filterSettings["ND46"] = "off"
        }
    }
    @IBAction func swtLGTDB2008ValueChange(_ sender: Any) {
        if (sender as! UISwitch).isOn {
            root?.filterSettings["LGTDB"] = "on"
        }else{
            root?.filterSettings["LGTDB"] = "off"
        }
    }
    @IBAction func swtLXLVPHCValueChange(_ sender: Any) {
        if (sender as! UISwitch).isOn {
            root?.filterSettings["LXLVPHC"] = "on"
        }else{
            root?.filterSettings["LXLVPHC"] = "off"
        }
    }
    @IBAction func swtTT652020ValueChange(_ sender: Any) {
        if (sender as! UISwitch).isOn {
            root?.filterSettings["TT652020"] = "on"
        }else{
            root?.filterSettings["TT652020"] = "off"
        }
    }
}
