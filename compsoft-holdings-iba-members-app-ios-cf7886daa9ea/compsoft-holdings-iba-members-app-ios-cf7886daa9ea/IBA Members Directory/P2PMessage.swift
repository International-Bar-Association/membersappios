//
//  P2PMessage.swift
//  IBA Members Directory
//
//  Created by George Smith on 27/03/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class P2PMessageThread: SRKObject, MessageListProtocol {
    var lastSentMessageData: (text: String?, timeSent: Date?)? {
        get {
            if _lastSentMessageData != nil {
                return _lastSentMessageData
            } else {
                let lastMessageInThread = self.getLastMessage()
                if lastMessageInThread != nil {
                    let lastMessageData = (lastMessageInThread!.messageBody as String?,lastMessageInThread?.date())
                    _lastSentMessageData = lastMessageData
                    return lastMessageData
                }
                return nil
            }
            
        }
    }
    
    @objc dynamic var threadId: NSNumber!
    @objc dynamic var title : NSString!
    @objc dynamic var text : NSString!
    @objc dynamic var timeSent: Date!
    private var _lastSentMessageData: (text: String?,timeSent: Date?)!
    

    @objc dynamic var otherParticipantLastSeenTime: Date!
    @objc dynamic var imageURLString : NSString!
    @objc dynamic var imageData : Data!
    @objc dynamic var status : NSNumber!
    @objc dynamic var senderId: NSNumber!
    @objc dynamic var otherParticipantId: NSNumber!
    
    override class func ignoredProperties() -> [Any] {
        return ["_lastSentMessageData"]
    }
    
    var sender: MemberProfile? {
        get {
            var user = MemberProfile.getProfileForFavouriteMemberId(self.senderId)
            return user
        }
    }
   
    func hasBeenRemoved() -> Bool {
        guard self.id != nil else {
            return false
        }
        return !(P2PMessageThread.query().where(withFormat: "id = %@", withParameters: [self.id]).fetch().count > 0)
    }
    
    static func getById(threadId: NSNumber) -> P2PMessageThread? {
        let result = P2PMessageThread.query().where(withFormat: "threadId = %@", withParameters: [threadId]).fetch()
        if let threads = result as? [P2PMessageThread] {
            guard threads.count > 0 else {
                return nil
            }
            return threads[0]
        }
        return nil
    }
    
    var messageStatus: MessageStatus! {
        set {
            status = newValue.rawValue as NSNumber!
        }
        get {
            if status == nil {
                return MessageStatus(rawValue:1)
            }
            return MessageStatus(rawValue: Int(status.int32Value))
        }
    }
    
    func getMessages() -> [P2PMessage] {
        guard self.id != nil else {
            return []
        }
        var returnRes: [P2PMessage] = []
        var results =  P2PMessage.query().where(withFormat: "messageThread = %@", withParameters: [self.id]).order(by: "sentTime").fetch()
        for res in results! {
            returnRes.append(res as! P2PMessage)
        }
        return returnRes
    }
    
    func getLastMessage() -> P2PMessage? {
        var result = P2PMessage.query().where(withFormat: "messageThread = %@", withParameters: [self.id]).order(byDescending: "sentTime").limit(1).fetch().compactMap {$0 as? P2PMessage}
        return result.first
    }
    
    func setHasRead() {
        if let latestMessage = self.getMessages().last {
            
            Networking.setP2PMessageRead(id: latestMessage.messageId as! Int, success: {
                print("Message set to read")
                self.messageStatus = .read
                self.commit()
            }) { (error) in
                print("failed to set to read")
            }
        }
        
    }
    
    func getHasBeenRead() -> Bool {
        return self.messageStatus == MessageStatus.read
    }
    
    func deleteMessage() {
        self.messageStatus = .deleted
        Networking.hideP2PThread(id: threadId as! Int, success: { 
            
        }) { (error) in
            print(error)
        }
        self.remove()
    }
    
    override func entityWillInsert() -> Bool {
        print(self.timeSent)
        if P2PMessageThread.query().where(withFormat: "threadId = %@", withParameters: [self.threadId]).fetch().count > 0 {
            return false
        }
        
        return true
    }
    
    override func entityDidInsert() {
        print("DidInsert")
    }
    
    override func entityDidDelete() {
        for message in getMessages() {
            message.remove()
        }
    }
    
    override func entityDidUpdate() {
        print(self.timeSent)
    }
    
    class func CheckForEmptyThreadsAndRemoveThem() -> Bool {
        let threads = P2PMessageThread.query().fetch()
        var hasRemovedSoNeedsViewRefresh = false
        if (threads?.count)! > 0 {
            for var thread in threads! {
                if let t = thread as? P2PMessageThread {
                    if t.getMessages().count == 0 {
                        t.remove()
                        hasRemovedSoNeedsViewRefresh = true
                    }
                }
            }
        }
        return hasRemovedSoNeedsViewRefresh
    }
    
    static func getThreads() -> [P2PMessageThread] {
        return P2PMessageThread.query().fetch().compactMap{$0 as! P2PMessageThread}.sorted(by: { (threadA, threadB) -> Bool in
            guard threadA.lastSentMessageData != nil && threadB.lastSentMessageData != nil else {
                return false
            }
            return threadA.lastSentMessageData!.timeSent! > threadB.lastSentMessageData!.timeSent!
        })
    }
}

class P2PMessage: SRKObject,CCMessageData {
    @objc dynamic var messageId: NSNumber!
    @objc dynamic var messageThread: P2PMessageThread!
    @objc dynamic var sentTime: Date!
    @objc dynamic var readTime: Date!
    @objc dynamic var messageBody: NSString!
    @objc dynamic var sentByMe: NSNumber!
    @objc dynamic var _status: NSNumber! = 0
    var messageStatus: P2PMessageStatus! {
        get{
            if _status == nil {
                _status = 0
            }
            return P2PMessageStatus(rawValue: _status as! Int)
        } set{
            _status = newValue.rawValue as NSNumber
        }
    }
    
    override func entityWillInsert() -> Bool {
        let currentMessages = P2PMessage.query().where(withFormat: "messageId = %@", withParameters: [self.messageId])
        if currentMessages!.count() > 0 {
            return false
        } else {
            return true
        }
    }
    
    override func entityWillUpdate() -> Bool {
        return true
    }
    
    func senderId() -> String! {
        print(sentByMe)
        return sentByMe == 0 ? "\(messageThread.threadId)" : "1"
    }
    
    func senderDisplayName() -> String! {
        if let sender =  messageThread.sender {
            return sender.firstName + " " + sender.lastName
        } else {
            return ""
        }
        
    }
    
    func date() -> Date! {
        return sentTime
    }
    
    func isMediaMessage() -> Bool {
        return false
    }
    
    func messageHash() -> UInt {
        return UInt(bitPattern: Int(messageId))
    }
    
    func text() -> String! {
        return "\(messageBody!)"
    }
    
}

enum P2PMessageStatus:Int {
    case sent
    case pending
    case failed
    
    func getBottomLabelForState() -> NSAttributedString {
        switch self {
        case .sent:
            return NSAttributedString(string: "")
        case . pending:
            return NSAttributedString(string: "Sending...")
        case .failed:
            return NSAttributedString(string: "Failed. Tap to retry.",attributes:[NSAttributedStringKey.foregroundColor:UIColor.red])
        }
    }
}
