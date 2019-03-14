//
//  BBFilterPopupViewController.swift
//  HieuLuat
//
//  Created by VietLH on 9/19/18.
//  Copyright © 2018 VietLH. All rights reserved.
//

import UIKit

class BBFilterPopupViewController: UIViewController {
    
    @IBOutlet var lblHeaderText: UILabel!
    @IBOutlet var svOptions: UIScrollView!
    @IBOutlet var btnXong: UIButton!

    var root: SearchControllers? = nil
    var optionList = [String]()
    var optionListText = [String:String]()
    var headerText = ""
    var labels = [UILabel]()
    var switches = [UISwitch]()
    let highestPriority = UILayoutPriority.init(1000)
    let higherPriority = UILayoutPriority.init(750)
    let lowerPriority = UILayoutPriority.init(751)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFilterOptions()
        updateSwitches()
        initHeaderText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //optionText will be the list of display name for options. Therefore, the order of optionText and options must be the same since the corresponding text will be replaced for option
    func updateFilterPopup(root: SearchControllers, options: [String], optionsText: [String:String], headerText: String) {
        self.root = root
        if root.isKind(of: BBSearchTableController.self) {
            self.root = root as! BBSearchTableController
        }
        if root.isKind(of: VKDTableController.self) {
            self.root = root as! VKDTableController
        }
        self.optionList = options
        self.optionListText = optionsText
        self.headerText = headerText
    }
    
    func updateSwitches() {
        var order = 0
        for opt in (optionList) {
            switches[order].isOn = (root?.isFilterSelected(key: opt))!
            order += 1
        }
    }
    
    func initHeaderText() {
        lblHeaderText.text = headerText
    }
    
    func initFilterOptions() {
        var order = 0
        for opt in optionList {
            let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.numberOfLines = 0
            lbl.lineBreakMode = .byWordWrapping
            lbl.text = optionListText[opt] //this is not a good way to apply display name. need to use other solution such as Hash
            lbl.tag = order
            
            let swt = UISwitch(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            swt.translatesAutoresizingMaskIntoConstraints = false
            swt.addTarget(self, action: #selector(swtValueChanged), for: .valueChanged)
            swt.tag = order
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 100))
            Utils.generateNewComponentWidthConstraint(component: view, width: svOptions.frame.width)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.clipsToBounds = true
            view.autoresizesSubviews = true
            view.tag = order
            
            if order == 0 {
                if optionList.count == 1 {
                    Utils.generateNewComponentConstraints(parent: svOptions, topComponent: svOptions, bottomComponent: svOptions, component: view, top: 0, left: 0, right: 0, bottom: 0, isInside: true)
                }else{
                    Utils.generateNewComponentConstraints(parent: svOptions, topComponent: svOptions, component: view, top: 0, left: 0, right: 0, isInside: true)
                }
            }else{
                if order < (optionList.count - 1) {
                    Utils.generateNewComponentConstraints(parent: svOptions, topComponent: (svOptions.subviews.last)!, component: view, top: 0, left: 0, right: 0, isInside: false)
                }else{
                    Utils.generateNewComponentConstraints(parent: svOptions, topComponent: (svOptions.subviews.last)!, bottomComponent: svOptions, component: view, top: 0, left: 0, right: 0, bottom: 0, isInside: false)
                }
            }
            
            Utils.generateNewComponentConstraintsSideward(parent: view, leftComponent: view, component: lbl, top: 2, left: 4, bottom: 2, isInside: true)
            Utils.generateNewComponentConstraintsSidewardMinimum(parent: view, leftComponent: lbl, rightComponent: view, component: swt, top: 2, left: 20, right: 4, bottom: 2, isInside: true)
            
            labels.append(lbl)
            switches.append(swt)
            
            order += 1
        }
    }
    
    @objc func swtValueChanged(sender: Any) {
        let name = optionList[(sender as! UISwitch).tag]
        root?.updateFilter(key: name, value: (sender as! UISwitch).isOn)
    }
    
    @IBAction func btnXongOnTouchDown(_ sender: Any) {
        root?.updateFilterLabel()
        root?.updateGroupsScrollView()
        root?.updateSearchResults()
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

}
