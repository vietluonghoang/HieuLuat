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
        AnalyticsHelper.sendAnalyticEvent(eventName: "open_screen", params: ["screen_name" : AnalyticsHelper.SCREEN_NAME_UPDATEVERSION])
    }
    
    @IBAction func btnUpdateAct(_ sender: Any) {
        openAppStore()
    }
    private func openAppStore(){
        // App Store URL.
        let appStoreLink = "https://apps.apple.com/us/app/wethoong/id1373587012"
        
        /* First create a URL, then check whether there is an installed app that can
         open it on the device. */
        RedirectionHelper().openUrl(url: URL(string: appStoreLink)!)
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
