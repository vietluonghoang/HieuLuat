//
//  SplashScreenViewController.swift
//  HieuLuat
//
//  Created by VietLH on 9/9/22.
//  Copyright © 2022 VietLH. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig

class SplashScreenViewController: UIViewController {
    var remoteConfig: RemoteConfig!
    var delayTimer: Timer?
    @IBOutlet var viewMainView: UIView!
    var homeOpened = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        RunLoop.current.run(until: Date(timeIntervalSinceNow : 2.0)) //delay 2 seconds to view splash screen longer
        // Do any additional setup after loading the view.
        self.viewMainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveToHomeAgain)))
        _ = DataConnection.instance()
        updateRemoteConfig() //update remote config from firebase
        print("Delay to wait for initialization of Firebase and Device information.....")
        delayTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkIfInitializationDone), userInfo: nil, repeats: true)
        moveToHome()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func updateRemoteConfig(){
        print("--- Getting RemoteConfig from Firebase")
        
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "remote_config_defaults")
        remoteConfig.fetch { (status, error) -> Void in
            if status == .success {
                print("RemoteConfig fetched!")
                self.remoteConfig.activate { changed, error in
                    // ...
                }
            } else {
                print("RemoteConfig not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
        fetchRemoteConfig()
    }
    
    func fetchRemoteConfig(){
        GeneralSettings.getRequiredDatabaseVersion = remoteConfig.configValue(forKey: "requiredDBVersion").numberValue.intValue
        print("--- requiredDBVersion: \(GeneralSettings.getRequiredDatabaseVersion)")
        GeneralSettings.minimumAppVersionRequired = remoteConfig.configValue(forKey: "minimumAppVersion").stringValue!
        print("--- minimumAppVersion: \(GeneralSettings.minimumAppVersionRequired)")
        GeneralSettings.minimumAdsIntervalInSeconds = remoteConfig.configValue(forKey: "minimumAdsInterval").numberValue.intValue
        print("--- minimumAdsInterval: \(GeneralSettings.minimumAdsIntervalInSeconds)")
        GeneralSettings.isEnableInterstitialAds = remoteConfig.configValue(forKey: "enableInterstitialAds").boolValue
        print("--- enableInterstitialAds: \(GeneralSettings.isEnableInterstitialAds)")
        GeneralSettings.isEnableInappNotif = remoteConfig.configValue(forKey: "enableInappNotif").boolValue
        print("--- enableInappNotif: \(GeneralSettings.isEnableInappNotif)")
        GeneralSettings.isEnableBannerAds = remoteConfig.configValue(forKey: "enableBannerAds").boolValue
        print("--- enableBannerAds: \(GeneralSettings.isEnableBannerAds)")
        GeneralSettings.isDevMode = remoteConfig.configValue(forKey: "developementMode").boolValue
        print("--- developementMode: \(GeneralSettings.isDevMode)")
        GeneralSettings.getActiveQC41Id = remoteConfig.configValue(forKey: "defaultActiveQC41Id").numberValue.int64Value
        print("--- defaultActiveQC41Id: \(GeneralSettings.getActiveQC41Id)")
        GeneralSettings.getActiveNDXPId = remoteConfig.configValue(forKey: "defaultActiveNDXPId").numberValue.int64Value
        print("--- defaultActiveNDXPId: \(GeneralSettings.getActiveNDXPId)")
        print("--- tamgiuPhuongtienDieukhoanID: ")
        GeneralSettings.setTamgiuPhuongtienParentID(tamgiuphuongtienArr: remoteConfig.configValue(forKey: "tamgiuPhuongtienDieukhoanID").jsonValue!)
        print("RemoteConfig fetched successfully")
        GeneralSettings.isRemoteConfigFetched = true
    }
    
    @objc func checkIfInitializationDone(){
        print("Checking the initialization conditions....")
        if (!AnalyticsHelper.getIdForVendor().isEmpty && !AnalyticsHelper.getAdsId().isEmpty && !AnalyticsHelper.getAdsId().contains("undefined")) {
            delayTimer?.invalidate()
            print(".... Done")
        }
    }
    
    func moveToHome(){
        print("forwarding to Home")
        performSegue(withIdentifier: "showHome", sender: nil)
        homeOpened = true
    }
    
    @objc func moveToHomeAgain(){
        if homeOpened {
            moveToHome()
        }
    }
}
