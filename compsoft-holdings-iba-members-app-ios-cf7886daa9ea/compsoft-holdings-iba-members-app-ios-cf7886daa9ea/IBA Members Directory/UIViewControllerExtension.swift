//
//  UIViewControllerExtension.swift
//  IBA Members Directory
//
//  Created by George Smith on 10/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import UIKit

class IBABaseUIViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(showConfBubbleView), name: NSNotification.Name(rawValue: "ConferenceStatusUpdated"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
}

extension UIViewController {
    
    @objc func showConfBubbleView() {
        
        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if let profile = MemberProfile.getMyProfile() {
            if profile.shouldSeeConfBubble == true {
                Networking.getConferenceDetails(profile.currentConference as! Int, success: { (response) in
                    let conference = Conference()
                    conference.conferenceId = profile.currentConference
                    conference.name = response.name as NSString?
                    conference.venue = response.venue as NSString?
                    conference.startDate = response.start!.stringToDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ") as NSDate?
                    conference.endDate = response.end!.stringToDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ") as NSDate?
                    conference.commit()
                    if let confStart = conference.startDate as? Date, let confEnd = conference.endDate as? Date {
                        if confStart < Date() && confEnd > Date() {
                           
                            appDelegate.bubbleContainerView.showBubble()
                            
                            
                        }
                    }
                }, failure: { (error) in
                    appDelegate.bubbleContainerView.hideBubble()
                    print(error)
                })
                
            } else {
                 appDelegate.bubbleContainerView.hideBubble()
            }
        } else {
             appDelegate.bubbleContainerView.hideBubble()
        }
        
        if !appDelegate.bubbleIsVisible {
            let windowView = UIApplication.shared.keyWindow!
            windowView.addSubview(appDelegate.bubbleContainerView)
            let trailing = NSLayoutConstraint(item: appDelegate.bubbleContainerView, attribute: .trailing, relatedBy: .equal, toItem: windowView, attribute: .trailing, multiplier: 1, constant: 0)
            windowView.addConstraint(trailing)
            let top = NSLayoutConstraint(item: appDelegate.bubbleContainerView, attribute: .top, relatedBy: .equal, toItem: windowView, attribute: .top, multiplier: 1, constant: 0)
            windowView.addConstraint(top)
            let bottom = NSLayoutConstraint(item: appDelegate.bubbleContainerView, attribute: .bottom, relatedBy: .equal, toItem: windowView, attribute: .bottom, multiplier: 1, constant: 0)
            windowView.addConstraint(bottom)
            let leading = NSLayoutConstraint(item: appDelegate.bubbleContainerView, attribute: .leading, relatedBy: .equal, toItem: windowView, attribute: .leading, multiplier: 1, constant: 0)
            windowView.addConstraint(leading)
            
            appDelegate.bubbleIsVisible = true
            //appDelegate.bubbleContainerView.animateEntry()
        }
    }
    
    func hideConfBubbleView() {
        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.bubbleContainerView.hideBubble()
    }
    
    func isModal() -> Bool {
            
        if let navigationController = self.navigationController{
            if navigationController.viewControllers.first != self{
                return false
            }
        }
            
        if self.presentingViewController != nil {
            return true
        }
            
        if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController  {
                return true
        }
            
        if self.tabBarController?.presentingViewController is UITabBarController {
                return true
        }
            
        return false
        }
    
    open static let ALERT_CANCEL_TITLE = NSLocalizedString("alert.cancelButton", value: "Cancel", comment: "list item button title")
    
    /** Shows an alert message with a default OK button */
    public func showAlert(title: String?, message: String?, okTitle: String = "OK", okHandler: ((_ alertAction: UIAlertAction) -> Void)? = nil) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: okTitle, style: .default, handler: okHandler))
        if self.view.superview != nil {
            self.present(alertView, animated: true, completion: nil)
        } else {
            debugPrint("Unable to show UI ALERT as this view is not on the heirarchy: \(message ?? "")")
        }
    }
    
    public func showAlert(title: String?, message: String?, okTitle: String, okHandler: ((UIAlertAction) -> Void)?, cancelTitle: String, cancelStyle: UIAlertActionStyle = .cancel, cancelHandler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okTitle, style: .default, handler: okHandler)
        alertController.addAction(okAction)
        let cancelAction = UIAlertAction(title: cancelTitle, style: cancelStyle, handler: cancelHandler)
        alertController.addAction(cancelAction)
        if self.view.superview != nil {
            self.present(alertController, animated: true, completion: nil)
        } else {
            debugPrint("Unable to show UI ALERT as this view is not on the heirarchy: \(message ?? "")")
        }
    }
    
    public func showAlert(title: String?, message: String?, okTitle: String, okHandler: ((UIAlertAction, UIAlertController) -> Void)?, textFieldConfigHandler: ((UITextField) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField(configurationHandler: textFieldConfigHandler)
        alert.addAction(UIAlertAction(title: okTitle, style: .default, handler: { (action) -> Void in
            if okHandler != nil {
                okHandler!(action, alert)
            }
        }))
        if self.view.superview != nil {
            self.present(alert, animated: true, completion: nil)
        } else {
            debugPrint("Unable to show UI ALERT as this view is not on the heirarchy: \(message ?? "")")
        }
    }
    
    public func showAlert(title: String?, message: String?, okTitle: String, okHandler: ((UIAlertAction, UIAlertController) -> Void)?, cancelTitle: String, cancelStyle: UIAlertActionStyle = .cancel,  cancelHandler: ((UIAlertAction) -> Void)?, textFieldConfigHandler: ((UITextField) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField(configurationHandler: textFieldConfigHandler)
        alert.addAction(UIAlertAction(title: okTitle, style: .default, handler: { (action) -> Void in
            if okHandler != nil {
                okHandler!(action, alert)
            }
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: cancelStyle, handler: { (action) -> Void in
            if cancelHandler != nil {
                cancelHandler!(action)
            }
        }))
        if self.view.superview != nil {
            self.present(alert, animated: true, completion: nil)
        } else {
            debugPrint("Unable to show UI ALERT as this view is not on the heirarchy: \(message ?? "")")
        }
    }
    public typealias ActionSheetOptions = (title: String, action: (UIAlertAction) -> Void)
    
    public func showActionSheet(with options:[ActionSheetOptions]) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for option in options {
            let action = UIAlertAction(title: option.title, style: .default, handler: option.action)
            actionSheet.addAction(action)
        }
        let cancelAction = UIAlertAction(title: UIViewController.ALERT_CANCEL_TITLE, style: .cancel) { (action) in
            actionSheet.dismiss(animated: true, completion: nil)
        }
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
}
