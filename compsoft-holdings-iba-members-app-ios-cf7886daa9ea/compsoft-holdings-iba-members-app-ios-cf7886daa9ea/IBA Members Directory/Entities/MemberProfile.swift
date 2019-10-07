//
//  Member.swift
//  IBA Members Directory
//
//  Created by Louisa Mousley on 14/05/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import Foundation
import UIKit
 
enum MemberType : Int
{
    case memberTypeNone = 0
    case memberTypeFavourite = 1
    case memberTypeMe = 2
}


class MemberProfile: SRKObject {
    
    @objc dynamic var userId : NSNumber! //from server
    @objc dynamic var firstName : String!
    @objc dynamic var lastName : String!
    @objc dynamic var jobPosition : String!
    @objc dynamic var firmName : String!
    @objc dynamic var profileClass: NSNumber!
    @objc dynamic var canSearchDirectory: NSNumber!

    @objc dynamic var addressLines : String!
    @objc dynamic var addressCity : String!
    @objc dynamic var addressCountry : String!
    @objc dynamic var addressCounty : String!
    @objc dynamic var addressPcZip : String!
    @objc dynamic var addressState : String!

    @objc dynamic var biography : String!
    @objc dynamic var emailAddress : String!
    @objc dynamic var phoneNumber : String?
    @objc dynamic var committess : NSArray!
    @objc dynamic var areasOfPractice : NSArray!
    @objc dynamic var memberType : NSNumber!
    @objc dynamic var isPublic: NSNumber?
    @objc dynamic var shouldSeeConfBubble: NSNumber?
    @objc dynamic var currentConference: NSNumber?

    @objc dynamic var imageURLString : NSString?
    @objc dynamic var imageData : NSData?
    
    func canViewProfile() -> Bool {
        if self.profileClass == 1 || self.profileClass == 4 || self.profileClass == 13 || self.profileClass == 27 {
            return true
        } else {
            return false
        }
    }
    
    class func getAllFavoritedProfiles() -> [MemberProfile]
    {
        let results : SRKResultSet = MemberProfile.query().where(withFormat: "memberType = %@", withParameters: NSArray(object: MemberType.memberTypeFavourite.rawValue) as [AnyObject]).order(by: "lastName").fetch()
        
        var memberArray = [MemberProfile]()
        for result in results   {
            let member = result as! MemberProfile
            memberArray.append(member)
        }
        return memberArray
    }
    
    class func getMyProfile() -> MemberProfile?
    {
        if let myProfile =  MemberProfile.query().where(withFormat: "memberType = %@", withParameters: [MemberType.memberTypeMe.rawValue]).fetch().firstObject as! MemberProfile?
        {
            return myProfile
        }
        return nil
    }
    
    class func getProfileForAttendee(attendee: Attendee) -> MemberProfile? {
        if let profile =  MemberProfile.query().where(withFormat: "userId = %@", withParameters: [attendee.attendeeId]).fetch().firstObject as! MemberProfile?
        {
            return profile
        }
        return nil
    }
    
    class func shouldShowConfBubble() -> Bool? {
        if let me = getMyProfile(), let shouldSeeConf = me.shouldSeeConfBubble {
            return Bool(shouldSeeConf)
        } else
        {
            return false
        }
    }
    
    class func getProfileForFavouriteMemberId(_ memberId:NSNumber) -> MemberProfile?
    {
        if let memberProfile =  MemberProfile.query().where(withFormat: "userId = %@", withParameters: NSArray(object: memberId) as [AnyObject]).fetch().firstObject as! MemberProfile?
        {
            return memberProfile
        }
        return nil
    }
    
    override func entityWillInsert() -> Bool {
        return true
    }
    
    override func entityDidUpdate() {
        
    }
    
    class func createMemberFromDictionary(_ memberId: Int?, memberDictionary : NSDictionary, isMine:Bool) -> MemberProfile
    {
        //if in db then is favourite so update record in db - else don't commit
        var userId : Int!
        if memberId != nil
        {
            userId = memberId
        }
        else
        {
            userId = memberDictionary.object(forKey: "UserId") as? Int
        }
        var memberProfile : MemberProfile!
        if isMine
        {
            memberProfile = MemberProfile.getMyProfile()
        }
        else
        {
            memberProfile = MemberProfile.getProfileForFavouriteMemberId(userId as NSNumber)
            
        }
        if memberProfile == nil
        {
            memberProfile = MemberProfile()
            memberProfile!.userId = userId as NSNumber
            if isMine
            {
                memberProfile.memberType = MemberType.memberTypeMe.rawValue as NSNumber
            }
            else
            {
                //if isn't mine and dont have then not a favourite
                memberProfile.memberType = MemberType.memberTypeNone.rawValue as NSNumber
                memberProfile.shouldSeeConfBubble = false
            }
        }
        
