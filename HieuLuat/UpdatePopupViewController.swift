//
//  UpdatePopupViewController.swift
//  HieuLuat
//
//  Created by VietLH on 9/12/19.
//  Copyright © 2019 VietLH. All rights reserved.
//

import UIKit

class UpdatePopupViewController: UIViewController {
    @IBOutlet var btnUpdate: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnUpdateAct(_ sender: Any) {
        openAppStore()
    }
    private func openAppStore(){
        // App Store URL.
        let appStoreLink = "https://apps.apple.com/us/app/wethoong/id1373587012"
        
        /* First create a URL, then check whether there is an installed app that can
         open it on the device. */
        if let url = URL(string: appStoreLink), UIApplication.shared.canOpenURL(url) {
            // Attempt to open the URL.
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: {(success: Bool) in
                    if success {
                        print("Launching \(url) was successful")
                    }})
            } else {
                // Fallback on earlier versions
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
