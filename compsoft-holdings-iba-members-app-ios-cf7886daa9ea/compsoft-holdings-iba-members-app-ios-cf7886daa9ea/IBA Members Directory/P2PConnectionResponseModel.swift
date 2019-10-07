//
//  P2PConnectionResponseModel.swift
//  IBA Members Directory
//
//  Created by George Smith on 27/03/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import Foundation
import ObjectMapper

class P2PConnectionResponseModel: Mappable {
    var userId: Int?
    var lastMessage: P2PMessageResponseModel?
    var userProfileImageUrl: String?
    var name: String?
    
    required init?(map: Map){
        
    }
    
    init(){
    }
    
    func mapping(map: Map) {
        userId <- map ["UserId"]
        lastMessage <- map["LastMessage"]
        userProfileImageUrl <- map["UserProfileImageUrl"]
        name <- map["Name"]
    }

}

class P2PMessageThreadResponseModel: Mappable {
    var threadId: Int?
    var messages: [P2PMessageResponseModel]?
    var recipientId: Int?
    var otherParticipantLastSeenDate: String?
    
    required init?(map: Map){
        
    }
    
    init(){
    }
    
    func mapping(map: Map) {
        threadId <- map ["ThreadId"]
        messages <- map ["Messages"]
        recipientId <- map["RecipientId"]
        otherParticipantLastSeenDate <- map["OtherParticipantLastSeenDateTime"]

    }
}

class SendP2PResponseModel: Mappable {
    var success: Bool?
    var message: P2PMessageResponseModel?
    
    required init?(map: Map){
        
    }
    
    init(){
    }
    
    func mapping(map: Map) {
        success <- map ["Success"]
        message <- map ["Message"]
    }

}

class P2PMessageResponseModel: Mappable {
    var messageId: Int?
    var message: String?
    var sentByMe: Bool?
    var sentTime: String?
    var deliveredTime: String?
    var readTime: String?
    
    required init?(map: Map){
        
    }
    
    init(){
    }
    
    func mapping(map: Map) {
        messageId <- map ["MessageId"]
        message <- map ["Message"]
        sentByMe <- map ["SentByMe"]
        sentTime <- map["SentTime"]
        deliveredTime <- map ["DeliveredTime"]
        readTime <- map["ReadTime"]
    }
}
