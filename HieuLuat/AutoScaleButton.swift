//
//  AutoScaleButton.swift
//  HieuLuat
//
//  Created by VietLH on 11/8/19.
//  Copyright © 2019 VietLH. All rights reserved.
//

import UIKit

class AutoScaleButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override var intrinsicContentSize: CGSize {
        return titleLabel!.sizeThatFits(CGSize(width: titleLabel!.preferredMaxLayoutWidth, height: .greatestFiniteMagnitude))
    }
    override func layoutSubviews() {
        titleLabel?.preferredMaxLayoutWidth = frame.size.width
        super.layoutSubviews()
    }
}