        memberProfile!.firstName = memberDictionary.object(forKey: "FirstName") as? String
        memberProfile!.lastName = memberDictionary.object(forKey: "LastName") as? String
        if let accessDict = memberDictionary.object(forKey: "Access") as? NSDictionary {
            if let canSearch = accessDict.object(forKey: "CanSearchDirectory") as? Bool {
                memberProfile!.canSearchDirectory = canSearch as NSNumber
            }
            if let pClass = accessDict.object(forKey: "Class") as? NSNumber {
                memberProfile!.profileClass = pClass
            }
        }
        
        
        memberProfile!.firmName = memberDictionary.object(forKey: "FirmName") as? String
        memberProfile!.jobPosition = memberDictionary.object(forKey: "JobPosition") as? String
        memberProfile!.biography = memberDictionary.object(forKey: "Biography") as? String
        memberProfile!.emailAddress = memberDictionary.object(forKey: "Email") as? String
        memberProfile!.phoneNumber = memberDictionary.object(forKey: "Phone") as? String
        
        if let photoUrl = memberDictionary.object(forKey: "ProfilePicture") as? String
        {
            if photoUrl != "http://www.int-bar.org/Officers/Images/"
            {
                if let currentStr = memberProfile.imageURLString as String? {
                    if photoUrl != currentStr {
                        memberProfile.imageData = nil
                    }
                }
                
                memberProfile!.imageURLString = photoUrl as NSString
            }
        }
        
        if let addressDict = memberDictionary.object(forKey: "Address") as? NSDictionary
        {
            memberProfile!.addAddressFromDictionary(addressDict)
        }
        
        if memberDictionary.object(forKey: "AreasOfPractice") != nil {
            memberProfile!.areasOfPractice = (memberDictionary.object(forKey: "AreasOfPractice") as? NSArray)!
        }
        
        if let commitees = memberDictionary.object(forKey: "Committees") as? NSArray {
            memberProfile!.committess = commitees
        }
        
        if let isPublic = memberDictionary.object(forKey: "Public") as? NSNumber
        {
            memberProfile.isPublic = isPublic
        }
        
        if let conferenceId = memberDictionary.object(forKey: "CurrentlyAttendingConference") as? NSNumber {
            if conferenceId == 673 {
                //BUILD SPECIFIC CONFERENCE ID
                memberProfile!.currentConference = conferenceId
            }
        }
         memberProfile!.shouldSeeConfBubble = false
        //if is my profile or a favourite then commit to db
        if memberProfile!.memberType != MemberType.memberTypeNone.rawValue as NSNumber
        {
            memberProfile!.commit()
        }
       
        return memberProfile!
        
    }
    
    func getImageForUser() -> UIImage?
    {
        if imageData != nil
        {
            return UIImage(data: imageData! as Data)
        }
        return nil
    }

    func getAddressStringForMember() -> String
    {
        if addressLines == nil {
            return ""
        }
        var fullAddressString = addressLines as String
        if addressCity != nil && addressCity != ""
        {
            fullAddressString += ", \(addressCity as String)"
        }
        if addressCounty != nil && addressCounty != ""
        {
            fullAddressString += ", \(addressCounty as String)"
        }
        if addressState != nil && addressState != ""
        {
            fullAddressString += ", \(addressState as String)"
        }
        if addressPcZip != nil && addressPcZip != ""
        {
            fullAddressString += ", \(addressPcZip as String)"
        }
        if addressCountry != nil && addressCountry != ""
        {
            fullAddressString += ", \(addressCountry as String)"
        }
        return fullAddressString
    }
    
    
    func addAddressFromDictionary(_ addressDict:NSDictionary)
    {
        self.addressCity = addressDict.object(forKey: "City") as? String
        self.addressCountry = addressDict.object(forKey: "Country") as? String
        self.addressCounty = addressDict.object(forKey: "County") as? String
        self.addressPcZip = addressDict.object(forKey: "PcZip") as? String
        
        let state = addressDict.object(forKey: "State") as? Int
        if state != nil
        {
            self.addressState = String(state!)
        }
        
        let addressLinesArray = addressDict.object(forKey: "AddressLines") as! [Any]
        var addressLinesString = String()
        for line in addressLinesArray
        {
            if let lineString = line as? String
            {
                addressLinesString += lineString + ", "
            }
        }
        self.addressLines = addressLinesString.substring(to: addressLinesString.endIndex)
        
    }
    
}
