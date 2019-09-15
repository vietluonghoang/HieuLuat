//
//  AppConfiguration.swift
//  HieuLuat
//
//  Created by VietLH on 9/12/19.
//  Copyright © 2019 VietLH. All rights reserved.
//

import Foundation
class AppConfiguration {
    enum Configuration: String {
        case minimumappversion = "minimum_app_version"
        case enableappnotification = "enable_inapp_notif"
        case enablebannerads = "enable_banner_ads"
        case enableinterstitialads = "enable_interstitial_ads"
        case minimumadsinterval = "minimum_ads_interval"
    }
}
