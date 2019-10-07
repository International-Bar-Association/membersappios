//
//  CCMessageCollectionViewController.swift
//  IBA Members Directory
//
//  Created by George Smith on 25/07/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class CCMessageCollectionViewController: UIViewController,UIScrollViewDelegate {
    
    var collectionView: UICollectionView!
    var inputToolbar: JSQMessagesInputToolbar!
    var keyboardController: JSQMessagesKeyboardController!
    
    var senderDisplayName: String?
    var senderId: String?
    var shouldAutoCorrect: Bool = false
    var autoScrollToLatestMessage: Bool!
    var outgoingCellIdentifier: String!
    var incomingCellIdentifier: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func setupView() {
        
        let toolbar = Bundle.main.loadNibNamed("CCToolbar", owner: self, options: nil)![0] as! JSQMessagesInputToolbar
        inputToolbar = toolbar
        inputToolbar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(inputToolbar)
        self.setupToolbarConstraints()
        //NOTE: Add collectionview with top,left & right constraints
        let frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        collectionView = UICollectionView(frame: frame, collectionViewLayout: UICollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        self.setupCollectionViewConstraints()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.inputToolbar.delegate = self
        self.inputToolbar.contentView.textView.placeHolder = "New Message"
        self.inputToolbar.contentView.textView.delegate = self
        
        self.autoScrollToLatestMessage = true
        
        self.outgoingCellIdentifier = CCMessagesOutgoingCollectionViewCell.cellReuseIdentifier()
        self.incomingCellIdentifier = CCMessagesIncomingCollectionViewCell.cellReuseIdentifier()
        
        if self.inputToolbar.contentView.textView != nil {
            self.keyboardController = JSQMessagesKeyboardController(textView: self.inputToolbar.contentView.textView, contextView: self.view, panGestureRecognizer: self.collectionView.panGestureRecognizer, delegate: self as! JSQMessagesKeyboardControllerDelegate)
        }
    }
    
    func didPressSendButton(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        fatalError("didPressSendButton has not been implemented")
    }
    
    func didPressAccessoryButton(button: UIButton) {
        fatalError("didPressAccessoryButton has not been implemented")
    }
    
    func finishSendingMessage() {
        self.finishSendingMessageAnimated(animated: true)
    }
    
    func finishSendingMessageAnimated(animated: Bool) {
        let textView = self.inputToolbar.contentView.textView
        textView?.text = nil
        textView?.undoManager?.removeAllActions()
        self.inputToolbar.toggleSendButtonEnabled()
        
        NotificationCenter.default.post(name: NSNotification.Name.UITextViewTextDidChange, object: textView)
        //MARK: COULD BE ERRONEOUS
        self.collectionView.collectionViewLayout.invalidateLayout(with: JSQMessagesCollectionViewFlowLayoutInvalidationContext())
        collectionView?.reloadData()
        if autoScrollToLatestMessage {
            scrollToBottom(animated: animated)
        }
    }
    
    func finishReceivingMessage() {
     self.finishReceivingMessageAnimated(animated: true)
    }
    
    func finishReceivingMessageAnimated(animated: Bool) {
        self.collectionView.collectionViewLayout.invalidateLayout(with: JSQMessagesCollectionViewFlowLayoutInvalidationContext())
        collectionView?.reloadData()
        if autoScrollToLatestMessage {
            scrollToBottom(animated: animated)
        }
        
    }
    
    func scrollToBottom(animated: Bool) {
        guard self.collectionView.numberOfSections == 0 else {
            return
        }
        
        let indexPath = IndexPath(item: self.collectionView.numberOfItems(inSection: 0) - 1, section: 0)
        self.scrollToIndexPath(indexPath: indexPath, animated: animated)
    }
    
    func scrollToIndexPath(indexPath: IndexPath, animated: Bool) {
        guard self.collectionView.numberOfSections <= indexPath.section else {
            return
        }
        
        guard self.collectionView.numberOfItems(inSection: indexPath.section) > 0 else {
            return
        }
        
        guard let layout = self.collectionView.collectionViewLayout as? CCMessageCollectionViewFlowLayout  else {
            return
        }
        
        let cellSize = layout.sizeForItem(at: indexPath)
        let maxHeightForVisibleMessage = CGRect(x: 0, y: 0, width: 0, height: self.collectionView.bounds.height - self.collectionView.contentInset.top - self.collectionView.contentInset.bottom - self.inputToolbar.bounds.height).height
        let scrollPos = (cellSize.height > maxHeightForVisibleMessage) ? UICollectionViewScrollPosition.bottom : UICollectionViewScrollPosition.top
        self.collectionView.scrollToItem(at: indexPath, at: scrollPos, animated: animated)
        
    }
    
    func isOutgoingMessage(item: CCMessageData) -> Bool {
        guard let messageSenderId = item.senderId else {
            fatalError("messageSenderId cannot be nil!")
        }
        return messageSenderId() == self.senderId!
    }
    
    func didReceiveMenuWillShowNotification(notification: Notification) {
        
    }
    
    func didRecieveMenuWillHideNotification(notification: Notification) {
        
    }
}

extension CCMessageCollectionViewController {
    
