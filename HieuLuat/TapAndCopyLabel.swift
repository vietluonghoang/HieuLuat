//
//  TapAndCopyLabel.swift
//  HieuLuat
//
//  Created by VietLH on 9/13/19.
//  Copyright © 2019 VietLH. All rights reserved.
//

import UIKit

@IBDesignable
class TapAndCopyLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        //1.Here i am Adding UILongPressGestureRecognizer by which copy popup will Appears
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        self.addGestureRecognizer(gestureRecognizer)
        self.isUserInteractionEnabled = true
    }
    
    // MARK: - UIGestureRecognizer
    @objc func handleLongPressGesture(_ recognizer: UIGestureRecognizer) {
        guard recognizer.state == .recognized else { return }
        
        if let recognizerView = recognizer.view,
            let recognizerSuperView = recognizerView.superview, recognizerView.becomeFirstResponder()
        {
            let menuController = UIMenuController.shared
            menuController.setTargetRect(recognizerView.frame, in: recognizerSuperView)
            menuController.setMenuVisible(true, animated:true)
        }
    }
    //2.Returns a Boolean value indicating whether this object can become the first responder
    override var canBecomeFirstResponder: Bool {
        return true
    }
    //3.Here we are enabling copy action
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(UIResponderStandardEditActions.copy(_:)))
        
    }
    // MARK: - UIResponderStandardEditActions
    override func copy(_ sender: Any?) {
        //4.copy current Text to the paste board
        UIPasteboard.general.string = text
    }
}
