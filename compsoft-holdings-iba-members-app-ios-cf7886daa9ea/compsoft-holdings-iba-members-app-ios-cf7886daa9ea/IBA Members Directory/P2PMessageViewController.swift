//
//  P2PMessageViewController.swift
//  IBA Members Directory
//
//  Created by George Smith on 27/03/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class P2PMessageViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var inputToolbar: JSQMessagesInputToolbar!
    var keyboardController: JSQMessagesKeyboardController!
    
    var senderDisplayName: String?
    var senderId: String?
    var shouldAutoCorrect: Bool = false
    var autoScrollToLatestMessage: Bool!
    var outgoingCellIdentifier: String!
    var incomingCellIdentifier: String!
    
    @IBOutlet weak var toolbarHeightConstraint: NSLayoutConstraint!
    
    var messageThread: P2PMessageThread!
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    var messages: [P2PMessage]! {
        didSet {
            if messages.count > 0 {
                self.tableView.tableFooterView?.backgroundColor = UIColor.white
            } else {
                self.tableView.tableFooterView?.backgroundColor = UIColor.clear
            }
        }
    }
    var hasMoreMessagesToReceive = true
    var isGettingMessages = false
    var messageDelegate: P2PMessageDelegate!
    var refreshTimer: Timer!
    let refreshIntervalSeconds = 500.0
    let pageLimit = 10
    
    fileprivate var cellHeights: [IndexPath: CGFloat?] = [:]
    
    var minimumToolbarHeightConstraint:CGFloat = 44.0
    var maximumToolbarHeightConstraint:CGFloat = 122.0
    
    @IBOutlet var toolbarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableviewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messages = []
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.senderId = "1"
        self.senderDisplayName = "Placeholder"
        setupView()
        setUpToolbar()
        messages = messageThread.getMessages()
        self.tableView.reloadData()
        scrollToBottom(animated: false)
        
        getMessages()
    }
    
    func recievedPushInBackgroundOrAutoRefresh() {
        getMessages()
    }
    
    func getMessages() {
        
        Networking.getP2PMessages(id: messageThread.threadId as! Int, skip: 0, take: pageLimit, success: { (messages) in
            for message in messages.messages! {
                
                let latestMessage = P2PMessage()
                latestMessage.messageBody = message.message as NSString?
                latestMessage.messageId = message.messageId as NSNumber?
                latestMessage.messageThread = self.messageThread
                latestMessage.sentByMe = message.sentByMe as NSNumber?
                
                
                if let sentTime = message.sentTime {
                    latestMessage.sentTime = sentTime.stringToDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                    if latestMessage.sentByMe == 0 {
                        latestMessage.messageThread.messageStatus = .unread
                    } else {
                        latestMessage.messageThread.messageStatus = .read
                    }
                    
                    //latestMessage.messageThread.timeSent = latestMessage.sentTime!
                }
                if let readTime = message.readTime {
                    latestMessage.readTime = readTime.stringToDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                }
                latestMessage.commit()
            }
            self.messageThread.otherParticipantId = messages.recipientId as NSNumber?
            if let lastSeenTime = messages.otherParticipantLastSeenDate {
                self.messageThread.otherParticipantLastSeenTime = lastSeenTime.stringToDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            }
            
            self.messageThread.commit()
            self.messageThread.setHasRead()
            self.messageDelegate.reloadTopView()
            self.reloadCollection()

            
        }, failure: { (error) in
            print(error)
            self.messageDelegate.stoppedGettingMessages()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.keyboardController.beginListeningForKeyboard()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshIntervalSeconds, repeats: true, block: { (timer) in
            self.recievedPushInBackgroundOrAutoRefresh()
        })
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        //self.messageDelegate = nil
        //self.collectionView.delegate = nil
        refreshTimer.invalidate()
    }
    
    func setupView() {
        self.inputToolbar.delegate = self
        self.inputToolbar.contentView.textView.placeHolder = "New Message"
        self.inputToolbar.contentView.textView.delegate = self
        self.inputToolbar.backgroundColor = UIColor.white
        self.autoScrollToLatestMessage = true
        

        if self.inputToolbar.contentView.textView != nil {
            self.keyboardController = JSQMessagesKeyboardController(textView: self.inputToolbar.contentView.textView, contextView: self.view, panGestureRecognizer: self.tableView.panGestureRecognizer, delegate: self as JSQMessagesKeyboardControllerDelegate)
        }
        
        
        
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 24))
        
        if messages.count > 0 {
            view.backgroundColor = UIColor.white
        } else {
            view.backgroundColor = UIColor.clear
        }
        
        if #available(iOS 11.0, *) {
            view.clipsToBounds = true
            view.layer.cornerRadius = 10
            view.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMinXMaxYCorner]
        }
        tableView.tableFooterView = view
    }
    
    func finishSendingMessage() {
        self.finishSendingMessageAnimated(animated: true)
    }
    
    func reloadCollection(scrollToBottom: Bool = true) {
        guard messageThread != nil else {
            return
        }
        messages = messageThread.getMessages()

        self.finishReceivingMessageAnimated(animated: false,shouldScrollToBottom: scrollToBottom)
    }
    
    func setUpToolbar() {
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.inputToolbar.contentView.backgroundColor = UIColor.white
        self.inputToolbar.contentView.rightBarButtonItem.backgroundColor = Settings.getConferenceSecondaryColour()
        self.inputToolbar.contentView.rightBarButtonItemWidth = 80
        self.inputToolbar.contentView.rightBarButtonItem.layer.cornerRadius = 5
        self.inputToolbar.contentView.rightBarButtonItem.setTitleColor(UIColor.white, for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.layer.borderWidth = 1
        self.inputToolbar.contentView.rightBarButtonItem.layer.borderColor =  Settings.getConferenceSecondaryColour().cgColor
        self.inputToolbar.contentView.rightBarButtonItem.setBackgroundImage(UIImage.init(color: UIColor(displayP3Red: 231, green: 57, blue: 47, alpha: 0.3)), for: UIControlState.disabled)
     
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !keyboardController.keyboardIsVisible else {
            return
        }
        let scrollViewHeight = scrollView.frame.size.height;
        let scrollContentSizeHeight = scrollView.contentSize.height;
        let scrollOffset = scrollView.contentOffset.y;
        guard hasMoreMessagesToReceive && !isGettingMessages else {
            return
        }
        if (scrollOffset < 10 )
        {
            isGettingMessages = true
            // then we are at the top
            messageDelegate.gettingMessages()
            Networking.getP2PMessages(id: messageThread.threadId as! Int, skip: messages.count, take: pageLimit, success: { (messages) in
                self.isGettingMessages = false
                if (messages.messages?.count)! < self.pageLimit {
                    self.hasMoreMessagesToReceive = false
                    
                }
                for message in messages.messages! {
                    
                    let latestMessage = P2PMessage()
                    latestMessage.messageBody = message.message as NSString?
                    latestMessage.messageId = message.messageId as NSNumber?
                    latestMessage.messageThread = self.messageThread
                    latestMessage.sentByMe = message.sentByMe as NSNumber?
                    
                    if let sentTime = message.sentTime {
                        latestMessage.sentTime = sentTime.stringToDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                        if latestMessage.sentByMe == 1 {
                            latestMessage.messageThread.messageStatus = .unread
                        } else {
                            latestMessage.messageThread.messageStatus = .read
                        }
                        //latestMessage.messageThread.timeSent = latestMessage.sentTime!
                    }
                    if let readTime = message.readTime {
                        latestMessage.readTime = readTime.stringToDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                    }
                    latestMessage.commit()
                }
                if let lastSeenTime = messages.otherParticipantLastSeenDate {
                    self.messageThread.otherParticipantLastSeenTime = lastSeenTime.stringToDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                }
                self.messageThread.commit()
                self.reloadCollection(scrollToBottom: false)
                self.messageDelegate.reloadTopView()
                self.messageDelegate.stoppedGettingMessages()
                
            }, failure: { (error) in
                self.isGettingMessages = false
                self.messageDelegate.stoppedGettingMessages()
                print(error)
            })
            
        }
        else if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
        {
            // then we are at the end
        }
    }
    
    
    func didPressSendButton(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        //Add temp message with sending status.
        self.messageThread.commit() //Make sure the thread exists
        let messageToSend = P2PMessage()
        messageToSend.sentTime = Date()
        messageToSend.messageId = Int.max as NSNumber?
        messageToSend.messageBody = text as NSString?
        messageToSend.messageThread = self.messageThread
        messageToSend.sentByMe = true
        messageToSend.messageStatus = P2PMessageStatus.pending
        messages.append(messageToSend)
        
        if let textView = self.inputToolbar.contentView.textView {
            textView.text = nil
            textView.undoManager?.removeAllActions()
        }
        
        
        tableView?.reloadData()
        scrollToBottom(animated: true)
        sendMessage(text: text,messageToSend: messageToSend)
        
    }
    
    func sendMessage(text: String, messageToSend: P2PMessage) {
        messageDelegate.didStartSendMessage()
        Networking.sendP2PMessages(id: messageThread.threadId as! Int,message: text, success: { (response) in
            if response.success! {
                self.messageDelegate.didStopSendMessage()
                messageToSend.messageBody = response.message!.message as NSString?
                messageToSend.messageId = response.message!.messageId as NSNumber?
                
                if let sentTime = response.message!.sentTime {
                    messageToSend.sentTime = sentTime.stringToDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                    messageToSend.messageThread.messageStatus = .read
                    messageToSend.messageThread.timeSent = messageToSend.sentTime!
                }
                if let readTime = response.message!.readTime {
                    messageToSend.readTime = readTime.stringToDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                }
                messageToSend.messageStatus = P2PMessageStatus.sent
                messageToSend.commit()
                self.tableView.reloadData()
                self.finishSendingMessage()
                
                
            } else {
                //set failure on message
                messageToSend.messageStatus = P2PMessageStatus.failed
                self.messageDelegate.didStopSendMessage()
                self.finishReceivingMessage()
            }
        }) { (error) in
            //Set failure on message type
            messageToSend.messageStatus = P2PMessageStatus.failed
            self.messageDelegate.didStopSendMessage()
            self.finishReceivingMessage()
        }
        
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: Settings.getConferencePrimaryColour())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.00))
    }
}

