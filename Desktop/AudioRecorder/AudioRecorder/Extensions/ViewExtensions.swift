//
//  ViewExtensions.swift
//  AudioRecorder
//
//  Created by Asad Ullah on 06/11/2020.
//

import UIKit

extension UIView {
    
    func setCornerRadius(radius: CGFloat) {
        self.layer.cornerRadius = radius
    }
    
   func setCustomCornerRadius(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func setShadow(shadowColor: UIColor, shadowOpacity: Float, shadowRadius: CGFloat, offset: CGSize) {
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOffset = offset
    }

    func setBorder(with color: UIColor, _ width: CGFloat) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
}