    func setupToolbarConstraints() {
        let barLeftConstraint = NSLayoutConstraint(item: inputToolbar, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0)
        let barRightConstraint = NSLayoutConstraint(item: inputToolbar, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0)
        let barBottomConstraint = NSLayoutConstraint(item: inputToolbar, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        let barHeightConstraint = NSLayoutConstraint(item: inputToolbar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: inputToolbar.preferredDefaultHeight)
        inputToolbar.addConstraints([barHeightConstraint])
        self.view.addConstraints([barLeftConstraint,barRightConstraint,barBottomConstraint])
    }
    
    func setupCollectionViewConstraints() {
        let collectionLeftConstraint = NSLayoutConstraint(item: collectionView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0)
        let collectionRightConstraint = NSLayoutConstraint(item: collectionView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0)
        let collectionBottomConstraint = NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: self.inputToolbar, attribute: .top, multiplier: 1, constant: 0)
        let collectionTopConstraint = NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        let xConstraint = NSLayoutConstraint(item: collectionView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        self.view.addConstraints([collectionLeftConstraint,collectionRightConstraint,collectionBottomConstraint,collectionTopConstraint,xConstraint])
    }
}

extension CCMessageCollectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let ccCollectionView = collectionView as? CCMessagesCollectionView else {
            fatalError()
        }
        let datasource = ccCollectionView.dataSource as! CCMessagesCollectionViewDataSource
        let messageItem = datasource.collectionView!(collectionView: ccCollectionView, messageDataForItemAtIndexPath: indexPath)
        let isOutgoing = self.isOutgoingMessage(item: messageItem!)
        let cellIdentifier = isOutgoing ? self.outgoingCellIdentifier : self.incomingCellIdentifier
        
        let cell = ccCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier!, for: indexPath) as! CCMessagesCollectionViewCell
        cell.delegate = ccCollectionView as CCMessagesCollectionViewCellDelegate
        cell.cellTopLabel?.attributedText = datasource.collectionView!(collectionView: ccCollectionView, attributedTextForCellTopLabelAt: indexPath)
        cell.cellBottomLabel?.attributedText = datasource.collectionView!(collectionView: ccCollectionView, attributedTextForCellBottomLabelAt: indexPath)
        cell.textView?.text = messageItem?.text!()
        if isOutgoing {
            cell.messageBubbleTopLabel?.textInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 15.0)
        } else {
            cell.messageBubbleTopLabel?.textInsets = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 0.0)
        }
        
        cell.textView?.dataDetectorTypes = UIDataDetectorTypes.all
        cell.layer.rasterizationScale = UIScreen.main.scale
        cell.layer.shouldRasterize = true
        
        
        if let bubbleImageDataSource = ccCollectionView.messageDataSource?.collectionView!(collectionView: ccCollectionView, messageBubbleImageDataForItemAt: indexPath) {
            cell.messageBubbleImageView?.image = bubbleImageDataSource.messageBubbleImage()
            cell.messageBubbleImageView?.highlightedImage = bubbleImageDataSource.messageBubbleHighlightedImage()
        }
        
        return cell
        
    }
}

extension CCMessageCollectionViewController: UICollectionViewDelegate {

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }

    func collectionView(collectionView: CCMessagesCollectionView, didTapCellAt indexPath: IndexPath, touchLocation: CGPoint) {
        
    }
    
    func collectionView(collectionView: CCMessagesCollectionView, didTapMessageBubbleAt indexPath: IndexPath) {
        
    }
}

extension CCMessageCollectionViewController: JSQMessagesInputToolbarDelegate {
    func messagesInputToolbar(_ toolbar: JSQMessagesInputToolbar!, didPressLeftBarButton sender: UIButton!) {
        if toolbar.sendButtonOnRight {
            self.didPressAccessoryButton(button: sender)
        } else {
            self.didPressSendButton(sender, withMessageText: currentComposedMessageText(), senderId: self.senderId!, senderDisplayName: self.senderDisplayName!, date: Date())
        }
    }
    
    func messagesInputToolbar(_ toolbar: JSQMessagesInputToolbar!, didPressRightBarButton sender: UIButton!) {
        if toolbar.sendButtonOnRight {
            self.didPressSendButton(sender, withMessageText: currentComposedMessageText(), senderId: self.senderId!, senderDisplayName: self.senderDisplayName!, date: Date())
        } else {
            self.didPressAccessoryButton(button: sender)
        }
    }
    
    func currentComposedMessageText() -> String {
        if shouldAutoCorrect {
            self.inputToolbar.contentView.textView.inputDelegate?.selectionWillChange(self.inputToolbar.contentView.textView)
            self.inputToolbar.contentView.textView.inputDelegate?.selectionDidChange(self.inputToolbar.contentView.textView)
        }
        
        return self.inputToolbar.contentView.textView.text.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
    }
}

extension CCMessageCollectionViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView == self.inputToolbar.contentView.textView else {
            return
        }
        textView.becomeFirstResponder()
        if self.autoScrollToLatestMessage {
            self.scrollToBottom(animated: true)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView == self.inputToolbar.contentView.textView else {
            return
        }
        
        self.inputToolbar.toggleSendButtonEnabled()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView == self.inputToolbar.contentView.textView else {
            return
        }
        textView.resignFirstResponder()
    }
}

extension CCMessageCollectionViewController: JSQMessagesKeyboardControllerDelegate {
    func keyboardController(_ keyboardController: JSQMessagesKeyboardController!, keyboardDidChangeFrame keyboardFrame: CGRect) {
        
    }
}
