//
//  Committee.swift
//  IBA Members Directory
//
//  Created by Louisa Mousley on 21/05/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import Foundation

class Committee: SRKObject {
    
    @objc dynamic var committeeId : NSNumber!
    @objc dynamic var committeeName : NSString!
    
    
    class func getCommitteeForCommitteeId(_ committeeId:NSNumber) -> Committee?
    {
        if let committee =  Committee.query().where(withFormat: "committeeId = %i", withParameters: [committeeId]).fetch().firstObject as! Committee?
        {
            return committee
        }
        return nil
    }
    
    class func getAllCommittees() -> [Committee]    {
        
        var committeeArray = [Committee]()
        
        let results = Committee.query().fetch()
        
        for result in results!   {
            let committee = result as! Committee
            committeeArray.append(committee)
        }
        
        return committeeArray
        
    }
    
    
    class func updateCommitteesWithDictionary(_ committeesDictionary : NSDictionary)
    {
        for (committeeId, committeeName) in committeesDictionary
        {
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal

            let committeeIdNumber = numberFormatter.number(from: committeeId as! String)
            var committee = Committee.getCommitteeForCommitteeId(committeeIdNumber!)
            if committee == nil
            {
                committee = Committee()
                committee!.committeeId = committeeIdNumber
            }
            committee!.committeeName = committeeName as! NSString
            committee!.commit()
        }
        
    }
    
    class func getCommitteesWithNameIncluding(_ nameIncluding: String) -> [Committee]? {
        
        var committeeArray = [Committee]()
        if let committees =  Committee.query().where(withFormat: "committeeName LIKE '%%\(nameIncluding)%%'", withParameters: nil).fetch()
        {
            for result in committees    {
                
                let committee = result as! Committee
                committeeArray.append(committee)
                
            }
        }
        
        if committeeArray.count != 0    {
            return committeeArray
        }   else    {
            return nil
        }
    }
}
