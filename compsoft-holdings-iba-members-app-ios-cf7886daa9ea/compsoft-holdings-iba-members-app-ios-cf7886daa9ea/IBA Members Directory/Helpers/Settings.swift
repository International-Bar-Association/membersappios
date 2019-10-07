//
//  Settings.swift
//  IBA Members Directory
//
//  Created by Louisa Mousley on 15/05/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import Foundation
import Crashlytics

let userEmailAddressKey = "userEmailAddress"
let userIdKey = "userIdKey"
let userPasswordKey = "userPassword"
let userAPISessionKey = "userAPISessionKey"
let runCountSinceLastReminderKey = "runCountSinceLastReminder"
let rememberLoginDetailsKey = "rememberLoginDetails"
let conferenceUrlKey = "conferenceUrlKey"
let loggedInKey = "loggedInKey"
let pushDeviceTokenKey = "pushDeviceTokenKey"
let uuidKey = "uuidKey"
let badgeAmountKey = "badgeAmountKey"
let badgeAmountP2PKey = "badgeAmountP2PKey"
let hasPreviouslauncedKey  = "previouslyLauncedKey"
class Settings
{
    class func initialise()
    {
        //we currently don't have any readWriteSettings that don't want to be overwritten - but keeping this here
        let readWriteSettings = [String]()
        
        // Read-only settings should always be updated from the DefaultSettings.plist. As its likely to be a url or similar that we want to change with app updates

        var defaultSettings: NSDictionary?
        if let path = Bundle.main.path(forResource: "DefaultSetting", ofType: "plist") {
            defaultSettings = NSDictionary(contentsOfFile: path)
        }
        if defaultSettings != nil {
            // Use your dict here
            let settings = UserDefaults.standard
            for (key, object) in defaultSettings!
            {
                // Overwrite values for read only values or read write values that are null
                if !readWriteSettings.contains((key as! String)) || settings.object(forKey: key as! String) == nil
                {
                    settings.setValue(object, forKey: key as! String)
                }
            }
        }
        
        var conferenceColours: NSDictionary?
        if let path = Bundle.main.path(forResource: "ConferenceUISetting", ofType: "plist") {
            conferenceColours = NSDictionary(contentsOfFile: path)
        }
        if conferenceColours != nil {
            // Use your dict here
            let settings = UserDefaults.standard
            for (key, object) in conferenceColours!
            {
                // Overwrite values for read only values or read write values that are null
                if !readWriteSettings.contains((key as! String)) || settings.object(forKey: key as! String) == nil
                {
                    settings.setValue(object, forKey: key as! String)
                }
            }
        }

    }
    
    class func setHasPreviouslyLaunched(_ launched: Bool) {
        UserDefaults.standard.set(launched, forKey: hasPreviouslauncedKey)
        UserDefaults.standard.synchronize()
    }
    
    class func getHasPreviouslyLaunched() -> Bool? {
        return UserDefaults.standard.bool(forKey: hasPreviouslauncedKey)
    }
    
    class func getUserEmail() -> String? {
        return UserDefaults.standard.string(forKey: userEmailAddressKey)
    }
    
    class func setUserEmail(_ emailAddress: String?) {
        
        UserDefaults.standard.set(emailAddress, forKey: userEmailAddressKey)
        UserDefaults.standard.synchronize()
        
    }
    
    class func getUserId() -> Int {
        return UserDefaults.standard.integer(forKey: userIdKey)
    }
    
    class func setUserId(_ id: Int?) {
        
        UserDefaults.standard.set(id, forKey: userIdKey)
        UserDefaults.standard.synchronize()
        
    }
    
    class func getUserPassword() -> String? {
        return UserDefaults.standard.string(forKey: userPasswordKey)
    }
    
    class func setUserPassword(_ password: String?) {
        
        UserDefaults.standard.set(password, forKey: userPasswordKey)
        UserDefaults.standard.synchronize()
    }
    
