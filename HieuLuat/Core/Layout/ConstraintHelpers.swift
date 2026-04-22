//
//  ConstraintHelpers.swift
//  HieuLuat
//
//  Created by AI Assistant on 4/22/26.
//  Copyright © 2026 VietLH. All rights reserved.
//

import UIKit

/// Helper class for programmatic Auto Layout constraint generation
class ConstraintHelpers {
    
    private static let defaultPriority = UILayoutPriority(999)
    
    // MARK: - Single Directional Constraints
    
    /// Add vertical constraints (top to bottom or top below another view)
    static func addVerticalConstraints(
        parent: UIView,
        topComponent: UIView,
        component: UIView,
        top: CGFloat,
        left: CGFloat,
        right: CGFloat,
        isInside: Bool
    ) {
        component.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(component)
        
        let constraints: [NSLayoutConstraint]
        
        if isInside {
            constraints = [
                component.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: left),
                component.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -right),
                component.topAnchor.constraint(equalTo: topComponent.topAnchor, constant: top)
            ]
        } else {
            constraints = [
                component.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: left),
                component.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -right),
                component.topAnchor.constraint(equalTo: topComponent.bottomAnchor, constant: top)
            ]
        }
        
        constraints.forEach { $0.priority = defaultPriority }
        NSLayoutConstraint.activate(constraints)
    }
    
    /// Add horizontal constraints (left to right or left next to another view)
    static func addHorizontalConstraints(
        parent: UIView,
        leftComponent: UIView,
        component: UIView,
        left: CGFloat,
        top: CGFloat,
        bottom: CGFloat,
        isInside: Bool
    ) {
        component.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(component)
        
        let constraints: [NSLayoutConstraint]
        
        if isInside {
            constraints = [
                component.leadingAnchor.constraint(equalTo: leftComponent.leadingAnchor, constant: left),
                component.topAnchor.constraint(equalTo: parent.topAnchor, constant: top),
                component.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -bottom)
            ]
        } else {
            constraints = [
                component.leadingAnchor.constraint(equalTo: leftComponent.trailingAnchor, constant: left),
                component.topAnchor.constraint(equalTo: parent.topAnchor, constant: top),
                component.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -bottom)
            ]
        }
        
        constraints.forEach { $0.priority = defaultPriority }
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Bidirectional Constraints
    
    /// Add constraints between top and bottom components
    static func addVerticalConstraints(
        parent: UIView,
        topComponent: UIView,
        bottomComponent: UIView,
        component: UIView,
        top: CGFloat,
        left: CGFloat,
        right: CGFloat,
        bottom: CGFloat,
        isInside: Bool
    ) {
        component.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(component)
        
        let constraints: [NSLayoutConstraint]
        
        if isInside {
            constraints = [
                component.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: left),
                component.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -right),
                component.topAnchor.constraint(equalTo: topComponent.topAnchor, constant: top),
                component.bottomAnchor.constraint(equalTo: bottomComponent.bottomAnchor, constant: -bottom)
            ]
        } else {
            constraints = [
                component.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: left),
                component.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -right),
                component.topAnchor.constraint(equalTo: topComponent.bottomAnchor, constant: top),
                component.bottomAnchor.constraint(equalTo: bottomComponent.bottomAnchor, constant: -bottom)
            ]
        }
        
        constraints.forEach { $0.priority = defaultPriority }
        NSLayoutConstraint.activate(constraints)
    }
    
    /// Add constraints between left and right components
    static func addHorizontalConstraints(
        parent: UIView,
        leftComponent: UIView,
        rightComponent: UIView,
        component: UIView,
        left: CGFloat,
        right: CGFloat,
        top: CGFloat,
        bottom: CGFloat,
        isInside: Bool
    ) {
        component.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(component)
        
        let constraints: [NSLayoutConstraint]
        
        if isInside {
            constraints = [
                component.leadingAnchor.constraint(equalTo: leftComponent.leadingAnchor, constant: left),
                component.trailingAnchor.constraint(equalTo: rightComponent.trailingAnchor, constant: -right),
                component.topAnchor.constraint(equalTo: parent.topAnchor, constant: top),
                component.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -bottom)
            ]
        } else {
            constraints = [
                component.leadingAnchor.constraint(equalTo: leftComponent.trailingAnchor, constant: left),
                component.trailingAnchor.constraint(equalTo: rightComponent.trailingAnchor, constant: -right),
                component.topAnchor.constraint(equalTo: parent.topAnchor, constant: top),
                component.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -bottom)
            ]
        }
        
        constraints.forEach { $0.priority = defaultPriority }
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Centered Constraints
    
    /// Add constraints with vertical centering
    static func addVerticalConstraintsWithCenterX(
        parent: UIView,
        topComponent: UIView,
        component: UIView,
        top: CGFloat,
        isInside: Bool
    ) {
        component.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(component)
        
        var constraints: [NSLayoutConstraint] = []
        
        if isInside {
            constraints.append(component.topAnchor.constraint(equalTo: topComponent.topAnchor, constant: top))
        } else {
            constraints.append(component.topAnchor.constraint(equalTo: topComponent.bottomAnchor, constant: top))
        }
        
        constraints.append(component.centerXAnchor.constraint(equalTo: parent.centerXAnchor))
        
        constraints.forEach { $0.priority = defaultPriority }
        NSLayoutConstraint.activate(constraints)
    }
    
    /// Add constraints with horizontal centering
    static func addHorizontalConstraintsWithCenterY(
        parent: UIView,
        leftComponent: UIView,
        component: UIView,
        left: CGFloat,
        isInside: Bool
    ) {
        component.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(component)
        
        var constraints: [NSLayoutConstraint] = []
        
        if isInside {
            constraints.append(component.leadingAnchor.constraint(equalTo: leftComponent.leadingAnchor, constant: left))
        } else {
            constraints.append(component.leadingAnchor.constraint(equalTo: leftComponent.trailingAnchor, constant: left))
        }
        
        constraints.append(component.centerYAnchor.constraint(equalTo: parent.centerYAnchor))
        
        constraints.forEach { $0.priority = defaultPriority }
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Fixed Size Constraints
    
    /// Add width constraint to component
    static func addWidthConstraint(to component: UIView, width: CGFloat) {
        component.translatesAutoresizingMaskIntoConstraints = false
        let constraint = component.widthAnchor.constraint(equalToConstant: width)
        constraint.priority = defaultPriority
        constraint.isActive = true
    }
    
    /// Add height constraint to component
    static func addHeightConstraint(to component: UIView, height: CGFloat) {
        component.translatesAutoresizingMaskIntoConstraints = false
        let constraint = component.heightAnchor.constraint(equalToConstant: height)
        constraint.priority = defaultPriority
        constraint.isActive = true
    }
    
    // MARK: - Linear Layout
    
    /// Automatically generate linear (vertical or horizontal) constraints for multiple views
    static func createLinearLayout(
        in parent: UIView,
        views: [UIView],
        axis: NSLayoutConstraint.Axis,
        top: CGFloat = 0,
        bottom: CGFloat = 0,
        left: CGFloat = 0,
        right: CGFloat = 0,
        spacing: CGFloat = 0
    ) {
        guard !views.isEmpty else { return }
        
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        views.forEach { parent.addSubview($0) }
        
        var constraints: [NSLayoutConstraint] = []
        
        for (index, view) in views.enumerated() {
            if axis == .vertical {
                // Horizontal constraints (same for all)
                constraints.append(view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: left))
                constraints.append(view.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -right))
                
                // Vertical constraints
                if index == 0 {
                    constraints.append(view.topAnchor.constraint(equalTo: parent.topAnchor, constant: top))
                } else {
                    constraints.append(view.topAnchor.constraint(equalTo: views[index - 1].bottomAnchor, constant: spacing))
                }
                
                if index == views.count - 1 {
                    constraints.append(view.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -bottom))
                }
            } else {
                // Horizontal constraints
                // Vertical constraints (same for all)
                constraints.append(view.topAnchor.constraint(equalTo: parent.topAnchor, constant: top))
                constraints.append(view.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -bottom))
                
                // Horizontal constraints
                if index == 0 {
                    constraints.append(view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: left))
                } else {
                    constraints.append(view.leadingAnchor.constraint(equalTo: views[index - 1].trailingAnchor, constant: spacing))
                }
                
                if index == views.count - 1 {
                    constraints.append(view.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -right))
                }
            }
        }
        
        constraints.forEach { $0.priority = defaultPriority }
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Priority Management
    
    /// Lower internal constraint priorities to prevent conflicts
    static func lowerConstraintPriorities(_ view: UIView) {
        let constraintsToReplace = view.constraints.filter { constraint in
            guard constraint.priority == .required else { return false }
            let first = constraint.firstItem as? UIView
            let second = constraint.secondItem as? UIView
            let involvesSubview = (first != nil && first != view) || (second != nil && second != view)
            return involvesSubview
        }
        
        for old in constraintsToReplace {
            old.isActive = false
            let replacement = NSLayoutConstraint(
                item: old.firstItem!,
                attribute: old.firstAttribute,
                relatedBy: old.relation,
                toItem: old.secondItem,
                attribute: old.secondAttribute,
                multiplier: old.multiplier,
                constant: old.constant
            )
            replacement.priority = defaultPriority
            replacement.isActive = true
        }
        
        for subview in view.subviews {
            lowerConstraintPriorities(subview)
        }
    }
}
