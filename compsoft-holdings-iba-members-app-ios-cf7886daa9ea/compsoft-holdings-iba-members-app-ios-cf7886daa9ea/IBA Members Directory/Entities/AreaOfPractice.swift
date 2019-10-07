//
//  AreaOfPractice.swift
//  IBA Members Directory
//
//  Created by Louisa Mousley on 21/05/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import Foundation


class AreaOfPractice: SRKObject {
    
    @objc dynamic var areaOfPracticeId : NSNumber!
    @objc dynamic var areaOfPracticeName : NSString!
    
    
    class func getAreaOfPracticeForId(_ areaOfPracticeId:NSNumber) -> AreaOfPractice?
    {
        if let areaOfPractice = AreaOfPractice.query().where(withFormat: "areaOfPracticeId = %i", withParameters: [areaOfPracticeId]).fetch().firstObject as! AreaOfPractice?
        {
            return areaOfPractice
        }
        return nil
    }
    
    
    class func updateAreasOfPracticeWithDictionary(_ areasOfPracticeDictionary : NSDictionary)
    {
        for (areaOfPracticeId, areaOfPracticeName) in areasOfPracticeDictionary
        {
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            let areaOfPracticeIdNumber = numberFormatter.number(from: areaOfPracticeId as! String)
            
            var areaOfPractice = AreaOfPractice.getAreaOfPracticeForId(areaOfPracticeIdNumber!)
            if areaOfPractice == nil
            {
                areaOfPractice = AreaOfPractice()
                areaOfPractice!.areaOfPracticeId = areaOfPracticeIdNumber
                
            }
            areaOfPractice!.areaOfPracticeName = areaOfPracticeName as! NSString
            areaOfPractice!.commit()
        }
    }
    
    class func getAllAreasOfPractice() -> [AreaOfPractice]    {
        
        var areaOfPracticeArray = [AreaOfPractice]()
        let results = AreaOfPractice.query().fetch()
        
        for result in results!   {
            let areaOfPractice = result as! AreaOfPractice
            areaOfPracticeArray.append(areaOfPractice)
        }
        
        return areaOfPracticeArray
    }
    
    class func getAreaOfPracticesWithNameIncluding(_ nameIncluding: String) -> [AreaOfPractice]? {
        
        var areaOfPracticeArray = [AreaOfPractice]()
        if let areaOfPractices =  AreaOfPractice.query().where(withFormat: "areaOfPracticeName LIKE '%%\(nameIncluding)%%'", withParameters: nil).fetch()
        {
            for result in areaOfPractices    {
                
                let areaOfPractice = result as! AreaOfPractice
                areaOfPracticeArray.append(areaOfPractice)
                
            }
        }
        
        if areaOfPracticeArray.count != 0    {
            return areaOfPracticeArray
        }   else    {
            return nil
        }
    }
    
}