    class func getUserAPISessionKey() -> String? {
        return UserDefaults.standard.string(forKey: userAPISessionKey)
    }
    
    class func setUserAPISessionKey(_ sessionKey: String?) {
        
        UserDefaults.standard.set(sessionKey, forKey: userAPISessionKey)
        UserDefaults.standard.synchronize()
    }
    
    class func getRunCountSinceLastReminder() -> Int?    {
        return UserDefaults.standard.integer(forKey: runCountSinceLastReminderKey)
    }
    
    class func getBaseUrl() -> String? {
        return Environment().baseURL
    }
    
    class func setRunCountSinceLastReminder(_ runCount: Int?) {
        
        UserDefaults.standard.set(runCount, forKey: runCountSinceLastReminderKey)
        UserDefaults.standard.synchronize()
    }
    
    class func getRememberLoginDetails() -> Bool    {
        return UserDefaults.standard.bool(forKey: rememberLoginDetailsKey)
    }
    
    class func setRememberLoginDetails(_ rememberLoginDetails: Bool) {
        
        UserDefaults.standard.set(rememberLoginDetails, forKey: rememberLoginDetailsKey)
        UserDefaults.standard.synchronize()
    }
    
    class func setConferenceURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: conferenceUrlKey)
        UserDefaults.standard.synchronize()
    }
    
    class func getConferenceURL() -> String? {
        return UserDefaults.standard.string(forKey: conferenceUrlKey)
    }
    
    class func setIsLoggedIn (_ loggedIn: Bool)
    {
        UserDefaults.standard.set(loggedIn, forKey: loggedInKey)
        UserDefaults.standard.synchronize()
    }
    
    class func getIsLoggedIn () -> Bool{
        return UserDefaults.standard.bool(forKey: loggedInKey)
    }
    
    class func setPushDeviceToken (_ deviceToken: String?)
    {
        UserDefaults.standard.setValue(deviceToken, forKey: pushDeviceTokenKey)
        UserDefaults.standard.synchronize()
    }
    
    class func getPushDeviceToken () -> String?{
        return UserDefaults.standard.string(forKey: pushDeviceTokenKey)
    }
    
    class func setUUID (_ uuid: String) {
        UserDefaults.standard.setValue(uuid, forKey: uuidKey)
        UserDefaults.standard.synchronize()
    }
    
    class func getUUID() -> String? {
        return UserDefaults.standard.string(forKey: uuidKey)
    }
    
    class func setBadgeAmount(_ amount: Int) {
        UserDefaults.standard.setValue(amount, forKey: badgeAmountKey)
        UserDefaults.standard.synchronize()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    class func getBadgeAmount() -> Int {
        return UserDefaults.standard.integer(forKey: badgeAmountKey)
    }
    
    class func setBadgeP2PAmount(_ amount: Int) {
        UserDefaults.standard.setValue(amount, forKey: badgeAmountP2PKey)
        UserDefaults.standard.synchronize()
        
        UIApplication.shared.applicationIconBadgeNumber = Settings.totalBadgeAmount
    }
    
    class var totalBadgeAmount: Int {
        get {
            let messages = Settings.getBadgeAmount()
            let p2ps = Settings.getBadgeP2PAmount()
            return messages + p2ps
        }
        
    }
    
    class func getBadgeP2PAmount() -> Int {
        return UserDefaults.standard.integer(forKey: badgeAmountP2PKey)
    }
    
    class func getConferencePrimaryColour() -> UIColor {
        let hex = UserDefaults.standard.string(forKey: "PrimaryEventColour")
        return UIColor(hex: hex!)
    }
    
    class func getConferenceSecondaryColour() -> UIColor {
        let hex = UserDefaults.standard.string(forKey: "SecondaryEventColour")
        return UIColor(hex: hex!)
    }
    
    class func getSelectedEventColour() -> UIColor {
        let hex = UserDefaults.standard.string(forKey: "SelectedEventColour")
        return UIColor(hex: hex!)
    }
    
}
