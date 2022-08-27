//
//  AppDelegate.swift
//  HieuLuat
//
//  Created by VietLH on 8/26/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit
import GoogleMobileAds
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics
import FirebaseInAppMessaging
import FirebaseRemoteConfig

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Use the Firebase library to configure APIs.
        print("--- Configuring Firebase library......")
        FirebaseApp.configure()
        
        // Initialize the Google Mobile Ads SDK.
        // Sample AdMob app ID: ca-app-pub-3940256099942544~1458002511
        //        GADMobileAds.configure(withApplicationID: "cca-app-pub-3940256099942544/6300978111")
        //        GADMobileAds.configure(withApplicationID: "ca-app-pub-1832172217205335~6889602059")
        //        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        //=====Setup TapjoySDK=====
        //Set up success and failure notifications
        NotificationCenter.default.addObserver(self, selector: #selector(tjcConnectSuccess), name: NSNotification.Name(rawValue: TJC_CONNECT_SUCCESS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tjcConnectFail), name: NSNotification.Name(rawValue: TJC_CONNECT_FAILED), object: nil)
        
        //Turn on Tapjoy debug mode
        if GeneralSettings.isDevMode {
            Tapjoy.setDebugEnabled(true)
        }else{
            Tapjoy.setDebugEnabled(false)
        }
        //Tapjoy connect call
        Tapjoy.connect("yYojHsRCSS2pV8bY5NMqOgEBt4iGX26mfOW99XyTfeLUjC-bN5EnpLQRgpnf")
        return true
    }
    
    @objc func tjcConnectSuccess() {
        print("Connect to TJ success")
    }
    
    @objc func tjcConnectFail() {
        print("Fail to connect to TJ")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

