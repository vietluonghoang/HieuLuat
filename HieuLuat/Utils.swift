//
//  Utils.swift
//  HieuLuat
//
//  Created by VietLH on 9/13/18.
//  Copyright © 2018 VietLH. All rights reserved.
//

import UIKit

class Utils {
    class func scaleImage(image: UIImage, targetWidth: CGFloat) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetWidth / image.size.width
        
        //        let ratio:Float = Float(size.width)/Float(size.height)
        
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        newSize = CGSize(width: size.width * widthRatio, height: CGFloat(Float(size.height) * Float(widthRatio)))
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    class func scaleImageSideward(image: UIImage, targetHeight: CGFloat) -> UIImage {
        let size = image.size
        
        let heightRatio  = targetHeight / image.size.height
        
        //        let ratio:Float = Float(size.width)/Float(size.height)
        
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        newSize = CGSize(width: CGFloat(Float(size.width) * Float(heightRatio)), height: size.height * heightRatio)
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    class func getScreenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    class func updateButtonState(button: UIButton, state: Bool, onColor: UIColor, offColor: UIColor) {
        
        if state {
            button.backgroundColor = onColor
            button.setTitleColor(offColor, for: .normal)
        }else{
            button.backgroundColor = offColor
            button.setTitleColor(onColor, for: .normal)
        }
    }
    
    class func updateViewState(view: UIView, state: Bool, onColor: UIColor, offColor: UIColor) {
        if state {
            view.backgroundColor = onColor
        }else{
            view.backgroundColor = offColor
        }
    }
    
    class func generateNewComponentConstraints(parent: UIView, topComponent: UIView, component: UIView, top: CGFloat, left: CGFloat, right: CGFloat, isInside: Bool) {
        component.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(component)
        if isInside {
            parent.addConstraints(
                [
                    NSLayoutConstraint(item: component,
                                       attribute: .leading,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .leading,
                                       multiplier: 1,
                                       constant: left),
                    NSLayoutConstraint(item: component,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .trailing,
                                       multiplier: 1,
                                       constant: right),
                    NSLayoutConstraint(item: component,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: topComponent,
                                       attribute: .top,
                                       multiplier: 1,
                                       constant: top)
                ])
        }else {
            parent.addConstraints(
                [
                    NSLayoutConstraint(item: component,
                                       attribute: .leading,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .leading,
                                       multiplier: 1,
                                       constant: left),
                    NSLayoutConstraint(item: component,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .trailing,
                                       multiplier: 1,
                                       constant: right),
                    NSLayoutConstraint(item: component,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: topComponent,
                                       attribute: .bottom,
                                       multiplier: 1,
                                       constant: top)
                ])
        }
    }
    
    class func generateNewComponentConstraints(parent: UIView, topComponent: UIView, bottomComponent: UIView, component: UIView, top: CGFloat, left: CGFloat, right: CGFloat, bottom: CGFloat, isInside: Bool) {
        component.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(component)
        if isInside {
            parent.addConstraints(
                [
                    NSLayoutConstraint(item: component,
                                       attribute: .leading,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .leading,
                                       multiplier: 1,
                                       constant: left),
                    NSLayoutConstraint(item: component,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .trailing,
                                       multiplier: 1,
                                       constant: (0 - right)),
                    NSLayoutConstraint(item: component,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: topComponent,
                                       attribute: .top,
                                       multiplier: 1,
                                       constant: top),
                    NSLayoutConstraint(item: component,
                                       attribute: .bottom,
                                       relatedBy: .equal,
                                       toItem: bottomComponent,
                                       attribute: .bottom,
                                       multiplier: 1,
                                       constant: (0 - bottom))
                ])
        }else {
            parent.addConstraints(
                [
                    NSLayoutConstraint(item: component,
                                       attribute: .leading,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .leading,
                                       multiplier: 1,
                                       constant: left),
                    NSLayoutConstraint(item: component,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .trailing,
                                       multiplier: 1,
                                       constant: (0 - right)),
                    NSLayoutConstraint(item: component,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: topComponent,
                                       attribute: .bottom,
                                       multiplier: 1,
                                       constant: top),
                    NSLayoutConstraint(item: component,
                                       attribute: .bottom,
                                       relatedBy: .equal,
                                       toItem: bottomComponent,
                                       attribute: .bottom,
                                       multiplier: 1,
                                       constant: (0 - bottom))
                ])
        }
    }
    
    class func generateNewComponentConstraintsSideward(parent: UIView, leftComponent: UIView, component: UIView, top: CGFloat, left: CGFloat, bottom: CGFloat, isInside: Bool) {
        component.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(component)
        if isInside {
            parent.addConstraints(
                [
                    NSLayoutConstraint(item: component,
                                       attribute: .leading,
                                       relatedBy: .equal,
                                       toItem: leftComponent,
                                       attribute: .leading,
                                       multiplier: 1,
                                       constant: left),
                    NSLayoutConstraint(item: component,
                                       attribute: .bottom,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .bottom,
                                       multiplier: 1,
                                       constant: (0 - bottom)),
                    NSLayoutConstraint(item: component,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .top,
                                       multiplier: 1,
                                       constant: top)
                ])
        }else {
            parent.addConstraints(
                [
                    NSLayoutConstraint(item: component,
                                       attribute: .leading,
                                       relatedBy: .equal,
                                       toItem: leftComponent,
                                       attribute: .trailing,
                                       multiplier: 1,
                                       constant: left),
                    NSLayoutConstraint(item: component,
                                       attribute: .bottom,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .bottom,
                                       multiplier: 1,
                                       constant: (0 - bottom)),
                    NSLayoutConstraint(item: component,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .top,
                                       multiplier: 1,
                                       constant: top)
                ])
        }
    }
    
    class func generateNewComponentConstraintsSideward(parent: UIView, leftComponent: UIView, rightComponent: UIView, component: UIView, top: CGFloat, left: CGFloat, right: CGFloat, bottom: CGFloat, isInside: Bool) {
        component.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(component)
        if isInside {
            parent.addConstraints(
                [
                    NSLayoutConstraint(item: component,
                                       attribute: .leading,
                                       relatedBy: .equal,
                                       toItem: leftComponent,
                                       attribute: .leading,
                                       multiplier: 1,
                                       constant: left),
                    NSLayoutConstraint(item: component,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: rightComponent,
                                       attribute: .trailing,
                                       multiplier: 1,
                                       constant: (0 - right)),
                    NSLayoutConstraint(item: component,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .top,
                                       multiplier: 1,
                                       constant: top),
                    NSLayoutConstraint(item: component,
                                       attribute: .bottom,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .bottom,
                                       multiplier: 1,
                                       constant: (0 - bottom))
                ])
        }else {
            parent.addConstraints(
                [
                    NSLayoutConstraint(item: component,
                                       attribute: .leading,
                                       relatedBy: .equal,
                                       toItem: leftComponent,
                                       attribute: .trailing,
                                       multiplier: 1,
                                       constant: left),
                    NSLayoutConstraint(item: component,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: rightComponent,
                                       attribute: .trailing,
                                       multiplier: 1,
                                       constant: (0 - right)),
                    NSLayoutConstraint(item: component,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .top,
                                       multiplier: 1,
                                       constant: top),
                    NSLayoutConstraint(item: component,
                                       attribute: .bottom,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .bottom,
                                       multiplier: 1,
                                       constant: (0 - bottom))
                ])
        }
    }
    
    class func generateNewComponentConstraintsRightward(parent: UIView, rightComponent: UIView, component: UIView, top: CGFloat, right: CGFloat, bottom: CGFloat, isInside: Bool) {
        component.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(component)
        if isInside {
            parent.addConstraints(
                [
                    NSLayoutConstraint(item: component,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: rightComponent,
                                       attribute: .trailing,
                                       multiplier: 1,
                                       constant: right),
                    NSLayoutConstraint(item: component,
                                       attribute: .bottom,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .bottom,
                                       multiplier: 1,
                                       constant: (0 - bottom)),
                    NSLayoutConstraint(item: component,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .top,
                                       multiplier: 1,
                                       constant: top)
                ])
        }else {
            parent.addConstraints(
                [
                    NSLayoutConstraint(item: component,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: rightComponent,
                                       attribute: .leading,
                                       multiplier: 1,
                                       constant: right),
                    NSLayoutConstraint(item: component,
                                       attribute: .bottom,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .bottom,
                                       multiplier: 1,
                                       constant: (0 - bottom)),
                    NSLayoutConstraint(item: component,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .top,
                                       multiplier: 1,
                                       constant: top)
                ])
        }
    }
    
    class func generateNewComponentConstraintsRightward(parent: UIView, leftComponent: UIView, rightComponent: UIView, component: UIView, top: CGFloat, left: CGFloat, right: CGFloat, bottom: CGFloat, isInside: Bool) {
        component.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(component)
        if isInside {
            parent.addConstraints(
                [
                    NSLayoutConstraint(item: component,
                                       attribute: .leading,
                                       relatedBy: .equal,
                                       toItem: leftComponent,
                                       attribute: .leading,
                                       multiplier: 1,
                                       constant: left),
                    NSLayoutConstraint(item: component,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: rightComponent,
                                       attribute: .trailing,
                                       multiplier: 1,
                                       constant: (0 - right)),
                    NSLayoutConstraint(item: component,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .top,
                                       multiplier: 1,
                                       constant: top),
                    NSLayoutConstraint(item: component,
                                       attribute: .bottom,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .bottom,
                                       multiplier: 1,
                                       constant: (0 - bottom))
                ])
        }else {
            parent.addConstraints(
                [
                    NSLayoutConstraint(item: component,
                                       attribute: .leading,
                                       relatedBy: .equal,
                                       toItem: leftComponent,
                                       attribute: .leading,
                                       multiplier: 1,
                                       constant: left),
                    NSLayoutConstraint(item: component,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: rightComponent,
                                       attribute: .leading,
                                       multiplier: 1,
                                       constant: (0 - right)),
                    NSLayoutConstraint(item: component,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .top,
                                       multiplier: 1,
                                       constant: top),
                    NSLayoutConstraint(item: component,
                                       attribute: .bottom,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .bottom,
                                       multiplier: 1,
                                       constant: (0 - bottom))
                ])
        }
    }
    
    class func generateNewComponentConstraintsSidewardMinimum(parent: UIView, leftComponent: UIView, rightComponent: UIView, component: UIView, top: CGFloat, left: CGFloat, right: CGFloat, bottom: CGFloat, isInside: Bool) {
        component.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(component)
        if isInside {
            parent.addConstraints(
                [
                    NSLayoutConstraint(item: component,
                                       attribute: .leading,
                                       relatedBy: .greaterThanOrEqual,
                                       toItem: leftComponent,
                                       attribute: .leading,
                                       multiplier: 1,
                                       constant: left),
                    NSLayoutConstraint(item: component,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: rightComponent,
                                       attribute: .trailing,
                                       multiplier: 1,
                                       constant: (0 - right)),
                    NSLayoutConstraint(item: component,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .top,
                                       multiplier: 1,
                                       constant: top),
                    NSLayoutConstraint(item: component,
                                       attribute: .bottom,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .bottom,
                                       multiplier: 1,
                                       constant: (0 - bottom))
                ])
        }else {
            parent.addConstraints(
                [
                    NSLayoutConstraint(item: component,
                                       attribute: .leading,
                                       relatedBy: .greaterThanOrEqual,
                                       toItem: leftComponent,
                                       attribute: .trailing,
                                       multiplier: 1,
                                       constant: left),
                    NSLayoutConstraint(item: component,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: rightComponent,
                                       attribute: .trailing,
                                       multiplier: 1,
                                       constant: (0 - right)),
                    NSLayoutConstraint(item: component,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .top,
                                       multiplier: 1,
                                       constant: top),
                    NSLayoutConstraint(item: component,
                                       attribute: .bottom,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .bottom,
                                       multiplier: 1,
                                       constant: (0 - bottom))
                ])
        }
    }
    
    class func generateNewComponentConstraintsRightwardMinimum(parent: UIView, leftComponent: UIView, rightComponent: UIView, component: UIView, top: CGFloat, left: CGFloat, right: CGFloat, bottom: CGFloat, isInside: Bool) {
        component.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(component)
        if isInside {
            parent.addConstraints(
                [
                    NSLayoutConstraint(item: component,
                                       attribute: .leading,
                                       relatedBy: .equal,
                                       toItem: leftComponent,
                                       attribute: .leading,
                                       multiplier: 1,
                                       constant: left),
                    NSLayoutConstraint(item: component,
                                       attribute: .trailing,
                                       relatedBy: .greaterThanOrEqual,
                                       toItem: rightComponent,
                                       attribute: .trailing,
                                       multiplier: 1,
                                       constant: (0 - right)),
                    NSLayoutConstraint(item: component,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .top,
                                       multiplier: 1,
                                       constant: top),
                    NSLayoutConstraint(item: component,
                                       attribute: .bottom,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .bottom,
                                       multiplier: 1,
                                       constant: (0 - bottom))
                ])
        }else {
            parent.addConstraints(
                [
                    NSLayoutConstraint(item: component,
                                       attribute: .leading,
                                       relatedBy: .equal,
                                       toItem: leftComponent,
                                       attribute: .leading,
                                       multiplier: 1,
                                       constant: left),
                    NSLayoutConstraint(item: component,
                                       attribute: .trailing,
                                       relatedBy: .lessThanOrEqual,
                                       toItem: rightComponent,
                                       attribute: .leading,
                                       multiplier: 1,
                                       constant: (0 - right)),
                    NSLayoutConstraint(item: component,
                                       attribute: .top,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .top,
                                       multiplier: 1,
                                       constant: top),
                    NSLayoutConstraint(item: component,
                                       attribute: .bottom,
                                       relatedBy: .equal,
                                       toItem: parent,
                                       attribute: .bottom,
                                       multiplier: 1,
                                       constant: (0 - bottom))
                ])
        }
    }
    
    class func generateNewComponentWidthConstraint(component: UIView, width: CGFloat) {
        component.translatesAutoresizingMaskIntoConstraints = false
            component.addConstraints(
                [
                    NSLayoutConstraint(item: component,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: width)
                ])
    }
    
    class func removeLastCharacters(result:String,length:Int) -> String {
        if result.count < length {
            return ""
        }
        return result.substring(to: result.index(result.endIndex, offsetBy: (0 - length)))
    }
    
    class func removeFirstCharacters(result:String,length:Int) -> String {
        if result.count < length {
            return ""
        }
        return result.substring(from: result.index(result.startIndex, offsetBy: (length)))
    }
    
    class func updateTableViewHeight(consHeightTblView: NSLayoutConstraint, tblView: UITableView, minimumHeight: CGFloat) {
        consHeightTblView.constant = 50000
        tblView.reloadData()
        tblView.layoutIfNeeded()
        
        var tableHeight:CGFloat = minimumHeight
        for obj in tblView.visibleCells {
            if let cell = obj as? UITableViewCell {
                tableHeight += cell.bounds.height
            }
        }
        consHeightTblView.constant = tableHeight
        tblView.sizeToFit()
        tblView.layoutIfNeeded()
    }
}
