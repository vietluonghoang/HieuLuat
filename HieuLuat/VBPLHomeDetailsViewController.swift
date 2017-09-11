//
//  VBPLHomeDetailsViewController.swift
//  HieuLuat
//
//  Created by VietLH on 9/7/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit
import os.log

class VBPLHomeDetailsViewController: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "ND462016":
            guard let dieukhoanHome = segue.destination as? VBPLDetailsSearchTableController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            dieukhoanHome.updateVanbanId(vanbanId: ["2"])
        
        case "QC412016":
            guard let dieukhoanHome = segue.destination as? VBPLDetailsSearchTableController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            dieukhoanHome.updateVanbanId(vanbanId: ["1"])
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
        
    }
}
