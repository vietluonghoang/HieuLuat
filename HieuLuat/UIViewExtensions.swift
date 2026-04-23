//
//  UIViewExtensions.swift
//  HieuLuat
//
//  Created by AI Assistant on 4/22/26.
//  Copyright © 2026 VietLH. All rights reserved.
//

import UIKit

// MARK: - Image Scaling Extensions

extension UIImage {
    
    /// Scale image to target width while maintaining aspect ratio
    /// - Parameter targetWidth: Target width in points
    /// - Returns: Scaled UIImage
    func scaledToWidth(_ targetWidth: CGFloat) -> UIImage? {
        let scale = targetWidth / self.size.width
        let newHeight = self.size.height * scale
        let newSize = CGSize(width: targetWidth, height: newHeight)
        
        return self.scaledToSize(newSize)
    }
    
    /// Scale image to target height while maintaining aspect ratio
    /// - Parameter targetHeight: Target height in points
    /// - Returns: Scaled UIImage
    func scaledToHeight(_ targetHeight: CGFloat) -> UIImage? {
        let scale = targetHeight / self.size.height
        let newWidth = self.size.width * scale
        let newSize = CGSize(width: newWidth, height: targetHeight)
        
        return self.scaledToSize(newSize)
    }
    
    /// Scale image to specific size using modern rendering
    /// - Parameter newSize: Target size
    /// - Returns: Scaled UIImage
    private func scaledToSize(_ newSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        let image = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return image
    }
}

// MARK: - Button State Extensions

extension UIButton {
    
    /// Update button state with colors
    /// - Parameters:
    ///   - isActive: Active state
    ///   - activeColor: Color when active
    ///   - inactiveColor: Color when inactive
    func updateState(isActive: Bool, activeColor: UIColor, inactiveColor: UIColor) {
        if isActive {
            self.backgroundColor = activeColor
            self.setTitleColor(inactiveColor, for: .normal)
        } else {
            self.backgroundColor = inactiveColor
            self.setTitleColor(activeColor, for: .normal)
        }
    }
}

// MARK: - View State Extensions

extension UIView {
    
    /// Update view background color based on state
    /// - Parameters:
    ///   - isActive: Active state
    ///   - activeColor: Color when active
    ///   - inactiveColor: Color when inactive
    func updateBackgroundState(isActive: Bool, activeColor: UIColor, inactiveColor: UIColor) {
        self.backgroundColor = isActive ? activeColor : inactiveColor
    }
    
    /// Get screen width
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    /// Get screen height
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
}

// MARK: - TableView Height Extensions

extension UITableView {
    
    /// Update table view height based on content
    /// - Parameters:
    ///   - constraint: Height layout constraint to update
    ///   - minimumHeight: Minimum allowed height
    func updateHeight(constraint: NSLayoutConstraint, minimumHeight: CGFloat = 0) {
        guard self.window != nil else {
            DispatchQueue.main.async {
                self.updateHeight(constraint: constraint, minimumHeight: minimumHeight)
            }
            return
        }
        
        // Temporarily set large height to measure content
        constraint.constant = 50000
        self.reloadData()
        self.layoutIfNeeded()
        
        // Calculate actual content height
        var contentHeight: CGFloat = minimumHeight
        for cell in self.visibleCells {
            contentHeight += cell.bounds.height
        }
        
        // Update constraint with actual height
        constraint.constant = max(contentHeight, minimumHeight)
        self.layoutIfNeeded()
    }
}

// MARK: - Label Font Extensions

extension UILabel {
    
    /// Apply standard content text font
    func applyContentFont() {
        self.font = UIFont.systemFont(ofSize: 15.0)
    }
}

// MARK: - String Trimming Extensions

extension String {
    
    /// Remove last N characters from string
    /// - Parameter count: Number of characters to remove
    /// - Returns: Trimmed string or empty string if count exceeds length
    func removingLast(_ count: Int) -> String {
        guard self.count >= count else { return "" }
        return String(self[..<self.index(self.endIndex, offsetBy: -count)])
    }
    
    /// Remove first N characters from string
    /// - Parameter count: Number of characters to remove
    /// - Returns: Trimmed string or empty string if count exceeds length
    func removingFirst(_ count: Int) -> String {
        guard self.count >= count else { return "" }
        return String(self[self.index(self.startIndex, offsetBy: count)...])
    }
}
