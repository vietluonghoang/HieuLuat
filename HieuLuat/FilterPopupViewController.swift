//
//  FilterPopupViewController.swift
//  HieuLuat
//
//  Created by VietLH on 9/6/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit

class FilterPopupViewController: UIViewController {
    @IBOutlet var svPopupContent: UIScrollView!
    @IBOutlet var viewContent: UIView!
    @IBOutlet var lblPopupTitle: UILabel!
    @IBOutlet var viewDetailContent: UIView!
    
    
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
        var swtArray = [UIView]()
        
        for id in root!.filterSettings.keys {
            if root?.filterSettings[id] == "on" {
                let wrapperView = UIView()
                let lblVanbanShortname = UILabel()
                lblVanbanShortname.text = GeneralSettings.getVanbanInfo(id: Int64(id)!, info: "shortname")
                let swt = UISwitch()
                swt.isOn = true
                swt.tag = Int(id)!
                swt.addTarget(self, action: #selector(swtAction), for: .valueChanged)
                let componentsList = [lblVanbanShortname,swt]
                Utils.autoGenerateLinearViewComponents(parent: wrapperView, orderedComponents: componentsList, top: 2, bottom: 2, left: 2, right: 2, isToptoBottom: false)
                swtArray.append(wrapperView)
            }
        }
        for id in root!.filterSettings.keys {
            if root?.filterSettings[id] == "off" {
                let wrapperView = UIView()
                let lblVanbanShortname = UILabel()
                lblVanbanShortname.text = GeneralSettings.getVanbanInfo(id: Int64(id)!, info: "shortname")
                let swt = UISwitch()
                swt.isOn = false
                swt.tag = Int(id)!
                swt.addTarget(self, action: #selector(swtAction), for: .valueChanged)
                let componentsList = [lblVanbanShortname,swt]
                Utils.autoGenerateLinearViewComponents(parent: wrapperView, orderedComponents: componentsList, top: 2, bottom: 2, left: 2, right: 2, isToptoBottom: false)
                swtArray.append(wrapperView)
            }
        }
        Utils.autoGenerateLinearViewComponents(parent: viewDetailContent, orderedComponents: swtArray, top: 0, bottom: 0, left: 0, right: 0, isToptoBottom: true)
    }
    
    @IBAction func btnXongOnTouchDown(_ sender: Any) {
        root?.updateSearchResults(for: (root?.searchController)!)
        root?.updateFilterLabel()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func swtAction(sender: UISwitch!) {
        if (sender!).isOn {
            root?.filterSettings[String(sender.tag)] = "on"
        }else{
            root?.filterSettings[String(sender.tag)] = "off"
        }
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
