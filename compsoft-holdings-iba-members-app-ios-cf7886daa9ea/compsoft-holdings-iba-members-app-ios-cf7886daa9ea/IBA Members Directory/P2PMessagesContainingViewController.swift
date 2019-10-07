//
//  P2PMessagesContainingViewController.swift
//  IBA Members Directory
//
//  Created by George Smith on 28/03/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import UIKit
import ARSLineProgress

protocol P2PMessageDelegate {
    func didStartSendMessage()
    func didStopSendMessage()
    func updateProgress()
    func reloadTopView()
    func gettingMessages()
    func stoppedGettingMessages()
}

protocol P2PMessageThreadDelegate {
    func reloadMessageThread()
}

class P2PMessagesContainingViewController: UIViewController {
    
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastSentTime: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var loadingMoreMessagesView: MessageSpinnerView!
    @IBOutlet weak var loadingMoreBottomConstraint: NSLayoutConstraint!
    
    var messageThread: P2PMessageThread!
    var messageThreadController: P2PMessageViewController!
    var timer: Timer?
    var messageListDelegate: MessageListDelegate!
    var originalFrame: CGRect!
    var isMessageListVisible: Bool!
    
    var hasInitialEmbed = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        let tapGestureRec = UITapGestureRecognizer(target: self, action: #selector(viewProfile(_:)))
        profileImage.addGestureRecognizer(tapGestureRec)
        
        if let navController = self.navigationController {
            navController.navigationBar.isTranslucent = false
            navController.navigationBar.barTintColor = Settings.getConferencePrimaryColour()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(recievedPushInBackground), name: NSNotification.Name(rawValue: "P2PMessageReceived"), object: nil)
    }
    

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupView() {
        progressView.progress = 0.0
        progressView.alpha = 0.0
        if messageThread != nil && !messageThread.hasBeenRemoved() {
            
            nameLabel.text = messageThread!.title as String
            if let time = messageThread.otherParticipantLastSeenTime {
                lastSentTime.text = "Last seen: \(time.toLocalTimeString(nil))"
            } else {
                lastSentTime.text = ""
            }
            
            if messageThread.imageData != nil {
                profileImage.image = UIImage(data: messageThread.imageData)
            } else {
                
                
                if let imgUrl = messageThread.imageURLString, let url = URL.cleaned(root: PROFILE_IMAGE_LOCATION, path: imgUrl as String) {
                
                    profileImage.downloadImageFrom(url: url, contentMode: .scaleAspectFit, completion: { (data) in
                        self.messageThread.imageData = data
                        self.messageThread.commit()
                    })
                }
            }
        } else {
            self.view.alpha = 0.0
        }
        
        
        if #available(iOS 11.0, *) {
            roundedView.clipsToBounds = true
            roundedView.layer.cornerRadius = 10
            roundedView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        }
        
        if messageThread.id != nil {
            deleteButton.isEnabled = true
        } else {
            deleteButton.isEnabled = false
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard splitViewController != nil else {
            return
        }
        if  splitViewController!.isCollapsed {
            P2PMessageThread.CheckForEmptyThreadsAndRemoveThem()
            self.messageListDelegate.reloadMessageList()
        }
    }
    
