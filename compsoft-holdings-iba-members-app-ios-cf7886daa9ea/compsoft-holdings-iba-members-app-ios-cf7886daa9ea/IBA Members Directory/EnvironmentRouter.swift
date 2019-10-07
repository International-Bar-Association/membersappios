//
//  EnvironmentRouter.swift
//  IBA Members Directory
//
//  Created by Myles Eynon on 09/06/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import Foundation
import AirshipKit
import Firebase

enum Environment {
    case development
    case testing
    case staging
    case production
    case unknown
    
    init() {
        let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist")
        let plistDict = NSDictionary(contentsOfFile: plistPath!)!
        if let environmentString = plistDict["Environment"] as? String {
            switch environmentString {
            case "DEVELOPMENT": self = .development
            case "PRODUCTION": self = .production
            case "TESTING": self = .testing
            case "STAGING": self = .staging
            default: self = .unknown
            }
            return
        }
        self = .unknown
    }
    
    var baseURL: String {
        switch self {
        case .production:
            return "https://ibamembersapp.ibanet.org/"
        case .staging:
            return "http://mobileapp.testing-int-bar.org/"
        default: return "http://10.19.13.146/ibamembersapp/"
        }
    }
    
    var xauthString: String {
        switch self {
        case .production: return "/api/v2/"
        case .staging: return "/api/v2/"
        default: return "/ibamembersapp/api/v2/"
        }
    }
    private var urbanAirshipConfigPath: String {
        switch self {
        case .development, .testing:
            return "AirshipConfigDev"
        case .staging:
            return "AirshipConfigStaging"
        case .production:
            return "AirshipConfigProduction"
        default:
            return ""
        }
    }
    
    private var firebaseConfigPath: String {
        switch self {
        case .development, .testing:
            return "GoogleService-Info-Development"
        case .staging:
            return "GoogleService-Info-Staging"
        case .production:
            return "GoogleService-Info-Production"
        default:
            return ""
        }
    }
    
    var urbanAirshipConfig: UAConfig {
        get {
            let path = Bundle.main.path(forResource: self.urbanAirshipConfigPath, ofType: "plist")
            return UAConfig(contentsOfFile: path ?? "")

        }
    }
    
    var firebaseConfig: FirebaseOptions? {
        get {
            let path = Bundle.main.path(forResource: self.firebaseConfigPath, ofType: "plist")
            return FirebaseOptions(contentsOfFile: path ?? "")
            
        }
    }
    
    func isEnviroment(type: Environment) -> Bool {
        if type == self {
            return true
        }
        return false
    }
}

