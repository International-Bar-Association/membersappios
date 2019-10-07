//
//  MessageResponseModel.swift
//  IBA Members Directory
//
//  Created by George Smith on 02/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import Foundation
import ObjectMapper

class MessageResponseModel: Mappable {
    var messages: [MessageDetailResponseModel]?
    var totalRecords: Int?
    
    required init?(map: Map){
        
    }
    
    init(){
    }
    
    func mapping(map: Map) {
        messages <- map ["Messages"]
        totalRecords <- map ["TotalRecords"]
    }
}

class MessageDetailResponseModel: Mappable {
    var appUserMessageId: Int?
    var messageType: Int?
    var title: String?
    var text: String?
    var url: String?
    var status: Int?
    var messageSent: String?
    
    required init?(map: Map){
        
    }
    
    init(){
    }
    
    func mapping(map: Map) {
        appUserMessageId <- map ["AppUserMessageId"]
        messageType <- map ["MessageType"]
        title <- map ["Title"]
        text <- map ["Text"]
        url <- map ["Url"]
        status <- map ["Status"]
        messageSent <- map["FormattedDate"]
    }
}