    func changeMessageThread(messageThread: P2PMessageThread) {
        messageThreadController.messageThread = messageThread
        messageThreadController.reloadCollection()
        nameLabel.text = messageThread.title as String
        if let time = messageThread.otherParticipantLastSeenTime {
            lastSentTime.text = "Last seen: \(time.toLocalTimeString(nil))"
        }
        else {
            lastSentTime.text = ""
        }
        guard messageThread.sender != nil else {
            return
        }
        if messageThread.imageData != nil {
            profileImage.image = UIImage(data: messageThread.imageData)
        } else {
            
            if let imgUrl = messageThread.imageURLString, let url = URL.cleaned(root: PROFILE_IMAGE_LOCATION, path: imgUrl as String) {
            
                    profileImage.downloadImageFrom(url: url, contentMode: .scaleAspectFit, completion: { (data) in
                        self.messageThread.imageData = data
                        self.messageThread.commit()
                    })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embed" {
            //Embedding JSQMessagingController
            print("embed")
            messageThreadController = segue.destination as! P2PMessageViewController
            messageThreadController.messageThread = messageThread
            messageThreadController.messageDelegate = self
            hasInitialEmbed = true
        }
    }
    
    func loadMessageViewController() {
        performSegue(withIdentifier: "embed", sender: nil)
    }
    
    @IBAction func viewProfile(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if self.view.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact {
            //Use storyboard intended for iPhone originally.
            let navController = storyboard.instantiateViewController(withIdentifier: "navPro-iPhone") as! UINavigationController
            let vc = navController.viewControllers[0] as! ProfileViewController
            
            if messageThread.sender != nil {
                vc.currentProfile = messageThread.sender!
            } else {
                let tempProfile = MemberProfile() // Causes profile view to download profile
                tempProfile.userId = messageThread.threadId
                vc.currentProfile = tempProfile
            }
            
            vc.shouldShowClose = true
            vc.profileDisplayType = .directoryProfile
            self.present(navController, animated: true, completion: nil)

        } else {
            
        
        let navController = storyboard.instantiateViewController(withIdentifier: "navPro") as! UINavigationController
        let vc = navController.viewControllers[0] as! ProfileViewController
        if messageThread.sender != nil {
            vc.currentProfile = messageThread.sender!
        } else {
            let tempProfile = MemberProfile() // Causes profile view to download profile
            tempProfile.userId = messageThread.threadId!
            vc.currentProfile = tempProfile
        }
        
        vc.shouldShowClose = true
        vc.profileDisplayType = .directoryProfile
        self.present(navController, animated: true, completion: nil)
        }
    }
    
    @IBAction func moveDown(_ sender: AnyObject) {
        moveMailDown(false)
    }
    
    func moveMailDown(_ delete: Bool) -> Bool {
        return messageListDelegate.moveDown()
    }
    
    @IBAction func moveUp(_ sender: AnyObject) {
        moveMailUp(false)
    }
    
    func moveMailUp(_ delete: Bool) {
        messageListDelegate.moveUp()
    }

    @IBAction func deleteMessage(_ sender: Any) {
        
        messageThread.deleteMessage()
        originalFrame = self.view.frame
        messageThreadController.messages.forEach { (message) in
            guard message.id != nil else {
                return
            }
            message.remove()
        }
        messageThreadController.reloadCollection()
        UIView.animate(withDuration: 0.15, animations: {
            self.view.alpha = 0.0
            self.view.frame = CGRect(x: 300, y: 0, width: 0, height: 0)
        }, completion: { (finsihed) in
            
            if self.isMessageListVisible! {
                //NOTE: Select next available message
                if !self.moveMailDown(true) {
                    //NOTE: No message to move to!
                    
                    
                }
                self.messageListDelegate.reloadMessageList()
            } else {
                self.parent?.navigationController?.popViewController(animated: true)
            }
        })
        
    }
    
    @objc func recievedPushInBackground() {
        messageThreadController.recievedPushInBackgroundOrAutoRefresh()
    }
    
}

extension P2PMessagesContainingViewController: P2PMessageDelegate {
    func stoppedGettingMessages() {
        UIView.animate(withDuration: 0.4) {
            self.loadingMoreBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        self.loadingMoreMessagesView.stopSpinning()
    }
    
    func didStartSendMessage() {
        progressView.alpha = 1.0
        progressView.progress = 0.5
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    func didStopSendMessage() {
        progressView?.progress = 0.0
        progressView.alpha = 0.0
        timer?.invalidate()
    }
    
    @objc func updateProgress() {
        progressView?.progress += 0.1
    }
    
    func gettingMessages() {
        
        UIView.animate(withDuration:0.4,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.3,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {
                        self.loadingMoreBottomConstraint.constant = 60
                        self.view.layoutIfNeeded()
        }, completion: nil)
        
        self.loadingMoreMessagesView.startSpinning()
    }

}

extension P2PMessagesContainingViewController: P2PMessageThreadDelegate {
    func reloadMessageThread() {
        setupView()
        self.containerView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        self.performSegue(withIdentifier: "embed", sender: self)
        
    }
    
    
    func reloadTopView() {
        
        if let time = messageThread.otherParticipantLastSeenTime {
            lastSentTime.text = "Last seen: \(time.toLocalTimeString(nil))"
        } else {
            lastSentTime.text = ""
        }
        
        if let data = messageThread.imageData {
            profileImage.image = UIImage(data: data)
        } else {
            guard let imgUrl = messageThread.imageURLString as String?  else {
                profileImage.image = #imageLiteral(resourceName: "icon_profile_image_placeholder_rome")
                return
            }
            if imgUrl == "N/A" {
                profileImage.image = #imageLiteral(resourceName: "icon_profile_image_placeholder_rome")
                return
            }
        
            profileImage.downloadImageFrom(link: imgUrl, contentMode: .scaleAspectFill, completion: { (data) in
                self.messageThread.imageData = data
            })
        }
        
        if let del = messageListDelegate {
            del.reloadMessageList()
        }
    }
}

