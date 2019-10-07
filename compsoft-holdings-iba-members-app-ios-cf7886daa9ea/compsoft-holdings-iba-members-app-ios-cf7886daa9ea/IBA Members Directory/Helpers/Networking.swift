//
//  Networking.swift
//  IBA Members Directory
//
//  Created by Louisa Mousley on 14/05/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireObjectMapper

//let LIVE_URL = "https://ibamembersapp.ibanet.org/api/V2/" //LIVE
let GENERAL_ERROR_MESSAGE = "Oops! Something went wrong"

let hmac256HashKey = "VH45QcbPPDurBLKEdBN6bkJs22z7KKqpXNEygtn7"

class Networking {
    
    class func showErrorInStatusBar(_ error: String, code: Int) {
        debugPrint("Errors no longer shown in status bar")
    }
    
    class func getURLStringForBuild() -> String
    {
        return Environment().baseURL + "api/v2/"
    }
    
    class func getURLRequestForPath(_ path:String, method:HTTPMethod, parameters:[String : AnyObject]?) -> (URLRequest)
    {
        if let username = Settings.getUserEmail() {
            let password = Settings.getUserPassword()
            let apiToken = Settings.getUserAPISessionKey()
            
            return Networking.getURLRequestForPathWithUsernameAndPassword(path, method: method, username: username, password: password!, apiToken:apiToken, parameters: parameters)
        } else {
            return Networking.getURLRequestForPathWithUsernameAndPassword(path, method: method, username: "", password: "", apiToken:"", parameters: parameters)
        }
    }
    
    class func getURLRequestForPathWithUsernameAndPassword(_ path:String, method:HTTPMethod, username:String, password:String, apiToken:String?, parameters:[String : AnyObject]?,requiresAuthHeader: Bool = false) -> (URLRequest)
    {
        
        let URL = Foundation.URL(string: Networking.getURLStringForBuild())!
        var mutableURLRequest = URLRequest(url: URL.appendingPathComponent(path))
        mutableURLRequest.httpMethod = method.rawValue
        mutableURLRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-type")
        
        //Date header
        let dateString = Networking.getDateHeaderString()
        mutableURLRequest.setValue(dateString, forHTTPHeaderField: "Date")
        
        //Version Header
        mutableURLRequest.setValue("3", forHTTPHeaderField: "AppVersion")

        let basicAuthString = Networking.createAuthorizatonHeaderStringWithCredentials(username, password: password)
        //mutableURLRequest.setValue("1234", forHTTPHeaderField: "Test")
        if requiresAuthHeader {
            //Authorization header
            mutableURLRequest.setValue(basicAuthString, forHTTPHeaderField: "Authorization")
        } else {
            //basicAuthString = "UserKey \(Settings.getUserAPISessionKey())"
            //let key = Settings.getUserAPISessionKey()
            //print(key)
            mutableURLRequest.setValue(Settings.getUserAPISessionKey(), forHTTPHeaderField: "UserKey")
        }
        
        //X-Auth header
        let xAuthBase64String = Networking.createXAuthHeader(path, dateString: dateString, basicAuthString: basicAuthString, apiToken:apiToken)
        mutableURLRequest.setValue(xAuthBase64String, forHTTPHeaderField: "X-Auth")
        
        //UserKey header
        if apiToken != nil
        {
            
        }
        
        switch mutableURLRequest.httpMethod!
        {
            
        case HTTPMethod.get.rawValue, HTTPMethod.delete.rawValue:
            do {
                let encoded = try URLEncoding.default.encode(mutableURLRequest as! URLRequestConvertible, with: parameters)
                return encoded
            } catch {
                return mutableURLRequest as (URLRequest)
            }
            
        default:
            do {
                let encoded = try JSONEncoding.default.encode(mutableURLRequest, with: parameters)
                return encoded
            } catch {
                return mutableURLRequest as (URLRequest)
            }
        }
    }
    
    
    class func getDateHeaderString() -> String
    {
        //Date header
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        let dateString = dateFormatter.string(from: Date())
        return dateString
    }
    
