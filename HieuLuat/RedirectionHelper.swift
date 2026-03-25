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
            UIApplication.shared.open(url, options: [:], completionHandler: {(success: Bool) in
                if success {
                    print("Launching \(url) was successful")
                }})
        }
    }
    
    func openUrl(urls: [URL]) {
        for url in urls {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: {(success: Bool) in
                    if success {
                        print("Launching \(url) was successful")
                    }})
                return
            }
        }
    }
}
