//
//  BubbleTestViewController.swift
//  IBA Members Directory
//
//  Created by George Smith on 09/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import UIKit

enum AnimationBubbleEntryType {
    case upIn
    case downIn
    case grow
}

protocol ConferenceBubbleDelegate {
    func didTapBubble()
    func openFromPush(id:Int)
}

class BadgeView: UILabel {
    
    private var growFrame: CGRect!
    private var tinyFrame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    private var count: Int = 0 {
        didSet {
            if oldValue == 0 && count > 0 {
                if self.frame == tinyFrame {
                    UIView.animate(withDuration: 0.3) {
                        self.frame = self.growFrame
                        self.layoutIfNeeded()
                    }
                }
            } else if count > 0 {
                self.frame = growFrame
            } else {
                self.frame = tinyFrame
            }
            self.text = "\(count)"
            
        }
    }

    override var frame: CGRect {
        didSet{
            if frame.width != 0 {
                growFrame = frame
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        tinyFrame = CGRect(x: frame.minX + (frame.width / 2), y: frame.minY + (frame.height / 2), width: 0, height: 0)
        self.backgroundColor = UIColor.red
        self.roundView()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.textColor = UIColor.white
        self.textAlignment = .center
        self.font = self.font.withSize(13)
        self.adjustsFontSizeToFitWidth = true
    }
    
    func setAmount(count: Int) {
        self.count = count
    }
}

class ConferenceBubbleContainingView: UIView, CAAnimationDelegate {
    
    var bubbleImageView: UIImageView!
    var bubbleView: UIView!
    var containerView: UIView!
    var bubbleRemoveImage: UIImage!
    var touchesEnabled: Bool = true
    var dragEnabled: Bool = true
    var canBeRemoved: Bool = true
    var startPos: CGPoint!
    var radius: CGFloat! = 5.00
    var animationType: AnimationBubbleEntryType = .grow
    var showAnim: CABasicAnimation!
    var maskPath: UIBezierPath!
    var maskLayer: CAShapeLayer!
    var webViewIsShown = false
    var showAnimationOnClose = true
    var shouldHideBubbleAfterNoInteractionTimer = true
    var noInterationTimeout = 1.50
    var timer = Timer()
    var growToRadius = CGFloat(0.0)
    var badge:BadgeView!
    
    var delegate: ConferenceBubbleDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.alpha = 0.0
    }
    
    override var alpha: CGFloat {
        didSet {
            debugPrint("ALPHA SET")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.alpha = 0.0
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func viewDidRotate(_ newFrame: CGRect) {
        self.frame = newFrame
        if self.alpha != 0 {
            checkBubbleIsInBounds()
        }
    }
    
    func hideBubble() {
        self.alpha = 0
    }
    
    func showBubble() {
        guard self.alpha != 1  else {
            return
        }
        guard let appDel = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        if appDel.conferenceMenuViewsOpen {
            return
        }
        self.bringSubview(toFront: self.bubbleView)
        self.alpha = 1
        self.badge.setAmount(count: Settings.getBadgeP2PAmount())
            
        animateEntry()

    }

    func checkBubbleIsInBounds() {
        
        let frame = bubbleImageView.convert(bubbleImageView.frame, to: self)
        if self.frame.contains(frame) {
            print("all good")
        } else {
            if window != nil {
                let startPos = CGPoint(x: window!.frame.size.width - 70, y: window!.frame.size.height - 70)
                bubbleView.center = CGPoint(x: startPos.x, y: startPos.y)
            }
            
        }
    }
    
    func setUpView(_ bubbleImage: UIImage,startPos: CGPoint, radius: Float,animationType: AnimationBubbleEntryType) {
        self.startPos = startPos
        self.radius = CGFloat(radius)
        bubbleImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.radius * 2, height: self.radius * 2))
        badge = BadgeView(frame: CGRect(x: (self.radius * 2) - 30, y: 5, width: 20, height: 20))
        badge.setAmount(count: 0)
        self.bubbleImageView.image = bubbleImage
        self.animationType = animationType
        self.backgroundColor = UIColor.clear
        addBubbleToViewWithImage()
        createBubbleFromImage()
        self.touchesEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadge), name: NSNotification.Name(rawValue: "P2PMessageReceived"), object: nil)

    }
    
    @objc func updateBadge() {
        self.badge.setAmount(count: Settings.getBadgeP2PAmount())
    }
    
    func createBubbleFromImage() {
        bubbleImageView.addSubview(badge)
        bubbleView.addSubview(bubbleImageView)
        
    }
    
    func addBubbleToViewWithImage() {
        let framePos = CGRect(x: startPos.x - radius, y: startPos.y - radius, width: radius * 2, height: radius * 2)
        bubbleView = UIView(frame: framePos)
        bubbleView.backgroundColor = UIColor.clear
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(moveBubble(_:)))
        bubbleView.addGestureRecognizer(panGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapBubble(_:)))
        bubbleView.addGestureRecognizer(tapGesture)
        self.addSubview(bubbleView)
        self.bringSubview(toFront: bubbleView)
    }
    
    @objc func moveBubble(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        sender.view?.center = CGPoint(x: bubbleView.center.x + translation.x, y: bubbleView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self)
    }
    
    @objc func tapBubble(_ sender: UITapGestureRecognizer) {
        delegate.didTapBubble()
    }
    
    func showConferenceOptionsView() {
        let portrait = self.frame.width > self.frame.height
        growToRadius = self.frame.height * 2
        if portrait {
            growToRadius = self.frame.width * 2
        }
        
        let growToRect = CGRect(x: self.frame.minX - self.frame.width / 2, y: self.frame.minY - self.frame.height / 2, width: growToRadius, height: growToRadius)
        maskPath = UIBezierPath(ovalIn: bubbleView.frame)
        let bigCirclePath = UIBezierPath(ovalIn: growToRect)
        let pathAnim = CABasicAnimation(keyPath: "path")
        pathAnim.delegate = self
        pathAnim.fromValue = maskPath.cgPath
        pathAnim.toValue = bigCirclePath
        pathAnim.duration = 0.2
        maskLayer.path = bigCirclePath.cgPath
        maskLayer.add(pathAnim, forKey: "pathAnimation")
        
        self.bringSubview(toFront: containerView)
    }
    

    func animateEntry() {
        switch animationType {
        case .grow:
             bubbleImageView.bounceIn()
            break
        default:
            break
        }
        
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: noInterationTimeout, target: self, selector: #selector(dimButton), userInfo: nil, repeats: false)
    }
    
    @objc  func dimButton() {
        UIView.animate(withDuration: 0.8, animations: {
            self.bubbleImageView.alpha = 0.2
        }) 
    }
    
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var inside = false
        let positionFrame = bubbleImageView.convert(bubbleImageView.frame, to: self)
        if positionFrame.contains(point) {
            inside = true
        } else {
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: noInterationTimeout, target: self, selector: #selector(dimButton), userInfo: nil, repeats: false)
        }
       
        self.bubbleImageView.alpha = 1
        
        return inside
    }
    
     }

