//
//  ConferenceWebViewController.swift
//  IBA Members Directory
//
//  Created by George Smith on 14/03/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import UIKit

class ConferenceWebViewController: UIViewController {
    let bubblePresentAnimationController = BubblePresentAnimationController()
    var webVc: SwiftWebVC!
    var collapseToView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = Settings.getConferencePrimaryColour()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVc = segue.destination as! UINavigationController
        if let url = Settings.getConferenceURL() {
            webVc = SwiftWebVC(urlString: url)
        } else {
            webVc = SwiftWebVC(urlString: "http://google.com")
        }
        
        navVc.pushViewController(webVc, animated: true)
        webVc.delegate = self
        //webVc.titleColor = UIColor.white
        let backButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        
        navVc.navigationItem.leftBarButtonItems?.append(backButton)
        
    }
    
    @objc func close() {
        
    }
}

extension ConferenceWebViewController: SwiftWebVCDelegate {
    public func didStartLoading() {
        
    }
    
    func didFinishLoading(success: Bool) {
        
    }

    
}


extension ConferenceWebViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        bubblePresentAnimationController.originalFrame = appDel.bubbleContainerView.frame
        if let vc = presenting as? ConferenceMenuViewController {
            bubblePresentAnimationController.viewTransforming = vc.websiteButton
            collapseToView = vc.websiteButton
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
