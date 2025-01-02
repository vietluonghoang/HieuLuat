//
//  AdsHelper.swift
//  HieuLuat
//
//  Created by VietLH on 10/31/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SystemConfiguration

class AdsHelper {
    
    class func initBannerAds(btnFBBanner: UIButton, bannerView: GADBannerView, toView: UIView, root: UIViewController){
        if GeneralSettings.isEnableBannerAds && AdsHelper.isConnectedToNetwork() {
            addBannerViewToView(bannerView: bannerView,toView: toView, root: root)
        }else{
            addButtonToView(btnFBBanner: btnFBBanner, toView: toView)
        }
    }
    
    class func addBannerViewToView(bannerView: GADBannerView, toView: UIView, root: UIViewController) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        toView.addSubview(bannerView)
        toView.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .top,
                                relatedBy: .equal,
                                toItem: toView,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: toView,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .leading,
                                relatedBy: .equal,
                                toItem: toView,
                                attribute: .leading,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .trailing,
                                relatedBy: .equal,
                                toItem: toView,
                                attribute: .trailing,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: toView,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
        
        
        if GeneralSettings.isDevMode {
            //test ad id
            print("========= ADS: showing test ads")
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174"
        }else{
            //my ad id
            print("========= ADS: showing real ads")
            bannerView.adUnitID = "ca-app-pub-1832172217205335/8933489074"
        }
        bannerView.rootViewController = root
        let request = GADRequest()
        if GeneralSettings.isDevMode {
            //            deprecated 'testDevices' method
            //            request.testDevices = [ "80d71213058fcf16c5bdb59a1fb12840" ]
            print("========= ADS: signing test device")
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "80d71213058fcf16c5bdb59a1fb12840" ]
        }
        bannerView.load(request)
    }
    
    class func addButtonToView(btnFBBanner: UIButton, toView: UIView){
        btnFBBanner.frame = toView.bounds
        btnFBBanner.contentMode = .center
        btnFBBanner.imageView?.contentMode = .scaleAspectFit
        btnFBBanner.backgroundColor = UIColor.brown
        btnFBBanner.setImage(UIImage(named: "facebook-banner-wethoong"), for: .normal)
        btnFBBanner.translatesAutoresizingMaskIntoConstraints = false
        toView.addSubview(btnFBBanner)
        toView.addConstraints(
            [NSLayoutConstraint(item: btnFBBanner,
                                attribute: .top,
                                relatedBy: .equal,
                                toItem: toView,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: btnFBBanner,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: toView,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: btnFBBanner,
                                attribute: .leading,
                                relatedBy: .equal,
                                toItem: toView,
                                attribute: .leading,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: btnFBBanner,
                                attribute: .trailing,
                                relatedBy: .equal,
                                toItem: toView,
                                attribute: .trailing,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: btnFBBanner,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: toView,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
        
    }
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
    
    class func initTJPlacement(name: String, delegate: TJPlacementDelegate) -> TJPlacement{
        let placement = TJPlacement(name: name, delegate: delegate)
        
        return placement as! TJPlacement
    }
    
    class func isValidToShowIntestitialAds() -> Bool {
        print("getLastAppOpenTimestamp: \(GeneralSettings.getLastAppOpenTimestamp)")
        print("getInterstitialAdsOpenTimes: \(GeneralSettings.getInterstitialAdsOpenTimes)")
        print("isEnableInterstitialAds: \(GeneralSettings.isEnableInterstitialAds)")
        print("minimumAdsIntervalInSeconds: \(GeneralSettings.minimumAdsIntervalInSeconds)")
        print("getLastInterstitialAdsOpenTimestamp: \(GeneralSettings.getLastInterstitialAdsOpenTimestamp)")
        print("is Ads optout: \(GeneralSettings.isAdsOptout)")
        //If the app was opened more than a day, let reset the opening timestamp and interstitial ads open counter
        if Int(NSDate().timeIntervalSince1970) - GeneralSettings.getLastAppOpenTimestamp > 86400 {
            GeneralSettings.getLastAppOpenTimestamp = Int(NSDate().timeIntervalSince1970)
            GeneralSettings.getInterstitialAdsOpenTimes = 0
        }
        
        //Show interstitial ads just in case:
        //1. Interstitial ads is enabled
        //2. It's long enough since the last time the ads shown (ex: at least 5 mins between shows)
        //3. The more time the ads shown, the longer interval until the next shown (ex: 5 mins for the first show, 10 mins for the second show, 15 mins for the third show and so on...)
        if !GeneralSettings.isAdsOptout && GeneralSettings.isEnableInterstitialAds && (Int(NSDate().timeIntervalSince1970) - GeneralSettings.getLastAppOpenTimestamp > GeneralSettings.minimumAdsIntervalInSeconds * (GeneralSettings.getInterstitialAdsOpenTimes + 1)) && (Int(NSDate().timeIntervalSince1970) - GeneralSettings.getLastInterstitialAdsOpenTimestamp > GeneralSettings.minimumAdsIntervalInSeconds) {
            return true
        }
        return false
    }
}
