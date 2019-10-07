//
//  ConferenceEventResponseModel.swift
//  IBA Members Directory
//
//  Created by George Smith on 20/03/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import Foundation
import ObjectMapper

class ConferenceEventResponseModel: Mappable {
    
    var name: String?
    var venue: String?
    var start: String?
    var end: String?
    
    required init?(map: Map){
        
    }
    
    init(){
    }
    
    func mapping(map: Map) {
        name <- map ["Name"]
        venue <- map ["Venue"]
        start <- map ["Start"]
        end <- map ["End"]
    }
}

class ConferenceBuildingEventResponseModel: Mappable {
    
    var buildings: [BuildingResponseModel]!
    var events: [ConferenceEventItemsResponseModel]!
    required init?(map: Map){
        
    }
    
    init(){
    }
    
    func mapping(map: Map) {
        buildings <- map["Buildings"]
        events <- map["Events"]
    }
}

class BuildingResponseModel: Mappable {
    
    var id: Int!
    var name: String!
    var floors:[BuildingFloorResponseModel]!
    required init?(map: Map){
        
    }
    
    init() {
    }
    
    func mapping(map: Map) {
        id <- map["BuildingId"]
        name <- map["BuildingName"]
        floors <- map ["Floors"]
    }
}

class BuildingFloorResponseModel: Mappable {
    
    var name: String!
    var floorIndex: Int!
    
    required init?(map: Map){
        
    }
    
    init() {
    }
    
    func mapping(map: Map) {
        name <- map["Name"]
        floorIndex <- map ["FloorIndex"]
    }
}

class ConferenceEventItemsResponseModel: Mappable {
    
    var eventId: Int?
    var conferenceId: String?
    var startTime: String?
    var endTime: String?
    var roomId: Int?
    var title: String?
    var subtitle: String?
    var attending: Bool?
    var centreX: Int?
    var centreY: Int?
    var lat: Double?
    var long: Double?
    var roomName: String?
    var floor: Int?
    var buildingId: Int?
    
    required init?(map: Map){
        
    }
    
    init(){
    }
    
    func mapping(map: Map) {
        eventId <- map ["EventItemId"]
        conferenceId <- map ["ConferenceId"]
        startTime <- map ["StartTime"]
        endTime <- map ["EndTime"]
        roomId <- map["RoomId"]
        title <- map["Title"]
        subtitle <- map["Subtitle"]
        attending <- map["Attending"]
        roomName <- map["RoomName"]
        centreX <- map["RoomCentreX"]
        centreY <- map["RoomCentreY"]
        lat <- map["Lat"]
        long <- map["Long"]
        floor <- map["Floor"]
        buildingId <- map["BuildingId"]
    }
}
