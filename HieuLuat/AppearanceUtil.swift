//
//  AppearanceUtil.swift
//  HieuLuat
//
//  Created by VietLH on 11/1/17.
//  Copyright © 2017 VietLH. All rights reserved.
//

import UIKit

class AppearanceUtil {

    func changeLabelText(label: UILabel, text: String, color: UIColor = AppColors.onSurface, bgColor: UIColor = AppColors.surface, font: UIFont = AppTypography.bodyMedium) {
        label.text = text
        label.textColor = color
        label.backgroundColor = bgColor
        label.font = font
    }
    
    func changeLabelText(label: UILabel, font: UIFont = AppTypography.bodyMedium) {
        label.font = font
    }
    
    func changeLabelText(label: UILabel, color: UIColor = AppColors.onSurface, bgColor: UIColor = AppColors.surface) {
        label.textColor = color
        label.backgroundColor = bgColor
    }
    
    func changeLabelText(label: UILabel, font: UIFont = AppTypography.bodyMedium, color: UIColor = AppColors.onSurface) {
        label.font = font
        label.textColor = color
    }
    
    func changeLabelText(label: UILabel, color: UIColor = AppColors.onSurface) {
        label.textColor = color
    }
    
    static func applyModernStyle(to view: UIView) {
        view.backgroundColor = AppColors.surface
        view.layer.cornerRadius = AppRadius.md
        AppShadow.light(for: view.layer)
    }
}
