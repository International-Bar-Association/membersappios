//
//  CCMessagesCollectionViewCell.swift
//  IBA Members Directory
//
//  Created by George Smith on 25/07/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class CCMessagesCollectionViewCell: UICollectionViewCell,UIGestureRecognizerDelegate {
    var delegate: CCMessagesCollectionViewCellDelegate?
    @IBOutlet var cellTopLabel: JSQMessagesLabel?
    @IBOutlet var messageBubbleTopLabel: JSQMessagesLabel?
    @IBOutlet var cellBottomLabel: JSQMessagesLabel?
    @IBOutlet var textView: UITextView?
    @IBOutlet var messageBubbleImageView: UIImageView?
    @IBOutlet var messageBubbleContainerView: UIView?
    @IBOutlet var avatarImageView: UIImageView?
    @IBOutlet var avatarContainerView: UIView?
    var mediaView: UIView?
    var tapGestureRecognizer: UITapGestureRecognizer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //setupCell()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell() {

        self.backgroundColor = UIColor.white
        self.cellTopLabel?.textAlignment = .center
        self.cellTopLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        self.cellTopLabel?.textColor = UIColor.lightGray
        
        self.messageBubbleTopLabel?.font = UIFont.systemFont(ofSize: 12)
        self.messageBubbleTopLabel?.textColor = UIColor.lightGray
        
        self.cellBottomLabel?.font = UIFont.systemFont(ofSize: 11)
        self.cellBottomLabel?.textColor = UIColor.lightGray
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(tap:)))
        self.addGestureRecognizer(tap)
        self.tapGestureRecognizer = tap
        
    }

    deinit {
        delegate = nil
        
        cellTopLabel = nil
        messageBubbleTopLabel = nil
        cellBottomLabel = nil
        textView = nil
        messageBubbleContainerView = nil
        
        tapGestureRecognizer?.removeTarget(nil, action: nil)
        tapGestureRecognizer = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellTopLabel?.text = nil
        self.messageBubbleTopLabel?.text = nil
        self.cellBottomLabel?.text = nil
        
        self.textView?.dataDetectorTypes = UIDataDetectorTypes.all
        self.textView?.text = nil
        self.textView?.attributedText = nil
    }
    
    @objc func handleTap(tap: UITapGestureRecognizer) {
        let touchPoint = tap.location(in: self)
        if self.messageBubbleContainerView!.frame.contains(touchPoint) {
            self.delegate?.messagesCollectionViewCellDidTapMessageBubble(self)
        } else {
            self.delegate?.messagesCollectionViewCellDidTap(self, atPosition: touchPoint)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: self)
        if gestureRecognizer is UILongPressGestureRecognizer {
            return self.messageBubbleContainerView!.frame.contains(point)
        }
        
        return false
    }
    
    func setBackgroundColour(colour: UIColor) {
        self.backgroundColor = colour
        self.cellTopLabel?.backgroundColor = colour
        self.messageBubbleTopLabel?.backgroundColor = colour
        self.cellBottomLabel?.backgroundColor = colour
        
        self.messageBubbleImageView?.backgroundColor = backgroundColor
        
        self.messageBubbleContainerView?.backgroundColor = backgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func cellReuseIdentifier() -> String {
        preconditionFailure("This method must be overridden")
    }
    
    class func mediaCellReuseIdentifier() -> String {
        preconditionFailure("This method must be overridden") 
    }
    
    class func registerMenuAction(_ action: Selector) {
    }
}
