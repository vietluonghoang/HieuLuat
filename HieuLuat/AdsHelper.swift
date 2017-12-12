//
//  AdsHelper.swift
//  HieuLuat
//
//  Created by VietLH on 10/31/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit
import GoogleMobileAds

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
        request.testDevices = [ "80d71213058fcf16c5bdb59a1fb12840" ]
        bannerView.load(request)
    }
}
