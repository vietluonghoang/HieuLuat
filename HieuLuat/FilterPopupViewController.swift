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
        
        for id in 0...GeneralSettings.getVanbanIdMax {
            if root?.filterSettings[String(id)] == "on" {
                swtArray.append(generateFilterSwitchItem(id: Int(id), shortname: GeneralSettings.getVanbanInfo(id: Int64(id), info: "shortname"), fullname: GeneralSettings.getVanbanInfo(id: Int64(id), info: "fullname"), isOn: true))
            }
        }
        for id in 0...GeneralSettings.getVanbanIdMax {
            if root?.filterSettings[String(id)] == "off" {
                swtArray.append(generateFilterSwitchItem(id: Int(id), shortname: GeneralSettings.getVanbanInfo(id: Int64(id), info: "shortname"), fullname: GeneralSettings.getVanbanInfo(id: Int64(id), info: "fullname"), isOn: false))
            }
        }
        Utils.autoGenerateLinearViewComponents(parent: viewDetailContent, orderedComponents: swtArray, top: 0, bottom: 0, left: 0, right: 0, isToptoBottom: true)
    }
    
    private func generateFilterSwitchItem(id: Int,shortname: String, fullname: String, isOn: Bool) -> UIView{
        let wrapperView = UIView()
        let wrapperTitleView = UIView()
        let lblVanbanShortname = CustomizedLabel()
        lblVanbanShortname.setBoldCaptionLabel()
        lblVanbanShortname.text = shortname
        let lblVanbanFullname = CustomizedLabel()
        lblVanbanFullname.setLightCaptionLabel()
        lblVanbanFullname.text = fullname
        let titleComponentsList = [lblVanbanShortname,lblVanbanFullname]
        Utils.autoGenerateLinearViewComponents(parent: wrapperTitleView, orderedComponents: titleComponentsList, top: 1, bottom: 1, left: 1, right: 1, isToptoBottom: true)
        let swt = UISwitch()
        swt.isOn = isOn
        swt.tag = id
        swt.addTarget(self, action: #selector(swtAction), for: .valueChanged)
        let componentsList = [wrapperTitleView,swt]
        Utils.autoGenerateLinearViewComponentsConstraintByFirstComponent(parent: wrapperView, orderedComponents: componentsList, top: 2, bottom: 2, left: 2, right: 2, isToptoBottom: false)
        return wrapperView
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
}
