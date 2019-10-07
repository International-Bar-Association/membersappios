//
//  Message.swift
//  IBA Members Directory
//
//  Created by George Smith on 02/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import Foundation

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum MessageType : Int
{
    case standard = 0
    case renewal = 1
    case upgrade = 2
    case eventPass = 3
}

enum MessageStatus : Int
{
    case unread = 0
    case read = 1
    case deleted = 2
}


class Message:SRKObject, MessageListProtocol {
    

    @objc dynamic var appUserMessageId : NSNumber!
    @objc dynamic var type : NSNumber!
    @objc dynamic var title : NSString!
    @objc dynamic var text : NSString!
    @objc dynamic var url : NSString!
    @objc dynamic var status : NSNumber!
    @objc dynamic var timeSent: Date!
    @objc dynamic var imageURLString : NSString!
    @objc dynamic var imageData : Data!
    
    var messageType: MessageType! {
        set {
            type = newValue.rawValue as NSNumber?
        }
        get {
            return MessageType(rawValue: Int(type.int32Value))
        }
    }
    var messageStatus: MessageStatus! {
        set {
            status = newValue.rawValue as NSNumber?
        }
        get {
            return MessageStatus(rawValue: Int(status.int32Value))
        }
    }
    
    override func entityWillInsert() -> Bool {
        let existingMessage = Message.query().where(withFormat: "appuserMessageId =%@", withParameters: [self.appUserMessageId!]).fetch()
        if existingMessage?.count > 0 {
            let message = existingMessage?[0] as! Message
            message.status = self.status
            message.commit()
            return false
        }
        
        Networking.setMessageReceived(self.appUserMessageId as! Int, success: {
            print("Message set to received")
        }) { (error) in
            print("failed to set to received")
        }
        
        return true
    }
    
    func setHasRead() {
        Networking.setMessageRead(self.appUserMessageId as! Int, success: {
            print("Message set to read")
            self.messageStatus = .read
            self.commit()
        }) { (error) in
            print("failed to set to read")
        }
    }
    
    func getHasBeenRead() -> Bool {
        return self.messageStatus == MessageStatus.read
    }
    
    func deleteMessage() {
        self.messageStatus = .deleted
        Networking.setMessageDeleted(self.appUserMessageId as! Int, success: {
            print("Message set to delete")
        }) { (error) in
            print("failed to set to delete")
        }
        self.remove()
    }
    
    func hasUrl() -> Bool {
        if let str = self.url {
            let urlStr = str as String
            return !urlStr.isEmpty
        }
        return false
    }
    
    class func createMessagesFromMessageResponseModel(_ messageResponse: MessageResponseModel) {
        if messageResponse.messages != nil {
            for message in messageResponse.messages! {
                let newMessage = Message()
                newMessage.appUserMessageId = message.appUserMessageId! as NSNumber?
                newMessage.title = message.title! as NSString?
                newMessage.text = message.text! as NSString?
                newMessage.url = message.url! as NSString?
                newMessage.messageStatus = MessageStatus(rawValue: message.status!)
                newMessage.messageType = MessageType(rawValue: message.messageType!)
                newMessage.timeSent = message.messageSent?.stringToDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                print(newMessage.timeSent!)
                newMessage.commit()
            }
        }
    }
    
    class func createAndGetMessagesFromMessageResponseModel(_ messageResponse: MessageResponseModel) -> Message? {
        if messageResponse.messages?.count > 0 {
            let message = messageResponse.messages![0]
            
            let newMessage = Message()
            newMessage.appUserMessageId = message.appUserMessageId! as NSNumber?
            newMessage.title = message.title! as NSString?
            newMessage.text = message.text! as NSString?
            newMessage.url = message.url! as NSString?
            newMessage.messageStatus = MessageStatus(rawValue: message.status!)
            newMessage.messageType = MessageType(rawValue: message.messageType!)
            newMessage.timeSent = message.messageSent?.stringToDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            newMessage.commit()
            
            return newMessage
        }
        return nil
        
    }
    
}
