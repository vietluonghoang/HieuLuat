//
//  AboutViewController.swift
//  HieuLuat
//
//  Created by VietLH on 4/2/18.
//  Copyright © 2018 VietLH. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet var btnFounderFB: UIButton!
    @IBOutlet var btnFounderE: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnFounderFB.setTitle(GeneralSettings.getFBLink, for: .normal)
        btnFounderE.setTitle(GeneralSettings.getEmailAddress, for: .normal)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnFouderFBAction(_ sender: Any) {
        let url = URL(string: btnFounderFB.titleLabel!.text!)
        if UIApplication.shared.canOpenURL(url!) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url!)
            }
        }
    }
    
    
    @IBAction func btnFounderEAction(_ sender: Any) {
        let url = URL(string: "mailto:\(btnFounderE.titleLabel!.text!)")
        if UIApplication.shared.canOpenURL(url!) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url!)
            }
        }
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
