//
//  MessageListProtocol.swift
//  IBA Members Directory
//
//  Created by George Smith on 27/03/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import Foundation

protocol MessageListProtocol {
    var timeSent: Date! { get set }
    var title : NSString! { get set } // Title in p2p intance is name
    var text : NSString! { get set }
    var imageURLString : NSString! { get set }
    var imageData : Data! { get set }
    var status : NSNumber! { get set }
    
    var lastSentMessageData: (text: String?,timeSent: Date?)? { get }
    func setHasRead()
    func getHasBeenRead() -> Bool
    func deleteMessage()
}

extension MessageListProtocol {
    var lastSentMessageData: (text: String?,timeSent: Date?)? {
        get {
            return nil
        }
    }
}
