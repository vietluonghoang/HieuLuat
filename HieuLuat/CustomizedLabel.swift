//
//  TapAndCopyLabel.swift
//  HieuLuat
//
//  Created by VietLH on 9/13/19.
//  Copyright © 2019 VietLH. All rights reserved.
//

import UIKit

@IBDesignable
class CustomizedLabel: UILabel {
    private var contentString = ""
    
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
        print("==+++ \(contentString)")
    }
    
    private func setDefaultLabelConfig(){
        numberOfLines = 0
        lineBreakMode = NSLineBreakMode.byWordWrapping
        textAlignment = NSTextAlignment.left
    }
    
    func setContentString(contentString: String) {
        self.contentString = contentString
    }
    
    func setLightCaptionLabel() {
        setDefaultLabelConfig()
        font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.light)
    }
    func setBoldCaptionLabel() {
        setDefaultLabelConfig()
        font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
    }
    func setRegularCaptionLabel() {
        setDefaultLabelConfig()
        font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
    }
    func setRegularCaptionLabelRightAligned() {
        setDefaultLabelConfig()
        font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        textAlignment = NSTextAlignment.right
    }
    func setNormalCaptionLabel() {
        setDefaultLabelConfig()
        font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
    }
}
