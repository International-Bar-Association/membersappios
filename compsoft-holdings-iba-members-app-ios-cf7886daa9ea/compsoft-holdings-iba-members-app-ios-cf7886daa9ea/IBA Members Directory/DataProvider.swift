//
//  DataProvider.swift
//  IBA Members Directory
//
//  Created by George Smith on 02/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import Foundation

class DataProvider {
    class func getDownloadedContent() -> [Content] {
        let results = Content.query().fetch()
        var content = [Content]()
        for res in results! {
            content.append(res as! Content)
        }
        return content
    }
    
    class func getContentForAlreadySavedContent(_ id: Int) -> Content? {
        let result = Content.query().where(withFormat: "contentId=\(id)", withParameters: []).fetch()
        if let res = result?.firstObject {
            return res as? Content
        }
        
        return nil
    }
    
    class func getCmsMessages() -> [MessageListProtocol]? {
        let result = Message.query().order(byDescending: "timeSent").fetch()
        var messages = [MessageListProtocol]()
        for res in result! {
            if let message = res as? Message {
                messages.append(message)
            }
        }
        
        let messagesOrdered = messages.sorted { (a, b) -> Bool in
            if a.timeSent == nil {
                return true
            }
            if b.timeSent == nil {
                return false
            }
            return a.timeSent > b.timeSent
        }
        
        return messagesOrdered
        
    }
    
    class func getAllMessages() -> [MessageListProtocol]? {
        let result = Message.query().order(byDescending: "timeSent").fetch()
        var messages = [MessageListProtocol]()
        for res in result! {
            if let message = res as? Message {
                messages.append(message)
            }
        }
        
        let p2pResult = P2PMessageThread.query().order(byDescending: "timeSent").fetch()

        for res in p2pResult! {
            if let message = res as? P2PMessageThread {
                messages.append(message)
            }
        }
        
        let messagesOrdered = messages.sorted { (a, b) -> Bool in
            if a.timeSent == nil {
                return true
            }
            if b.timeSent == nil {
                return false
            }
            return a.timeSent > b.timeSent
        }
        
        return messagesOrdered
    }
    
    class func getMessageById(_ id: Int) -> Message? {
        return Message.query().where(withFormat: "appUserMessageId == \(id)", withParameters: nil).fetch().firstObject as? Message
    }
    
    class func getNumberOfUnreadMessages() -> Int {
        let unreadMessages = Message.query().where(withFormat: "status == 0", withParameters: nil).fetch()
        return unreadMessages!.count
    }
}
