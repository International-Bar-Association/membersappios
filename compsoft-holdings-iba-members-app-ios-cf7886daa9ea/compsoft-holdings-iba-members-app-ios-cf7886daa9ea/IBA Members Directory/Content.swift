//
//  Content.swift
//  IBA Members Directory
//
//  Created by George Smith on 02/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import Foundation

enum ContentType : Int
{
    case article = 0
    case film = 1
    case podcast = 2
    
    func toString() -> String {
        switch self {
        case .article:
            return "Article"
        case .film:
            return "Video"
        case .podcast:
            return "Podcast"
        }
    }
    
    func getImageSrc() -> String {
        let imgSrc = "content_type_"
        switch self {
        case .article:
            return imgSrc + "article"
        case .film:
            return imgSrc + "film"
        case .podcast:
            return imgSrc + "podcast"
        }
    }
}


class Content: SRKObject {
    @objc dynamic var contentId: NSNumber!
    @objc dynamic var type: NSNumber!
    @objc dynamic var thumbnailURL: NSString!
    @objc dynamic var thumbnailData: Data!
    @objc dynamic var additionalData:Data!
    @objc dynamic var title: NSString!
    @objc dynamic var precis: NSString!
    @objc dynamic var url: NSString!
    @objc dynamic var featured: NSNumber!
    @objc dynamic var dateCreateString: NSString!
    @objc dynamic var dateCreated: Date!
    @objc dynamic var mimeType: NSString!
    
    var contentType: ContentType! {
        set {
            type = newValue.rawValue as NSNumber?
        }
        get {
            return ContentType(rawValue: Int(type.int32Value))
        }
    }
    
    func copyItemToNewContent() -> Content {
        let newContent = Content()
        newContent.contentId = self.contentId
        newContent.type = self.type
        newContent.thumbnailURL = self.thumbnailURL
        newContent.thumbnailData = self.thumbnailData
        newContent.additionalData = self.additionalData
        newContent.title = self.title
        newContent.precis = self.precis
        newContent.url = self.url
        newContent.featured = self.featured
        newContent.dateCreateString = self.dateCreateString
        newContent.dateCreated = self.dateCreated
        newContent.mimeType = self.mimeType
        return newContent
    }
    
    class func createContentFromContentLibraryResponseModel(_ library: ContentLibraryResponseModel) -> [Content] {
        var contentArr = [Content]()
        for content in library.items! {
            let newContent = Content()
            if let content = DataProvider.getContentForAlreadySavedContent(content.id!) {
                contentArr.append(content)
            } else {
                
                newContent.contentId = content.id as NSNumber?
                newContent.type = content.contentType as NSNumber?
                newContent.featured = content.featured as NSNumber?
                newContent.precis = content.precis as NSString?
                newContent.thumbnailURL = content.thumbnailUrl as NSString?
                newContent.url = content.url as NSString?
                newContent.dateCreateString = content.created as NSString?
                newContent.dateCreated = content.created?.stringToDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                newContent.title = content.title as NSString?
                contentArr.append(newContent)
            }
        }
        return contentArr
    }
}