    class func createAuthorizatonHeaderStringWithCredentials(_ username:String, password:String) -> String
    {
        let plainString = username + ":" + password
        let plainData = plainString.data(using: String.Encoding.utf8)
        let base64String = plainData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue:0))
        return "Basic " + base64String!
    }
    
    class func createXAuthHeader(_ path: String, dateString:String, basicAuthString: String, apiToken:String?) -> String
    {
        var xAuthString = "\(Environment().xauthString)\(path)" + " " + dateString + " "
        if apiToken == nil
        {
            xAuthString += basicAuthString
        }
        else
        {
            //if we've got an apiToken then we've logged in before.
            xAuthString += "UserKey " + apiToken!
        }
        
        let xAuthPlainData = xAuthString.data(using: String.Encoding.utf8)
        let hmacData = AuthorizationHelper.hmac(forKey: hmac256HashKey, andData: xAuthString)
        let xAuthBase64String = hmacData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue:0))
        return xAuthBase64String!
    }
    
    
    class func makeURLRequest(_ urlRequest: URLRequestConvertible,expectJson: Bool = true, completion: @escaping (_ json: AnyObject?, _ error: NSError?) -> Void)
    {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        if expectJson {
            print(urlRequest)
            request(urlRequest).validate().responseJSON { response in
                if let res = response.response{
                    print(res)
                    if res.statusCode == 403{
                        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.logUserOut(false)
                        DispatchQueue.main.async {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                    } else if let error = response.result.error as? NSError  {
                        if error.code  != -6006 {
                            showErrorInStatusBar(GENERAL_ERROR_MESSAGE, code: (error.code))
                        } else {
                            print("JSON failed serialization failed. Could be an empty body or could be more malicous")
                        }
                    }
                }
                completion(response.result.value as AnyObject?, response.result.error as NSError?)
            }
        } else {
            request(urlRequest).response{ response in
                print(response)
                if response.error != nil {
                    if response.response?.statusCode == 403 {
                        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.logUserOut(false)
                        DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                    } else {
                        showErrorInStatusBar(GENERAL_ERROR_MESSAGE, code: 0)
                    }
                }
                
                completion(nil, response.error as NSError?)
            }
        }
    }
    
    class func showNoInternetError()
    {
        showErrorInStatusBar("No Internet", code: 0)
    }
    
    class func checkForResponseError(_ responseJson: AnyObject?) -> Bool
    {
        if let responseDictionary = responseJson as? NSDictionary
        {
            var errorMessageString : String?
            if let responseErrorDictionary = responseDictionary["ResponseError"] as? NSDictionary
            {
                errorMessageString = responseErrorDictionary["Message"] as? String
            }
            else if let message = responseDictionary["Message"] as? String
            {
                errorMessageString = message
                
            }
            if errorMessageString != nil
            {
                print(errorMessageString!)
                
                showErrorInStatusBar(ERROR_TEXT, code: 0)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return true
            }
        }
        return false
    }
    
    class func loginWithUsernameAndPassword(_ username: String, password: String, completion:@escaping (_ success: Bool) -> ())
    {
        let urlRequest = Networking.getURLRequestForPathWithUsernameAndPassword("login", method: .put, username: username, password: password, apiToken: nil, parameters: nil,requiresAuthHeader: true)
        makeURLRequest(urlRequest) { (json, error) in
            
            if error != nil
            {
                Networking.showNoInternetError()
                completion(false)
                return
            }
            if Networking.checkForResponseError(json)
            {
                completion(false)
                return
            }
            
            if let responseDictionary = json as? NSDictionary
            {
                if let sessionId = responseDictionary.object(forKey: "SessionToken") as? String
                {
                    Settings.setUserAPISessionKey(sessionId)
                }
                
                if let profileDictionary = responseDictionary.object(forKey: "Profile") as? NSDictionary
                {
                    let UID = profileDictionary["Id"] as? Int
                    let memberProfile = MemberProfile.createMemberFromDictionary(UID, memberDictionary:profileDictionary, isMine:true)
                    Settings.setUserId(memberProfile.userId as! Int)
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion(true)
                return
            }
            completion(false)
        }
    }
    
    
    class func refreshDictionariesAndCheckForConference()
    {
        
        //NOTE: We want the bubble to show early if the user has a conference cached
        
        let urlRequest = Networking.getURLRequestForPath("refresh/", method: .get, parameters:nil)
        makeURLRequest(urlRequest) { (json, error) in
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default) .async {
                if let responseDictionary = json as? NSDictionary
                {
                    //get the areasOfPractice dictionary and save locally
                    if let areasOfPracticeDictionary = responseDictionary.object(forKey: "AreasOfPracticeDict") as? NSDictionary
                    {
                        AreaOfPractice.updateAreasOfPracticeWithDictionary(areasOfPracticeDictionary)
                    }
                    if let committeesDictionary = responseDictionary.object(forKey: "CommitteesDict") as? NSDictionary
                    {
                        Committee.updateCommitteesWithDictionary(committeesDictionary)
                    }
                    
                    if let conference = responseDictionary.object(forKey: "Conference") as? NSDictionary {
                        guard var myProfile = MemberProfile.getMyProfile() else {
                            return
                        }
                        if let shouldShow = conference.object(forKey: "ShowDetails") as? Bool {
                            myProfile.shouldSeeConfBubble = shouldShow as NSNumber?
                            if let conferenceId = conference.object(forKey: "ConferenceId") as? NSNumber {
                                myProfile.currentConference = conferenceId
                                //Does conference exist?
                                var conf = Conference.getConference(id: conferenceId as! Int)
                                if conf == nil {
                                    conf = Conference()
                                    conf!.conferenceId = conferenceId
                                    conf!.commit()
                                }
                                myProfile.commit()
                            }
                        }
                        
                        if let url = conference.object(forKey: "Url") as? String {
                            Settings.setConferenceURL(url)
                        } else {
                            Settings.setConferenceURL("https://www.google.com")
                        }
                        
                    } else {
                        guard let myProfile = MemberProfile.getMyProfile() else {
                            return
                        }
                        myProfile.shouldSeeConfBubble = 0
                        myProfile.commit()
                    }
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name("UpdatedDictionariesFromServer"), object: self)
                        NotificationCenter.default.post(name: NSNotification.Name("ConferenceStatusUpdated"), object: self)
                    }
                }
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    
    class func logout(_ completion:@escaping (_ loggedOutSuccessful:Bool) -> ())
    {
        let username = Settings.getUserEmail()
        let password = Settings.getUserPassword()
        var UUID = Settings.getUUID()
        if UUID == nil {
            print("Device UUID blank")
            UUID = ""
        }
        let urlRequest = Networking.getURLRequestForPathWithUsernameAndPassword("login", method:.delete, username:username!, password:password!, apiToken:Settings.getUserAPISessionKey(), parameters:["uuid":UUID! as AnyObject])
        makeURLRequest(urlRequest) { (json, error) in
            
            if Networking.checkForResponseError(json)
            {
                completion(false)
                return
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let responseSuccess = json as? Bool
            {
                completion(responseSuccess)
                return
            }
            completion(false)
            
        }
    }
    
    
    class func getProfilesWithSearchParameters(_ firstName:String?, lastName:String?, firmName:NSString?, city:String?, country:String?, committee:NSNumber?, areaOfPractice:NSNumber?,conference: Bool,take: NSNumber?, skip: NSNumber?, completion:@escaping (_ memberProfileArray: [MemberProfile]?, _ successful:Bool,_ isExtraResults:Bool,_ conferenceSearch: Bool) -> ())
    {
        var paramsGAString = ""
        var params = [String: AnyObject]()
        if firstName != nil && firstName != ""
        {
            params["firstName"] = firstName! as AnyObject?
            paramsGAString += "firstName = \(firstName!), "
        }
        if lastName != nil && lastName != ""
        {
            params["lastName"] = lastName! as AnyObject?
            paramsGAString += "lastName = \(lastName!), "
        }
        if firmName != nil && firmName != ""
        {
            params["firmName"] = firmName!
            paramsGAString += "firmName = \(firmName!), "
        }
        if city != nil && city != ""
        {
            params["city"] = city! as AnyObject?
            paramsGAString += "city = \(city!), "
        }
        if country != nil && country != ""
        {
            params["country"] = country! as AnyObject?
            paramsGAString += "country = \(country!), "
        }
        if committee != nil
        {
            params["committee"] = committee!
            paramsGAString += "committee = \(committee!), "
        }
        if areaOfPractice != nil
        {
            params["areaOfPractice"] = areaOfPractice!
            paramsGAString += "areaOfPractice = \(areaOfPractice!), "
        }
        
        params["OnlyConferenceAttendees"] = "\(conference)" as AnyObject

        let urlRequest = Networking.getURLRequestForPath("profile/", method: .get, parameters:params)
        makeURLRequest(urlRequest) { (json, error) in
            
            if error != nil
            {
                Networking.showNoInternetError()
                completion(nil, false,false,conference)
                return
            }
            if Networking.checkForResponseError(json)
            {
                completion(nil, false,false,conference)
                return
            }
            
            if let responseArray = json as? NSArray
            {
                var memberProfileArray : [MemberProfile]?
                memberProfileArray = [MemberProfile]()
                for memberDictionary in responseArray
                {
                    let memberProfile = MemberProfile.createMemberFromDictionary(nil, memberDictionary:memberDictionary as!     NSDictionary, isMine:false)
                    memberProfileArray!.append(memberProfile)
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                var isExtra = false
                if skip != nil {
                    if skip as! Int > 0 {
                        isExtra = true
                    }
                }
                completion(memberProfileArray, true,isExtra,conference)
                return
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            completion(nil, false,false,conference)
        }
        GAEventManager.sendSearchEvent(paramsGAString)
        
    }
    
    class func getAttendeesWithSearchParameters(_ firstName:String?, lastName:String?, firmName:NSString?, city:String?, country:String?, committee:NSNumber?, areaOfPractice:NSNumber?,conference: Bool,take: NSNumber?, skip: NSNumber?, completion:@escaping (_ memberProfileArray: [Attendee]?, _ successful:Bool) -> ())
    {
        var paramsGAString = ""
        var params = [String: AnyObject]()
        if firstName != nil && firstName != ""
        {
            params["firstName"] = firstName! as AnyObject?
            paramsGAString += "firstName = \(firstName!), "
        }
        if lastName != nil && lastName != ""
        {
            params["lastName"] = lastName! as AnyObject?
            paramsGAString += "lastName = \(lastName!), "
        }
        if firmName != nil && firmName != ""
        {
            params["firmName"] = firmName!
            paramsGAString += "firmName = \(firmName!), "
        }
        if city != nil && city != ""
        {
            params["city"] = city! as AnyObject?
            paramsGAString += "city = \(city!), "
        }
        if country != nil && country != ""
        {
            params["country"] = country! as AnyObject?
            paramsGAString += "country = \(country!), "
        }
        if committee != nil
        {
            params["committee"] = committee!
            paramsGAString += "committee = \(committee!), "
        }
        if areaOfPractice != nil
        {
            params["areaOfPractice"] = areaOfPractice!
            paramsGAString += "areaOfPractice = \(areaOfPractice!), "
        }
        
        params["OnlyConferenceAttendees"] = "\(conference)" as AnyObject
        
        let urlRequest = Networking.getURLRequestForPath("profile/", method: .get, parameters:params)
        makeURLRequest(urlRequest) { (json, error) in
            
            if error != nil
            {
                Networking.showNoInternetError()
                completion(nil, false)
                return
            }
            if Networking.checkForResponseError(json)
            {
                completion(nil, false)
                return
            }
            
            if let responseArray = json as? NSArray
            {
                var memberProfileArray : [Attendee]?
                memberProfileArray = [Attendee]()
                for memberDictionary in responseArray
                {
                    let attendee = Attendee.fromJson(json: memberDictionary as! [String : Any])
                    memberProfileArray!.append(attendee)
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                completion(memberProfileArray,true)
                return
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            completion(nil, false)
        }
        GAEventManager.sendSearchEvent(paramsGAString)
        
    }
    
    class func getProfileForId(_ memberId:NSNumber, showError:Bool, completion:@escaping (_ memberProfile: MemberProfile?) -> ())
    {
        let urlRequest = Networking.getURLRequestForPath("profile", method: .get, parameters:["userId" : memberId as AnyObject])
        makeURLRequest(urlRequest) { (json, error) in
            
            if error != nil
            {
                if showError
                {
                    Networking.showNoInternetError()
                }
                completion(nil)
                return
            }
            if Networking.checkForResponseError(json)
            {
                completion(nil)
                return
            }
            
            if let responseDictionary = json as? NSDictionary
            {
                let memberProfile = MemberProfile.createMemberFromDictionary(memberId as? Int, memberDictionary:responseDictionary, isMine:false)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion(memberProfile)
                return
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            completion(nil)
            
        }
    }
    
    class func updateProfileBiography(_ biography: String, completion:@escaping (_ success:Bool) -> ())
    {
        var params = ["Biography" : biography]
        let urlRequest = Networking.getURLRequestForPath("profile", method: .put, parameters:params as [String : AnyObject]?)
        makeURLRequest(urlRequest,expectJson: false) { (json, error) in
            
            if error != nil
            {
                Networking.showNoInternetError()
                completion(false)
                return
            }
            if Networking.checkForResponseError(json)
            {
                completion( false)
                return
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            GAEventManager.sendUpdateBioEvent()
            completion(true)
        }
    }
    
    class func changeProfilePrivacy(_ completion:@escaping (_ success:Bool) -> ())
    {
        let urlRequest = Networking.getURLRequestForPath("MakeProfilePublic", method: .put, parameters:nil)
        makeURLRequest(urlRequest,expectJson: false) { (json, error) in
            
            if error != nil
            {
                Networking.showNoInternetError()
                completion(false)
                return
            }
            if Networking.checkForResponseError(json)
            {
                completion(false)
                return
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            completion(true)
        }
    }
    
    class func updateProfilePicture(_ imageData: Data, completion:@escaping (_ success:Bool, _ data:Data?) -> ())    {
        
        
        let apiToken = Settings.getUserAPISessionKey()
        let URL = Foundation.URL(string: Networking.getURLStringForBuild())!
        var mutableURLRequest = URLRequest(url: URL.appendingPathComponent("profileimage"))
        mutableURLRequest.httpMethod = HTTPMethod.put.rawValue
        
        let dateString = Networking.getDateHeaderString()
        mutableURLRequest.setValue(dateString, forHTTPHeaderField: "Date")
        
        //Authorization header
        let basicAuthString = Networking.createAuthorizatonHeaderStringWithCredentials(Settings.getUserEmail()!, password: Settings.getUserPassword()!)
        mutableURLRequest.setValue(basicAuthString, forHTTPHeaderField: "Authorization")
        
        //X-Auth header
        let xAuthBase64String = Networking.createXAuthHeader("profileimage", dateString: dateString, basicAuthString: basicAuthString, apiToken:apiToken)
        mutableURLRequest.setValue(xAuthBase64String, forHTTPHeaderField: "X-Auth")
        
        mutableURLRequest.setValue(apiToken!, forHTTPHeaderField: "UserKey")
        
        let boundaryConstant = "----WebKitFormBoundaryV3ahoxVHofGKBhh3";
        let contentType = "multipart/form-data; boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        var uploadData = Data()
        uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Disposition: form-data; name=\"ProfileImage\"; filename=\"image.png\"\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Type: image/png\r\n\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append(imageData)
        uploadData.append("\r\n--\(boundaryConstant)--\r\n".data(using: String.Encoding.utf8)!)
        
        
        
        upload(uploadData, with: mutableURLRequest as! URLRequestConvertible).response { response in
            
            guard response.error == nil else {
                print("error calling POST on /uploadPhoto")
                completion(false,nil)
                return
            }
            
            if let error = response.error {
                let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.logUserOut(false)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if response.response?.statusCode == 200 {
                GAEventManager.sendUpdatePhotoEvent()
                completion(true, imageData)
                
            }
            else
            {
                completion(false, nil)
            }
        }
    }
}

extension Networking {
    //MARK: V2 Networking Stuff
    class func getMessages(_ from: String?, success: @escaping (_ results:MessageResponseModel) -> Void, failure:@escaping (_ error: Error?) -> Void) -> Void {
        var urlRequest = Networking.getURLRequestForPath("message", method: .get, parameters:["length":20 as AnyObject,"start":0 as AnyObject])
        if from != nil {
            urlRequest = Networking.getURLRequestForPath("message", method: .get, parameters:["from":from! as AnyObject,"length":20 as AnyObject,"start":0 as AnyObject])
        }
        
        
        SessionManager.default.request(urlRequest).validate().responseObject { (response: DataResponse<MessageResponseModel>) in
            if !response.result.isSuccess {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let res = response.response {
                    if res.statusCode == 403 {
                        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.logUserOut(false)
                    } else {
                        showErrorInStatusBar("A Network Error has occurred.", code: 0)
                    }
                }
                failure(nil)
            }
            if  let responseData = response.result.value {
                success(responseData)
            } else {
                showErrorInStatusBar(GENERAL_ERROR_MESSAGE, code: 0)
                failure(nil)
            }
        }
        
    }
    
    class func getMessage(_ id: Int, success: @escaping (_ results:MessageResponseModel) -> Void, failure:@escaping (_ error: Error?) -> Void) -> Void {
        let urlRequest = Networking.getURLRequestForPath("message", method: .get, parameters:["AppUserMessageId":id as AnyObject])
        SessionManager.default.request(urlRequest).validate().responseObject { (response: DataResponse<MessageResponseModel>) in
            if !response.result.isSuccess {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let res = response.response {
                    if res.statusCode == 403 {
                        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.logUserOut(false)
                    } else {
                        showErrorInStatusBar("A Network Error has occurred.", code: 0)
                    }
                }
                
                showErrorInStatusBar("A Network Error has occurred.", code: 0)
                failure(nil)
            }
            if  let responseData = response.result.value {
                success( responseData)
            } else {
                failure(nil)
            }
        }
        
    }
    
    class func setMessageRead(_ id: Int,success: @escaping () -> Void, failure:(_ error: Error?) -> Void) -> Void {
        
        let params = ["AppUserMessageId" : id, "Read": Date().toTimeString("yyyy-MM-dd")] as [String : Any]
        let urlRequest = Networking.getURLRequestForPath("message", method: .put, parameters:params as? [String : AnyObject])
        makeURLRequest(urlRequest, expectJson: false) { (json, error) in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            success()
        }
        
    }
    
    class func setMessageDeleted(_ id: Int,success: @escaping () -> Void, failure:(_ error: Error?) -> Void) -> Void {
        
        let params = ["AppUserMessageId" : id, "Deleted": Date().toTimeString("yyyy-MM-dd")] as [String : Any]
        let urlRequest = Networking.getURLRequestForPath("message", method: .put, parameters:params as? [String : AnyObject])
        makeURLRequest(urlRequest, expectJson: false) { (json, error) in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            success()
        }
        
    }
    
    class func setMessageReceived(_ id: Int,success: @escaping () -> Void, failure:(_ error: Error?) -> Void) -> Void {
        
        let params = ["AppUserMessageId" : id, "Received": Date().toTimeString("yyyy-MM-dd")] as [String : Any]
        let urlRequest = Networking.getURLRequestForPath("message", method: .put, parameters:params as? [String : AnyObject])
        makeURLRequest(urlRequest, expectJson: false) { (json, error) in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            success()
        }
        
    }
    
    class func getContent(_ from: String, success: @escaping (_ results:ContentLibraryResponseModel) -> Void, failure:@escaping (_ error: Error?) -> Void) -> Void {
        let urlRequest = Networking.getURLRequestForPath("ContentLibrary", method: .get, parameters:["length":20 as AnyObject,"start":0 as AnyObject])
        SessionManager.default.request(urlRequest).validate().responseObject { (response: DataResponse<ContentLibraryResponseModel>) in
            if !response.result.isSuccess {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                if let res = response.response {
                    if res.statusCode == 403 {
                        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.logUserOut(false)
                    } else {
                        showErrorInStatusBar("A Network Error has occurred.", code: 0)
                    }
                }
                
                failure(nil)
            }
            if  let responseData = response.result.value {
                success(responseData)
            } else {
                failure(nil)
            }
        }
    }
    
    class func configurePushDeviceToken(_ completion:(() -> ())? ) {
        let pushToken = Settings.getPushDeviceToken()
        var params: [String:AnyObject] = [:]
        if pushToken == nil {
            return
        }
        if let uuid =  Settings.getUUID() {
            params = ["DeviceUUID" : uuid as AnyObject, "DeviceType": 1 as AnyObject,"PushToken": pushToken! as AnyObject]
        } else {
            let uuid = UUID().uuidString
            Settings.setUUID(uuid)
            params = ["DeviceUUID" : uuid as AnyObject, "DeviceType": 1 as AnyObject,"PushToken": pushToken! as AnyObject]
        }
        
        let urlRequest = Networking.getURLRequestForPath("Device", method: .put, parameters:params)
        makeURLRequest(urlRequest) { (json, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if completion != nil {
                completion!()
            }
        }
    }
    
    class func getConferenceDetails(_ id: Int,success: @escaping (_ results:ConferenceEventResponseModel) -> Void, failure:@escaping (_ error: Error?) -> Void) -> Void {
        let urlRequest = Networking.getURLRequestForPath("conference", method: .get, parameters:["id":id as AnyObject])
        
        SessionManager.default.request(urlRequest).validate().responseObject { (response: DataResponse<ConferenceEventResponseModel>) in
            if !response.result.isSuccess {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let res = response.response {
                    if res.statusCode == 403 {
                        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.logUserOut(false)
                    } else {
                        showErrorInStatusBar("A Network Error has occurred.", code: 0)
                    }
                }
                failure(nil)
            }
            if  let responseData = response.result.value {
                success(responseData)
            } else {
                showErrorInStatusBar(GENERAL_ERROR_MESSAGE, code: 0)
                failure(nil)
            }
        }
        
    }
    
    class func getConferenceEvents(_ id: Int,success: @escaping (_ results: ConferenceBuildingEventResponseModel) -> Void, failure:@escaping (_ error: Error?) -> Void) -> Void {
        let urlRequest = Networking.getURLRequestForPath("conference/\(id)/buildingevents", method: .get, parameters:["take":1000 as AnyObject])
        
        SessionManager.default.request(urlRequest).validate().responseObject{ (response: DataResponse<ConferenceBuildingEventResponseModel>) in
            if !response.result.isSuccess {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let res = response.response {
                    if res.statusCode == 403 {
                        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.logUserOut(false)
                    } else {
                        showErrorInStatusBar("A Network Error has occurred.", code: 0)
                    }
                }
                failure(nil)
            }
            if  let responseData = response.result.value {
                success(responseData)
            } else {
                showErrorInStatusBar(GENERAL_ERROR_MESSAGE, code: 0)
                failure(nil)
            }
        }
        
    }
    
    class func getP2PMessageConnections(success: @escaping (_ results:[P2PConnectionResponseModel]) -> Void, failure:@escaping (_ error: Error?) -> Void) -> Void {
        
        let urlRequest = Networking.getURLRequestForPath("P2PConnections", method: .get, parameters:nil)
        
        SessionManager.default.request(urlRequest).validate().responseArray{ (response: DataResponse<[P2PConnectionResponseModel]>) in
            if !response.result.isSuccess {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let res = response.response {
                    if res.statusCode == 403 {
                        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.logUserOut(false)
                    } else {
                        showErrorInStatusBar("A Network Error has occurred.", code: 0)
                    }
                }
                failure(nil)
            }
            if  let responseData = response.result.value {
                success(responseData)
            } else {
                showErrorInStatusBar(GENERAL_ERROR_MESSAGE, code: 0)
                failure(nil)
            }
        }
    }
    
    class func getP2PMessages(id: Int, skip: Int, take: Int,success: @escaping (_ results:P2PMessageThreadResponseModel) -> Void, failure:@escaping (_ error: Error?) -> Void) -> Void {
        
        let urlRequest = Networking.getURLRequestForPath("P2P", method: .get, parameters:["id":id as AnyObject,"take":take as AnyObject, "skip":skip as AnyObject])
        
        SessionManager.default.request(urlRequest).validate().responseObject{ (response: DataResponse<P2PMessageThreadResponseModel>) in
            if !response.result.isSuccess {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let res = response.response {
                    if res.statusCode == 403 {
                        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.logUserOut(false)
                    } else {
                        showErrorInStatusBar("A Network Error has occurred.", code: 0)
                    }
                }
                failure(nil)
            }
            if  let responseData = response.result.value {
                success(responseData)
            } else {
                showErrorInStatusBar(GENERAL_ERROR_MESSAGE, code: 0)
                failure(nil)
            }
        }
    }
    
    class func sendP2PMessages(id: Int,message: String,success: @escaping (_ results:SendP2PResponseModel) -> Void, failure:@escaping (_ error: Error?) -> Void) -> Void {
        let urlRequest = Networking.getURLRequestForPath("P2P", method: .post, parameters:["UserId":id as AnyObject,"Message":message as AnyObject, "UUID":UUID().uuidString as AnyObject])
        
        SessionManager.default.request(urlRequest).validate().responseObject{ (response: DataResponse<SendP2PResponseModel>) in
            if !response.result.isSuccess {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let res = response.response {
                    if res.statusCode == 403 {
                        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.logUserOut(false)
                    } else {
                        showErrorInStatusBar("A Network Error has occurred.", code: 0)
                    }
                }
                failure(nil)
            }
            if  let responseData = response.result.value {
                success(responseData)
            } else {
                showErrorInStatusBar(GENERAL_ERROR_MESSAGE, code: 0)
                failure(nil)
            }
        }
    }
    
    class func setP2PMessageRead(id: Int, success: @escaping () -> Void, failure: @escaping (_ error: Error?) -> Void) -> Void {
        let urlRequest = Networking.getURLRequestForPath("P2P/\(id)/read", method: .post, parameters:["threadId":id as AnyObject])
        makeURLRequest(urlRequest, expectJson: false) { (json, error) in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            success()
        }
        
    }
    
    class func hideP2PThread(id: Int,success: @escaping () -> Void, failure:@escaping (_ error: Error?) -> Void) -> Void {
        
        let urlRequest = Networking.getURLRequestForPath("P2P", method: .put, parameters:["threadId":id as AnyObject])
        SessionManager.default.request(urlRequest).validate().response(completionHandler: { (response) in
            print(response)
        })
    }
    
    
}
