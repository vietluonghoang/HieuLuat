//
//  ViewController.swift
//  HieuLuat
//
//  Created by VietLH on 8/26/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var lblVersion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        RunLoop.current.run(until: Date(timeIntervalSinceNow : 2.0)) //delay 2 seconds to view splash screen longer
        lblVersion.text = getVersion()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getVersion() -> String {
        let bundleCode: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
        let bundleVersion: AnyObject? = Bundle.main.infoDictionary!["CFBundleVersion"] as AnyObject
        let versionInfo = "v.\(bundleCode as! String)(\(bundleVersion as! String)) - db.\(GeneralSettings.getDatabaseVersion)"
//        print("=========== \(versionInfo)")
        return versionInfo
    }
}

