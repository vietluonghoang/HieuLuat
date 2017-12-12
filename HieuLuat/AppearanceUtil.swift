//
//  AppearanceUtil.swift
//  HieuLuat
//
//  Created by VietLH on 11/1/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit

class AppearanceUtil {

    func changeLabelText(label: UILabel,text: String, color: UIColor, bgColor: UIColor, font: UIFont ){
        label.text = text
        label.textColor = color
        label.backgroundColor = bgColor
        label.font = font
    }
    
    func changeLabelText(label: UILabel, font: UIFont ){
        label.font = font
    }
    
    func changeLabelText(label: UILabel, color: UIColor, bgColor: UIColor ){
        label.textColor = color
        label.backgroundColor = bgColor
    }
    
    func changeLabelText(label: UILabel, font: UIFont , color: UIColor){
        label.font = font
        label.textColor = color
    }
    
    func changeLabelText(label: UILabel, color: UIColor ){
        label.textColor = color
    }
}
