//
//  SplashScreenViewController.swift
//  HieuLuat
//
//  Created by VietLH on 9/9/22.
//  Copyright © 2022 VietLH. All rights reserved.
//

import FirebaseRemoteConfig
import UIKit

class SplashScreenViewController: UIViewController {
    var remoteConfig: RemoteConfig!
    var delayTimer: Timer?
    @IBOutlet var viewMainView: UIView!
    var homeOpened = false

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 5.0))  //delay 5 seconds to view splash screen longer
        // Do any additional setup after loading the view.
        self.viewMainView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self, action: #selector(moveToHomeAgain)))
        _ = DataConnection.instance() 
        updateRemoteConfig()  //update remote config from firebase
        print(
            "Delay to wait for initialization of Firebase and Device information....."
        )
        delayTimer = Timer.scheduledTimer(
            timeInterval: 1, target: self,
            selector: #selector(checkIfInitializationDone), userInfo: nil,
            repeats: true)
        AnalyticsHelper.sendAnalyticEventMixPanel(
            eventName: "app_open", params: [:])
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

    func updateRemoteConfig() {
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
                var params = [
                    "defaultActiveNDXPId": String(
                        GeneralSettings.getActiveNDXPId),
                    "defaultActiveQC41Id": String(
                        GeneralSettings.getActiveQC41Id),
                    "defaultConnectionTries": String(GeneralSettings.remainingConnectionTries),
                    "defaultMixPanelEventSendTimeout": String(GeneralSettings.getDefaultMixPanelEventSendTimeout),
                    "developementMode": String(GeneralSettings.isDevMode),
                    "enableBannerAds": String(
                        GeneralSettings.isEnableBannerAds),
                    "enableInappNotif": String(
                        GeneralSettings.isEnableInappNotif),
                    "enableInterstitialAds": String(
                        GeneralSettings.isEnableInterstitialAds),
                    "minimumAdsInterval": String(
                        GeneralSettings.minimumAdsIntervalInSeconds),
                    "minimumAppVersion": String(
                        GeneralSettings.minimumAppVersionRequired),
                    "mixPanelEnabled": String(GeneralSettings.isMixPanelEnabled),
                    "requiredDBVersion": String(
                        GeneralSettings.getRequiredDatabaseVersion),
                    "tamgiuPhuongtienDieukhoanID": String(GeneralSettings.getTamgiuPhuongtienParentID()),
                    "trackAutomaticEvents": String(GeneralSettings.isTrackAutomaticEvents)
                ]
                AnalyticsHelper.sendAnalyticEventMixPanel(
                    eventName: "app_config", params: params)
            } else {
                print("RemoteConfig not fetched")
                print(
                    "Error: \(error?.localizedDescription ?? "No error available.")"
                )
            }
        }
        fetchRemoteConfig()
    }

    func fetchRemoteConfig() {

        GeneralSettings.getActiveNDXPId =
            remoteConfig.configValue(forKey: "defaultActiveNDXPId").numberValue
            .int64Value
        print("--- defaultActiveNDXPId: \(GeneralSettings.getActiveNDXPId)")
        GeneralSettings.getActiveQC41Id =
            remoteConfig.configValue(forKey: "defaultActiveQC41Id").numberValue
            .int64Value
        print("--- defaultActiveQC41Id: \(GeneralSettings.getActiveQC41Id)")
        GeneralSettings.remainingConnectionTries =
            remoteConfig.configValue(forKey: "defaultConnectionTries").numberValue
            .intValue
        print("--- defaultConnectionTries: \(GeneralSettings.remainingConnectionTries)")
        GeneralSettings.getDefaultMixPanelEventSendTimeout =
            remoteConfig.configValue(forKey: "defaultMixPanelEventSendTimeout").numberValue
            .intValue
        print("--- defaultMixPanelEventSendTimeout: \(GeneralSettings.getDefaultMixPanelEventSendTimeout)")
        GeneralSettings.isDevMode =
            remoteConfig.configValue(forKey: "developementMode").boolValue
        print("--- developementMode: \(GeneralSettings.isDevMode)")
        GeneralSettings.isEnableBannerAds =
            remoteConfig.configValue(forKey: "enableBannerAds").boolValue
        print("--- enableBannerAds: \(GeneralSettings.isEnableBannerAds)")
        GeneralSettings.isEnableInappNotif =
            remoteConfig.configValue(forKey: "enableInappNotif").boolValue
        print("--- enableInappNotif: \(GeneralSettings.isEnableInappNotif)")
        GeneralSettings.isEnableInterstitialAds =
            remoteConfig.configValue(forKey: "enableInterstitialAds").boolValue
        print(
            "--- enableInterstitialAds: \(GeneralSettings.isEnableInterstitialAds)"
        )
        GeneralSettings.minimumAdsIntervalInSeconds =
            remoteConfig.configValue(forKey: "minimumAdsInterval").numberValue
            .intValue
        print(
            "--- minimumAdsInterval: \(GeneralSettings.minimumAdsIntervalInSeconds)"
        )
        GeneralSettings.minimumAppVersionRequired = remoteConfig.configValue(
            forKey: "minimumAppVersion"
        ).stringValue!
        print(
            "--- minimumAppVersion: \(GeneralSettings.minimumAppVersionRequired)"
        )
        GeneralSettings.isMixPanelEnabled =
            remoteConfig.configValue(forKey: "mixPanelEnabled").boolValue
        print("--- mixPanelEnabled: \(GeneralSettings.isMixPanelEnabled)")
        GeneralSettings.getRequiredDatabaseVersion =
            remoteConfig.configValue(forKey: "requiredDBVersion").numberValue
            .intValue
        print(
            "--- requiredDBVersion: \(GeneralSettings.getRequiredDatabaseVersion)"
        )
        print("--- tamgiuPhuongtienDieukhoanID: ")
        GeneralSettings.setTamgiuPhuongtienParentID(
            tamgiuphuongtienArr: remoteConfig.configValue(
                forKey: "tamgiuPhuongtienDieukhoanID"
            ).jsonValue!)
        print("RemoteConfig fetched successfully")
        GeneralSettings.isTrackAutomaticEvents =
            remoteConfig.configValue(forKey: "trackAutomaticEvents").boolValue
        print("--- trackAutomaticEvents: \(GeneralSettings.isTrackAutomaticEvents)")
        
        GeneralSettings.isRemoteConfigFetched = true
    }

    @objc func checkIfInitializationDone() {
        print("Checking the initialization conditions....")
        if !AnalyticsHelper.getIdForVendor().isEmpty
            && !AnalyticsHelper.getAdsId().isEmpty
            && !AnalyticsHelper.getAdsId().contains("undefined")
        {
            delayTimer?.invalidate()
            print(".... Done")
        }
    }

    func moveToHome() {
        print("forwarding to Home")
        performSegue(withIdentifier: "showHome", sender: nil)
        homeOpened = true
    }

    @objc func moveToHomeAgain() {
        if homeOpened {
            moveToHome()
        }
    }
}
