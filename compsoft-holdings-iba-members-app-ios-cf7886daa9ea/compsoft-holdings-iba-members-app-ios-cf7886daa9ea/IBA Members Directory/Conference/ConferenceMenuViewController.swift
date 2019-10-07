//
//  ConferenceMenuViewController.swift
//  IBA Members Directory
//
//  Created by George Smith on 13/03/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import UIKit
import MessageUI

class ConferenceMenuViewController: UIViewController {
    
    let bubblePresentAnimationController = BubblePresentAnimationController()
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    
    
    var conference: Conference!
    var badge:BadgeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.alpha = 0.0
        
        if badge == nil {
            badge = BadgeView(frame: CGRect(x: (self.chatButton.frame.width) - 40, y: 20, width: 20, height: 20))
            
            chatButton.addSubview(badge)
        }
        badge.setAmount(count: Settings.getBadgeP2PAmount())
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadge), name: NSNotification.Name(rawValue: "P2PMessageReceived"), object: nil)
    }
    
    @objc func updateBadge() {
        self.badge.setAmount(count: Settings.getBadgeP2PAmount())
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = Settings.getConferencePrimaryColour()
        self.view.backgroundColor = Settings.getConferencePrimaryColour()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        closeButton.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        closeButton.alpha = 1.0
        closeButton.bounceIn()
        badge.setAmount(count: Settings.getBadgeP2PAmount())
    }
    
    func showChatWithMessage(id: Int) {
        showMessages(id)
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true) { 
            let appDel = UIApplication.shared.delegate as! AppDelegate
            if let bubble = appDel.bubbleContainerView {
                    bubble.showBubble()
            }
        }
    }
    
    @IBAction func showWebsite(_ sender: Any) {
//        let vc = storyboard?.instantiateViewController(withIdentifier: "ConferenceWebViewController") as! ConferenceWebViewController
//        vc.transitioningDelegate = vc
//        vc.navigationController?.navigationBar.barStyle = .black
//        self.present(vc, animated: true, completion: nil)
        
        guard let url = URL(string: Settings.getConferenceURL()!) else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func showSchedule(_ sender: Any) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let vc = storyboard?.instantiateViewController(withIdentifier: "MapScheduleSplitViewController") as! UISplitViewController
            let navVc = vc.viewControllers.first as! UINavigationController
            let scheduleVC = navVc.viewControllers.first as! ConferenceScheduleTableViewController
            let mapNavVc = vc.viewControllers.last as! UINavigationController
            let mapVc = mapNavVc.childViewControllers.first as! ConferenceMapViewController
            scheduleVC.delegate = mapVc
            vc.transitioningDelegate = scheduleVC
            self.present(vc, animated: true, completion: {
                if let eventId = sender as? String, let event = Event.getEventById(id: eventId) {
                    mapVc.selectEventFromCalender(event: event)
                    scheduleVC.selectEvent(event: event)
                }
            })
        } else {
            let vc = storyboard?.instantiateViewController(withIdentifier: "MapViewControllerNavigationController") as! UINavigationController
            let scheduleVc = vc.viewControllers.first as! ConferenceMapViewController
            vc.transitioningDelegate = scheduleVc
            scheduleVc.showContainerView = true
            self.present(vc, animated: true, completion: {
                if let eventId = sender as? String, let event = Event.getEventById(id: eventId) {
                    scheduleVc.selectEventFromCalender(event: event)
                }
            })
        }
    }
    
    
    @IBAction func showMessages(_ sender: Any) {

        if let profile = MemberProfile.getMyProfile() {
        
            //user is not a paid member
            if profile.canSearchDirectory == false {
                //show the sign up screen
                showUpgradeAlert()
                return
            }
        }
        
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ConferenceMessagesSplitVC") as! ConferenceMessageSplitViewController
        if let id = sender as? Int {
            
            guard vc.viewControllers.count > 0 else {
                return
            }
            
            if let messageNavController = vc.viewControllers[0] as? UINavigationController {
                guard messageNavController.childViewControllers.count > 0 else {
                    return
                }
                if let messagesViewController = messageNavController.childViewControllers[0] as? ConferenceMessagingViewController {
                    self.present(vc, animated: true, completion: {
                        messagesViewController.viewAppearFromPush(messageId: id)
                    })
                }
                
            }
        } else {
            let navVc = vc.viewControllers.first as! UINavigationController
            //vc.transitioningDelegate = navVc
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWebViewSegue" {
            let vc = segue.destination as! ConferenceWebViewController
            vc.transitioningDelegate = vc
        }
    }
    
    private func showUpgradeAlert() {
        
        let fcAlert = FCAlertView()
    
        fcAlert.hideDoneButton = false
        fcAlert.dismissOnOutsideTouch = true
        //self.view.addSubview(lert)
        
        fcAlert.doneBlock = {
            if !MFMailComposeViewController.canSendMail()
            {
                let alert = UIAlertView(title: NO_EMAIL_ACCOUNT_TITLE, message: NO_EMAIL_ACCOUNT_TEXT, delegate: nil, cancelButtonTitle: OK_TEXT)
                alert.show()
                return
            }
            let mailController = MFMailComposeViewController()
            mailController.setToRecipients([NSString(string: "member@int-bar.org") as String])
            mailController.setSubject(EMAIL_IBA_SUBJECT)
            mailController.mailComposeDelegate = self
            self.present(mailController, animated: true, completion: nil)
            
        }
        
        fcAlert.showAlert(inView: self, withTitle: "Upgrade Membership", withSubtitle: "In order to search and view messages, you will need to upgrade your IBA membership. Upgrade now or contact the IBA for more information", withCustomImage: UIImage(named: "image_placeholder"), withDoneButtonTitle: "Upgrade!", andButtons: nil)
        fcAlert.addButton("Cancel") {
            fcAlert.dismiss() //because the source has been modified to disable 'dismissOnOutsideTouch' !!
        }
    }
}

extension ConferenceMenuViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        bubblePresentAnimationController.dismissing = false
        bubblePresentAnimationController.viewTransforming = appDel.bubbleContainerView.bubbleView
        return bubblePresentAnimationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        bubblePresentAnimationController.dismissing = true
        bubblePresentAnimationController.viewTransforming = appDel.bubbleContainerView.bubbleView
        return bubblePresentAnimationController
    }
}

extension ConferenceMenuViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Mail cancelled")
        case MFMailComposeResult.saved.rawValue:
            print("Mail saved")
        case MFMailComposeResult.sent.rawValue:
            print("Mail sent")
        case MFMailComposeResult.failed.rawValue:
            print("Mail sent failure: %@", [error!.localizedDescription])
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
}
