//
//  ViewExtension.swift
//  IBA Members Directory
//
//  Created by George Smith on 14/03/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import UIKit

extension UIView {
    func bounceIn() {
        self.transform = CGAffineTransform(scaleX: 0,y: 0)
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    public func layoutAttachAll(to: UIView) {
        let leadingConstraint = NSLayoutConstraint(item: to, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: to, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: to, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: to, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        to.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
    
    public func roundView(radius: CGFloat = 0.15) {
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius =  self.frame.width  / 2
    }
    
    public func addDropShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 10
    }
}

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        addSublayer(border)
    }
}
