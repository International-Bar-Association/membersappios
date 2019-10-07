//
//  ContentLibraryResponseModel.swift
//  IBA Members Directory
//
//  Created by George Smith on 02/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import Foundation
import ObjectMapper

class ContentLibraryResponseModel: Mappable {
    var items: [ContentResponseModel]?
    var totalRecords: Int?
    
    required init?(map: Map){
        
    }
    
    init(){
    }
    
    func mapping(map: Map) {
        items <- map ["Items"]
        totalRecords <- map ["TotalRecords"]
    }
}

class ContentResponseModel: Mappable {
    var id: Int?
    var thumbnailUrl: String?
    var title: String?
    var precis: String?
    var contentType: Int?
    var url: String?
    var featured: Bool?
    var created: String?
    
    required init?(map: Map){
        
    }
    
    init(){
    }
    
    func mapping( map: Map) {
        id <- map ["Id"]
        thumbnailUrl <- map ["ThumbnailUrl"]
        title <- map ["Title"]
        url <- map ["Url"]
        contentType <- map ["ContentType"]
        precis <- map ["Precis"]
        featured <- map ["Featured"]
        created <- map ["CreatedDate"]
    }
}
