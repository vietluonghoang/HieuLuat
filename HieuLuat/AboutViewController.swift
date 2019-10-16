//
//  AboutViewController.swift
//  HieuLuat
//
//  Created by VietLH on 4/2/18.
//  Copyright © 2018 VietLH. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    let redirectionHelper = RedirectionHelper()
    
    @IBOutlet var btnFounderFB: UIButton!
    @IBOutlet var btnFounderE: UIButton!
    @IBOutlet var btnAdsOptout: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnFounderFB.setTitle((GeneralSettings.getFBLink[1]).absoluteString, for: .normal)
        btnFounderE.setTitle(GeneralSettings.getEmailAddress, for: .normal)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnFouderFBAction(_ sender: Any) {
        redirectionHelper.openUrl(urls: GeneralSettings.getFBLink)
    }
    
    
    @IBAction func btnFounderEAction(_ sender: Any) {
        let url = URL(string: "mailto:\(btnFounderE.titleLabel!.text!)")!
        redirectionHelper.openUrl(url: url)
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
