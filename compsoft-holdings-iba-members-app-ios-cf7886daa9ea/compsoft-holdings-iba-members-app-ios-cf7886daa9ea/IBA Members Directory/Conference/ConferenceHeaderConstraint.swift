//
//  ConferenceHeaderConstraint.swift
//  IBA Members Directory
//
//  Created by George Smith on 16/03/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import UIKit

class HeaderTopConstraint {
    
    var closed:CGFloat!
    var peak:CGFloat!
    var open:CGFloat!
    
    var constraint: NSLayoutConstraint!
    var scrollMapHeightConstraint: NSLayoutConstraint!
    
    let peakedMapHeightConstraint: CGFloat = 0.75
    let closedMapHeightConstraint: CGFloat = 0.95
    
    var onPeak = {}
    var onClose = {}
    var onOpen = {}
    
    var onPeaking = {}
    var onClosing = {}
    var onOpening = {}
    
    init(constraintToAnimate: NSLayoutConstraint, closedValue:CGFloat, peakValue: CGFloat, openValue: CGFloat) {
        constraint = constraintToAnimate
        closed = closedValue
        open = openValue
        peak = peakValue
    }
    
    func adjustPeakHeight(height: CGFloat, view: UIView) {
        
        if constraint.constant == peak {
            UIView.animate(withDuration: 0.4, animations: {
                self.constraint.constant = height
                view.layoutIfNeeded()
            })
        }
        self.peak = height
    }
    
    func didTapHeader(view: UIView) {
        switch constraint.constant {
        case closed:
            UIView.animate(withDuration: 0.4, animations: {
                self.constraint.constant = self.open
                view.layoutIfNeeded()
                //self.scrollMapHeightConstraint.multiplier = peakedMapHeightConstraint
                self.onClosing()
            }, completion: { (y) in
                self.onOpen()
            })
            break
        case peak:
            UIView.animate(withDuration: 0.4, animations: {
                self.constraint.constant = self.open
                view.layoutIfNeeded()
                self.onClosing()
            }, completion: { (y) in
                self.onOpen()
            })
            break
        case open:
            UIView.animate(withDuration: 0.4, animations: {
                self.constraint.constant = self.peak
                //self.scrollMapHeightConstraint.multiplier = peakedMapHeightConstraint
                view.layoutIfNeeded()
                self.onPeaking()
            }, completion: { (y) in
                self.onPeak()
            })
            break
        default:
            break
        }
    }
    
    func didSwipeHeader(view: UIView, directionUp: Bool) {
        switch constraint.constant {
        case closed:
            UIView.animate(withDuration: 0.4, animations: {
                if directionUp {
                    self.constraint.constant = self.peak
                    
                }
                self.onPeaking()
                view.layoutIfNeeded()
            }, completion: { (y) in
                self.onPeak()
            })
            
            break
        case peak:
            UIView.animate(withDuration: 0.4, animations: {
                if directionUp {
                    self.constraint.constant = self.open
                    self.onOpening()
                } else {
                    self.constraint.constant = self.closed
                    self.onClosing()
                }
                
                view.layoutIfNeeded()
            }, completion: { (y) in
                if directionUp {
                    self.onOpen()
                } else {
                    self.onClose()
                }

            })
            break
        case open:
            UIView.animate(withDuration: 0.4, animations: {
                if !directionUp {
                    self.constraint.constant = self.peak
                    self.onPeaking()
                }
                view.layoutIfNeeded()
            }, completion: { (y) in
                self.onPeak()
            })
            
            break
        default:
            break
        }
    }
}
