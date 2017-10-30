//
//  PickerViewSelectPopup.swift
//  HieuLuat
//
//  Created by VietLH on 10/25/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit

class PickerViewSelectPopup: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let mucphatRange = ["50.000","60.000","80.000","100.000","120.000","200.000","300.000","400.000","500.000","600.000","800.000","1.000.000","1.200.000","500.000","1.600.000","2.000.000","2.500.000","3.000.000","4.000.000","5.000.000","6.000.000","7.000.000","8.000.000","10.000.000","12.000.000","14.000.000","15.000.000","16.000.000","18.000.000","20.000.000","25.000.000","28.000.000","30.000.000","32.000.000","36.000.000","37.500.000","40.000.000","50.000.000","52.500.000","56.000.000","64.000.000","70.000.000","75.000.000","80.000.000","150.000.000"]
    
    @IBOutlet var pvMucphat: UIPickerView!
    @IBOutlet var btnXong: UIButton!
    
    var root = MPSearchFilterPopupController()
    var target = ""
    var selectedRow = ""
    
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
            root.updateMucphatTu(tu: selectedRow)
        }else{
            root.updateMucphatDen(den: selectedRow)
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
        selectedRow = mucphatRange[row] as String
    }
    
}
