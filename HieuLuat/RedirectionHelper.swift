//
//  RedirectionHelper.swift
//  HieuLuat
//
//  Created by VietLH on 9/12/19.
//  Copyright © 2019 VietLH. All rights reserved.
//

import Foundation
import UIKit

class RedirectionHelper {
    
    func openUrl(url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            // Attempt to open the URL.
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: {(success: Bool) in
                    if success {
                        print("Launching \(url) was successful")
                    }})
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func openUrl(urls: [URL]) {
        for url in urls {
            if UIApplication.shared.canOpenURL(url) {
                // Attempt to open the URL.
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: {(success: Bool) in
                        if success {
                            print("Launching \(url) was successful")
                        }})
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(url)
                }
                return
            }
        }
    }
}