extension P2PMessageViewController {
    
    func finishSendingMessageAnimated(animated: Bool) {
        let textView = self.inputToolbar.contentView.textView
        textView?.text = nil
        textView?.undoManager?.removeAllActions()
        self.inputToolbar.toggleSendButtonEnabled()
        growShrinkToolbar()
        
        NotificationCenter.default.post(name: NSNotification.Name.UITextViewTextDidChange, object: textView)
        if autoScrollToLatestMessage {
            scrollToBottom(animated: animated)
        }
    }
    
    func finishReceivingMessage(shouldScrollToBottom: Bool = true) {
        self.finishReceivingMessageAnimated(animated: true,shouldScrollToBottom: shouldScrollToBottom)
    }
    
    func finishReceivingMessageAnimated(animated: Bool, shouldScrollToBottom: Bool = true) {
        tableView?.reloadData()
        if shouldScrollToBottom {
            scrollToBottom(animated: animated)
        }
        
    }
    
    func scrollToBottom(animated: Bool) {
        guard self.tableView.numberOfSections > 0 else {
            return
        }
        
        let indexPath = IndexPath(item: self.tableView.numberOfRows(inSection: 0) - 1, section: 0)
        self.scrollToIndexPath(indexPath: indexPath, animated: animated)
    }
    
