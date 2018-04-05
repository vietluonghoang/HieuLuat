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
        
        //test ad id
        //bannerView.adUnitID = "ca-app-pub-3940256099942544/6300978111"
        
        //my ad id
        bannerView.adUnitID = "ca-app-pub-1832172217205335/8933489074"
        
        bannerView.rootViewController = root
        let request = GADRequest()
        if GeneralSettings.isDevMode {
            request.testDevices = [ "80d71213058fcf16c5bdb59a1fb12840" ]
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
}
