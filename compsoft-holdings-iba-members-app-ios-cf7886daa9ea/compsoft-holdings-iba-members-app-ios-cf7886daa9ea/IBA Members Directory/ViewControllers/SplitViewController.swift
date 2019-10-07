
//
//  SplitViewController.swift
//  IBA Members Directory
//
//  Created by Jacob King on 13/05/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    let bubblePresentAnimationController = BubblePresentAnimationController()
    var collapseToView: UIView!
    
    override func awakeFromNib() {
        delegate = self

    }
    
    //SplitViewController delegate methods
    func splitViewController(_ svc: UISplitViewController, willHide aViewController: UIViewController, with barButtonItem: UIBarButtonItem, for pc: UIPopoverController) {
        
        let navigationController = svc.viewControllers[1] as! UINavigationController
        let currentViewController = navigationController.viewControllers[0] 
            
        barButtonItem.title = restorationIdentifier
        currentViewController.navigationItem.leftBarButtonItem = barButtonItem

    }
    
    func splitViewController(_ svc: UISplitViewController, willShow aViewController: UIViewController, invalidating barButtonItem: UIBarButtonItem) {

        let navigationController = svc.viewControllers[1] as! UINavigationController
        let currentViewController = navigationController.viewControllers[0] 
        currentViewController.navigationItem.leftBarButtonItem = nil

    }
    
    func splitViewController(_ svc: UISplitViewController, shouldHide vc: UIViewController, in orientation: UIInterfaceOrientation) -> Bool {
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            return false
        }
        return true
    }
    
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }

}

extension SplitViewController: UIViewControllerTransitioningDelegate {
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
