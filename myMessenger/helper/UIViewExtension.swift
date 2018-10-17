//
//  UIViewExtension.swift
//  myMessenger
//
//  Created by Mokhtar on 10/14/18.
//  Copyright © 2018 Ahmed Mokhtar. All rights reserved.
//

import UIKit

extension UIView {
    
    func setupAnchorsWithConstant(top : NSLayoutYAxisAnchor?,
                                  bottom : NSLayoutYAxisAnchor?,
                                  left : NSLayoutXAxisAnchor?,
                                  right : NSLayoutXAxisAnchor?,
                                  topConstant : CGFloat?,
                                  bottomConstant : CGFloat?,
                                  leftConstant : CGFloat?,
                                  rightConstant : CGFloat?) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top, let topConstant = topConstant {
            topAnchor.constraint(equalTo: top, constant: topConstant).isActive = true
        }
        
        if let bottom = bottom, let bottomConstant = bottomConstant {
            bottomAnchor.constraint(equalTo: bottom, constant: bottomConstant).isActive = true
        }
        
        if let left = left, let leftConstant = leftConstant {
            leftAnchor.constraint(equalTo: left, constant: leftConstant).isActive = true
        }
        
        if let right = right, let rightConstant = rightConstant {
            rightAnchor.constraint(equalTo: right, constant: rightConstant).isActive = true
        }
        
    }
    
    
    func setupAnchors(top : NSLayoutYAxisAnchor?,
                      bottom : NSLayoutYAxisAnchor?,
                      left : NSLayoutXAxisAnchor?,
                      right : NSLayoutXAxisAnchor?) {
        setupAnchorsWithConstant(top: top, bottom: bottom, left: left, right: right, topConstant: 0, bottomConstant: 0, leftConstant: 0, rightConstant: 0)
    }
    
    func setupXYAnchors (top : NSLayoutYAxisAnchor? = nil,
                         bottom : NSLayoutYAxisAnchor? = nil,
                         leading : NSLayoutXAxisAnchor? = nil,
                         trailing : NSLayoutXAxisAnchor? = nil,
                         centerX : NSLayoutXAxisAnchor? = nil,
                         centerY : NSLayoutYAxisAnchor? = nil,
                         
                         topConstant : CGFloat = 0,
                         bottomConstant : CGFloat = 0,
                         leadingConstant : CGFloat = 0,
                         trailingConstant : CGFloat = 0,
                         centerXConstant : CGFloat = 0,
                         centerYConstant : CGFloat = 0)
                            -> [String:NSLayoutConstraint] {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraintDictionary = [String:NSLayoutConstraint]()
        
        if let top = top {
            let top = topAnchor.constraint(equalTo: top, constant: topConstant)
            top.isActive = true
            constraintDictionary["top"] = top
        }
        
        if let bottom = bottom {
            let bottom = bottomAnchor.constraint(equalTo: bottom, constant: bottomConstant)
            bottom.isActive = true
            constraintDictionary["bottom"] = bottom
        }
        
        if let leading = leading {
            let leading = leadingAnchor.constraint(equalTo: leading, constant: leadingConstant)
            leading.isActive = true
            constraintDictionary["leading"] = leading
        }
        
        if let trailing = trailing {
            let trailing = trailingAnchor.constraint(equalTo: trailing, constant: trailingConstant)
            trailing.isActive = true
            constraintDictionary["trailing"] = trailing
        }
        
        
        
        if let centerX = centerX {
            let centerX = centerXAnchor.constraint(equalTo: centerX, constant: centerXConstant)
            centerX.isActive = true
            constraintDictionary["centerX"] = centerX
        }
        
        if let centerY = centerY {
            let centerY = centerYAnchor.constraint(equalTo: centerY, constant: centerYConstant)
            centerY.isActive = true
            constraintDictionary["centerY"] = centerY
        }
        
        return constraintDictionary
        
    }
    
    
    func setUpDimensionsAnchors (width : NSLayoutDimension?,
                                 height : NSLayoutDimension?,
                                 for widthConstant : CGFloat = 0,
                                 for widthMultiplier : CGFloat = 1 ,
                                 for heightConstant : CGFloat = 0,
                                 for heightMultiplier : CGFloat = 1) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let height = height {
            heightAnchor.constraint(equalTo: height, multiplier: heightMultiplier, constant: heightConstant).isActive = true
        } else {
            heightAnchor.constraint(equalToConstant: heightConstant).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalTo: width, multiplier: widthMultiplier, constant: widthConstant).isActive = true
        } else {
            widthAnchor.constraint(equalToConstant: widthConstant).isActive = true
        }
    }
}
