//
//  PickerViewSelectPopup.swift
//  HieuLuat
//
//  Created by VietLH on 10/25/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit

class PickerViewSelectPopup: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let mucphatRange = GeneralSettings().getMucphatRange()
    
    @IBOutlet var pvMucphat: UIPickerView!
    @IBOutlet var btnXong: UIButton!
    
    var root = MPSearchFilterPopupController()
    var target = ""
    var selectedRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.pvMucphat.delegate = self
        self.pvMucphat.dataSource = self
    }
    
    func updateMucphat(root: MPSearchFilterPopupController, target: String) {
        self.target = target
        self.root = root
    }
    
    @IBAction func btnXongAction(_ sender: Any) {
        //Xong button
        if(target == "tu"){
            root.updateMucphatTu(tu: mucphatRange[selectedRow])
        }else{
            root.updateMucphatDen(den: mucphatRange[selectedRow])
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @available(iOS 2.0, *)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mucphatRange.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mucphatRange[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
    
}
