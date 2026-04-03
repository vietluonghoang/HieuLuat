//
//  LoadingView.swift
//  HieuLuat
//
//  Created by VietLH on 10/11/19.
//  Copyright © 2019 VietLH. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    func showSpinner() {
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.color = AppColors.primary
        ai.startAnimating()
        ai.center = self.center
        
        DispatchQueue.main.async {
            self.backgroundColor = AppColors.surface.withAlphaComponent(0.9)
            self.layer.cornerRadius = AppRadius.lg
            self.addSubview(ai)
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
}
