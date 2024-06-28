//
//  CustomUINavigationController.swift
//  HieuLuat
//
//  Created by Viet Cat on 28/6/24.
//  Copyright © 2024 VietLH. All rights reserved.
//

import Foundation
import UIKit

import UIKit

class CustomNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize the navigation controller if needed
//        performSegue(withIdentifier: "goHome", sender: nil)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        
//        super.prepare(for: segue, sender: sender)
//        
//        switch(segue.identifier ?? "") {
//        case "showHome":
//            guard let home = segue.destination as? UINavigationController else {
//                fatalError("Unexpected destination: \(segue.destination)")
//            }
//            
//        default:
//            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
//        }
//    }
}

