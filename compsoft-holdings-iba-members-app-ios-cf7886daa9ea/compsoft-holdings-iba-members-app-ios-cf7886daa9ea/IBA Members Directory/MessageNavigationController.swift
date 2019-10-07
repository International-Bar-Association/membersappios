//
//  MessageNavigationController.swift
//  IBA Members Directory
//
//  Created by George Smith on 02/08/2018.
//  Copyright © 2018 Compsoft plc. All rights reserved.
//

import UIKit

class MessageNavigationController: UINavigationController {
    let bubblePresentAnimationController = BubblePresentAnimationController()
    var collapseToView: UIView!
    
}

extension MessageNavigationController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        bubblePresentAnimationController.originalFrame = appDel.bubbleContainerView.frame
        if let vc = presenting as? ConferenceMenuViewController {
            bubblePresentAnimationController.viewTransforming = vc.scheduleButton
            collapseToView = vc.scheduleButton
        } else {
            bubblePresentAnimationController.viewTransforming = self.view
        }
        
        return bubblePresentAnimationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        bubblePresentAnimationController.dismissing = true
        bubblePresentAnimationController.viewTransforming = collapseToView
        return bubblePresentAnimationController
    }
}
