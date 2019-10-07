//
//  GAEventManager.swift
//  IBA Members Directory
//
//  Created by Louisa Mousley on 26/08/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import Foundation


class GAEventManager : NSObject
{
    
    class func sendTabSelectedEvent(_ tabName:String)
    {
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: nil)
//        var build = GAIDictionaryBuilder.createEventWithCategory("Screen Changed", action: "Tab Selected", label: tabName, value: nil).build() as [NSObject : AnyObject]
//        tracker.send(build)
    }
    
    
    class func sendUpdateBioEvent()
    {
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: nil)
//        var build = GAIDictionaryBuilder.createEventWithCategory("Profile", action: "Updated", label: "Biography", value: nil).build() as [NSObject : AnyObject]
//        tracker.send(build)
    }
    
    class func sendUpdatePhotoEvent()
    {
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: nil)
//        var build = GAIDictionaryBuilder.createEventWithCategory("Profile", action: "Updated", label: "Photo", value: nil).build() as [NSObject : AnyObject]
//        tracker.send(build)
    }
    
    class func sendFavouriteAddedEvent()
    {
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: nil)
//        var build = GAIDictionaryBuilder.createEventWithCategory("Favourite", action: "Added", label: "Favourite", value: nil).build() as [NSObject : AnyObject]
//        tracker.send(build)
    }
    
    class func sendSearchEvent(_ paramsString: String)
    {
        //TODO: LKM need to add search parameters to GA event
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker.set(kGAIScreenName, value: nil)
//        var build = GAIDictionaryBuilder.createEventWithCategory("Search", action: "", label: paramsString, value: nil).build() as [NSObject : AnyObject]
//        tracker.send(build)
    }
    
}