    func scrollToIndexPath(indexPath: IndexPath, animated: Bool) {
        guard indexPath.section < self.tableView.numberOfSections   else {
            return
        }
        
        guard self.tableView.numberOfRows(inSection: indexPath.section) > 0 else {
            return
        }
        
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
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
    
    func messageForBottomLabelAtIndexPath(indexPath: IndexPath) -> NSAttributedString? {
        let message = messages[indexPath.item]
        
        if message.messageStatus != P2PMessageStatus.sent {
            return message.messageStatus.getBottomLabelForState()
        } else {
            return nil
        }
    }
    
    func messageForTopLabelAtIndexPath(indexPath: IndexPath) -> NSAttributedString? {
        let message = messages[indexPath.item];
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sentTime.toShortDayString() == message.sentTime.toShortDayString() {
                return nil;
            }
        }
        
        return  JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.sentTime)
    }
}

extension P2PMessageViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count > 0 ? messages.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if messages.count > 0 {

            let message = messages[indexPath.row]
            let isOutgoing = isOutgoingMessage(item: message)
            let cell = tableView.dequeueReusableCell(withIdentifier: CCMessageTableViewCell.reuseIdentifier(outgoing: isOutgoing), for: indexPath) as! CCMessageTableViewCell
            
            cell.textView?.text = message.text()
            cell.bubbleImageView?.image = isOutgoing ? outgoingBubbleImageView.messageBubbleImage : incomingBubbleImageView.messageBubbleImage
            cell.bubbleTopLabel.attributedText = messageForTopLabelAtIndexPath(indexPath: indexPath)
            cell.cellBottomLabel.attributedText = messageForBottomLabelAtIndexPath(indexPath: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoMessagesTableViewCell")
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.height
    }
    
}

