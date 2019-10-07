//
//  FlipPresentAnimationController.swift
//  IBA Members Directory
//
//  Created by George Smith on 13/03/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import UIKit

class BubblePresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning,CAAnimationDelegate {
    var originalFrame = CGRect.zero
    var animationType: AnimationBubbleEntryType = .grow
    var showAnim: CABasicAnimation!
    var maskPath: UIBezierPath!
    var maskLayer: CAShapeLayer!
    var growToRadius = CGFloat(0.0)
    var viewTransforming: UIView!
    var dismissing = false
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    weak var transitionContext: UIViewControllerContextTransitioning?
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        self.transitionContext = transitionContext
        if dismissing {
            show()
                    } else {
            show()
        }
    }
    
    func hide() {
        
        let containerView = transitionContext!.containerView
        guard let fromViewController = transitionContext!.viewController(forKey: UITransitionContextViewControllerKey.from) else {
            return
        }
        
        guard let toViewController = transitionContext!.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }
        
        let button = viewTransforming! // in this
        let fromViewControllerSnapshot = fromViewController.view.resizableSnapshotView(from: fromViewController.view.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)
        containerView.addSubview(fromViewControllerSnapshot!)
        fromViewController.view.alpha = 0.0
        let toViewControllerSnapshotView = toViewController.view.resizableSnapshotView(from: toViewController.view.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)
        containerView.insertSubview(toViewControllerSnapshotView!, belowSubview: fromViewControllerSnapshot!)
        

        
        let portrait = fromViewController.view.frame.width > fromViewController.view.frame.height
        growToRadius = fromViewController.view.frame.height * 2
        if portrait {
            growToRadius = fromViewController.view.frame.width * 2
        }
        let circleMaskPathInitial = UIBezierPath(ovalIn: toViewController.view.frame)
        let radius = growToRadius
        let circleMaskPathFinal = UIBezierPath(ovalIn: button.frame)
        CATransaction.begin()
        var maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathInitial.cgPath
        fromViewControllerSnapshot!.layer.mask = maskLayer

        var maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration = self.transitionDuration(using: transitionContext)
        maskLayerAnimation.delegate = self
        DispatchQueue.main.async {
            maskLayer.add(maskLayerAnimation, forKey: "path")
        }

        CATransaction.commit()
    }
    
    func show() {
        
        //2
        let containerView = transitionContext!.containerView
        guard let fromViewController = transitionContext!.viewController(forKey: UITransitionContextViewControllerKey.from) else {
            return
        }
        
        guard let toViewController = transitionContext!.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }
        
        toViewController.modalPresentationStyle = UIModalPresentationStyle.custom
        let button = viewTransforming!
        
        //3
        containerView.addSubview(toViewController.view)
        
        //4
        
        let portrait = toViewController.view.frame.width > toViewController.view.frame.height
        growToRadius = toViewController.view.frame.height * 2
        if portrait {
            growToRadius = toViewController.view.frame.width * 2
        }
        let circleMaskPathInitial = UIBezierPath(ovalIn: button.frame)
        let radius = growToRadius //sqrt((extremePoint.x*extremePoint.x) + (extremePoint.y*extremePoint.y))
        let circleMaskPathFinal = UIBezierPath(ovalIn: button.frame.insetBy(dx: -radius, dy: -radius))
        
        CATransaction.begin()
        //5
        var maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        toViewController.view.layer.mask = maskLayer
        
        //6
        var maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration = self.transitionDuration(using: transitionContext)
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "pathAnim")
        
        CATransaction.commit()

    }
    
    func animationDidStop(_ anim: CAAnimation!, finished flag: Bool) {
        DispatchQueue.main.async {
        self.transitionContext?.completeTransition(!self.transitionContext!.transitionWasCancelled)
        }
    }

    
//    func showConferenceOptionsView() {
//        let portrait = self.frame.width > self.frame.height
//        growToRadius = self.frame.height * 2
//        if portrait {
//            growToRadius = self.frame.width * 2
//        }
//        
//        let growToRect = CGRect(x: self.frame.minX - self.frame.width / 2, y: self.frame.minY - self.frame.height / 2, width: growToRadius, height: growToRadius)
//        maskPath = UIBezierPath(ovalIn: bubbleView.frame)
//        let bigCirclePath = UIBezierPath(ovalIn: growToRect)
//        let pathAnim = CABasicAnimation(keyPath: "path")
//        pathAnim.delegate = self
//        pathAnim.fromValue = maskPath.cgPath
//        pathAnim.toValue = bigCirclePath
//        pathAnim.duration = 0.2
//        maskLayer.path = bigCirclePath.cgPath
//        maskLayer.add(pathAnim, forKey: "pathAnimation")
//        
//        self.bringSubview(toFront: containerView)
//    }

}
