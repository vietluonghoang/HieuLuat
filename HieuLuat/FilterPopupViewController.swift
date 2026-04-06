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
    @IBOutlet var btnXong: UIButton!
    
    var root: VBPLSearchTableController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSwitches()
        
        // Modern styling
        view.backgroundColor = AppColors.surface
        svPopupContent?.backgroundColor = AppColors.surface
        viewContent?.backgroundColor = AppColors.surface
        viewContent?.layer.cornerRadius = AppRadius.lg
        viewDetailContent?.backgroundColor = AppColors.surfaceVariant
        viewDetailContent?.layer.cornerRadius = AppRadius.md
        lblPopupTitle?.font = AppTypography.titleMedium
        lblPopupTitle?.textColor = AppColors.onSurface
        btnXong?.applyModernStyle(.primary)
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
        
        for id in stride(from: GeneralSettings.getVanbanIdMax, through: 0, by: -1) {
            if root?.filterSettings[String(id)] == "on" {
                swtArray.append(generateFilterSwitchItem(id: Int(id), shortname: GeneralSettings.getVanbanInfo(id: Int64(id), info: "shortname"), fullname: GeneralSettings.getVanbanInfo(id: Int64(id), info: "fullname"), isOn: true))
            }
        }
        for id in stride(from: GeneralSettings.getVanbanIdMax, through: 0, by: -1){
            if root?.filterSettings[String(id)] == "off" {
                swtArray.append(generateFilterSwitchItem(id: Int(id), shortname: GeneralSettings.getVanbanInfo(id: Int64(id), info: "shortname"), fullname: GeneralSettings.getVanbanInfo(id: Int64(id), info: "fullname"), isOn: false))
            }
        }
        Utils.autoGenerateLinearViewComponents(parent: viewDetailContent, orderedComponents: swtArray, top: 0, bottom: 0, left: 0, right: 0, isToptoBottom: true)
    }
    
    private func generateFilterSwitchItem(id: Int,shortname: String, fullname: String, isOn: Bool) -> UIView{
        let wrapperView = UIView()
        
        let lblVanbanShortname = CustomizedLabel()
        lblVanbanShortname.setBoldCaptionLabel()
        lblVanbanShortname.textColor = AppColors.onSurface
        lblVanbanShortname.text = shortname
        
        let lblVanbanFullname = CustomizedLabel()
        lblVanbanFullname.setLightCaptionLabel()
        lblVanbanFullname.textColor = AppColors.onSurfaceVariant
        lblVanbanFullname.text = fullname
        
        let swt = UISwitch()
        swt.isOn = isOn
        swt.tag = id
        swt.addTarget(self, action: #selector(swtAction), for: .valueChanged)
        
        lblVanbanShortname.translatesAutoresizingMaskIntoConstraints = false
        lblVanbanFullname.translatesAutoresizingMaskIntoConstraints = false
        swt.translatesAutoresizingMaskIntoConstraints = false
        
        lblVanbanShortname.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        lblVanbanFullname.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        swt.setContentCompressionResistancePriority(.required, for: .horizontal)
        swt.setContentHuggingPriority(.required, for: .horizontal)
        
        wrapperView.backgroundColor = AppColors.surface
        wrapperView.layer.cornerRadius = AppRadius.sm
        
        wrapperView.addSubview(lblVanbanShortname)
        wrapperView.addSubview(lblVanbanFullname)
        wrapperView.addSubview(swt)
        
        NSLayoutConstraint.activate([
            lblVanbanShortname.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 4),
            lblVanbanShortname.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 4),
            lblVanbanShortname.trailingAnchor.constraint(lessThanOrEqualTo: swt.leadingAnchor, constant: -8),
            
            lblVanbanFullname.topAnchor.constraint(equalTo: lblVanbanShortname.bottomAnchor, constant: 2),
            lblVanbanFullname.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 4),
            lblVanbanFullname.trailingAnchor.constraint(lessThanOrEqualTo: swt.leadingAnchor, constant: -8),
            lblVanbanFullname.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -4),
            
            swt.centerYAnchor.constraint(equalTo: wrapperView.centerYAnchor),
            swt.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -4),
        ])
        
        return wrapperView
    }
    
    @IBAction func btnXongOnTouchDown(_ sender: Any) {
        root?.updateSearchResults()
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