extension P2PMessageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = cellHeights[indexPath] {
            return height ?? UITableViewAutomaticDimension
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < messages.count else {
            return
        }
        let message = messages[indexPath.row]
        
        if message.messageStatus == P2PMessageStatus.failed {
            message.messageStatus = P2PMessageStatus.pending
            sendMessage(text: message.messageBody as String, messageToSend: message)
        }
        tableView.reloadData()
    }
}


extension P2PMessageViewController: JSQMessagesInputToolbarDelegate {
    func messagesInputToolbar(_ toolbar: JSQMessagesInputToolbar!, didPressLeftBarButton sender: UIButton!) {
        if toolbar.sendButtonOnRight {
            //self.didPressAccessoryButton(button: sender)
        } else {
            self.didPressSendButton(sender, withMessageText: currentComposedMessageText(), senderId: self.senderId!, senderDisplayName: self.senderDisplayName!, date: Date())
        }
    }
    
    func messagesInputToolbar(_ toolbar: JSQMessagesInputToolbar!, didPressRightBarButton sender: UIButton!) {
        if toolbar.sendButtonOnRight {
            self.didPressSendButton(sender, withMessageText: currentComposedMessageText(), senderId: self.senderId!, senderDisplayName: self.senderDisplayName!, date: Date())
        } else {
            //self.didPressAccessoryButton(button: sender)
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

extension P2PMessageViewController: UITextViewDelegate {
    
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
        growShrinkToolbar()
        self.inputToolbar.toggleSendButtonEnabled()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView == self.inputToolbar.contentView.textView else {
            return
        }
        textView.resignFirstResponder()
    }
    
    func growShrinkToolbar() {
        let numberOfLines:Int = Int(self.inputToolbar.contentView.textView.contentSize.height / (self.inputToolbar.contentView.textView.font?.lineHeight)!)
        
        let height = CGFloat(numberOfLines) * minimumToolbarHeightConstraint
        if height != toolbarHeightConstraint.constant {
            self.inputToolbar.contentView.textView.isScrollEnabled = false
            self.inputToolbar.contentView.textView.becomeFirstResponder()
            if height < maximumToolbarHeightConstraint {
                toolbarHeightConstraint.constant = height
                tableviewBottomConstraint.constant = height
                
            } else {
                toolbarHeightConstraint.constant = maximumToolbarHeightConstraint
                tableviewBottomConstraint.constant = maximumToolbarHeightConstraint
            }
            
            if self.inputToolbar.contentView.textView.text.isEmpty == false && numberOfLines < 3{
                self.inputToolbar.contentView.textView.scrollRangeToVisible(NSMakeRange(0, 1))
            }
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.inputToolbar.contentView.textView.isScrollEnabled = true
        }
    }
}

extension P2PMessageViewController: JSQMessagesKeyboardControllerDelegate {
    
    func keyboardController(_ keyboardController: JSQMessagesKeyboardController!, keyboardDidChangeFrame keyboardFrame: CGRect) {
        if (!self.inputToolbar.contentView.textView.isFirstResponder && self.toolbarBottomConstraint.constant == 0.0) {
            return;
        }
        let viewBottom = self.view.frame.maxY
        let keyboardTop = keyboardFrame.maxY - keyboardFrame.height
        print("vb \(viewBottom)")
        print("kt \(keyboardTop)")
        var  heightFromBottom = (viewBottom - keyboardTop)
        heightFromBottom = CGFloat.maximum(0.0, heightFromBottom)
        toolbarBottomConstraint.constant = heightFromBottom
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: heightFromBottom + 20, right: 0)
    }
}

