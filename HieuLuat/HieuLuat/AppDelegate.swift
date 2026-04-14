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
        // Disable Metal globally before llama.cpp loads
        setenv("GGML_METAL_ENABLE", "0", 1)
        setenv("GGML_METAL_OFF", "1", 1)

        // Override point for customization after application launch.
        
        // Apply global UI theme
        AppTheme.apply()
        
        // Use the Firebase library to configure APIs.
        print("--- Configuring Firebase library......")
        FirebaseApp.configure()
        
        // Initialize the Google Mobile Ads SDK.
        //         Sample AdMob app ID: ca-app-pub-3940256099942544~1458002511
        //                GADMobileAds.configure(withApplicationID: "cca-app-pub-3940256099942544/6300978111")
//        GADMobileAds.configure(withApplicationID: "ca-app-pub-1832172217205335~6889602059")
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // Initialize MixPanel
        AnalyticsHelper.initMixPanel(userID: "")
        
        // --- llama.cpp GGUF test ---
        #if DEBUG
        testLlamaBridge()
        #endif
        
        return true
    }
    
    #if DEBUG
    private func testLlamaBridge() {
        DispatchQueue.global(qos: .userInitiated).async {
            // Find the GGUF model in the documents directory to match the new dynamic path requirement
            let fileManager = FileManager.default
            let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            // Assuming the model file exists, or just pass a dummy path if this is a legacy test
            let modelPath = docs.appendingPathComponent("model.gguf").path
            
            NSLog("[AppDelegate] Loading llama.cpp GGUF model at: %@", modelPath)
            LlamaBridge.shared.loadModel(path: modelPath)
            
            NSLog("[AppDelegate] Running inference...")
            let result = LlamaBridge.shared.infer(prompt: "Hello", maxNewTokens: 64, stopTokenIds: [])
            NSLog("[AppDelegate] Inference result: %@", result)
        }
    }
    #endif
    
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        if identifier == "com.hieuluat.aimodel.download" {
            AIModelCoordinator.shared // ensure initialized
            completionHandler()
        }
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
        print("Requesting for permission....")
        AnalyticsHelper.requestPermission()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

