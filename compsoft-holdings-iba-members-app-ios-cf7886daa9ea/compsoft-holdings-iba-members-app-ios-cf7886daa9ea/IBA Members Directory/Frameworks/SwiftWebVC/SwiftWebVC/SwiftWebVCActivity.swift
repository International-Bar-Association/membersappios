//
//  SwiftWebVCActivity.swift
//
//  Created by Myles Ringle on 24/06/2015.
//  Transcribed from code used in SVWebViewController.
//  Copyright (c) 2015 Myles Ringle & Sam Vermette. All rights reserved.
//

import UIKit


class SwiftWebVCActivity: UIActivity {

    var URLToOpen: URL?
    var schemePrefix: String?
    
    override var activityType : UIActivityType? {
 
        let typeArray = "\(type(of: self))".components(separatedBy: ".")
        let typeStr: String = typeArray[typeArray.count-1]
        return UIActivityType(rawValue: typeStr)
    }
        
    override var activityImage : UIImage {
        if let type = activityType?.rawValue {
            return SwiftWebVC.bundledImage(named: "\(type)")!
        }
        else{
            assert(false, "Unknow type")
            return UIImage()
        }
    }
            
    override func prepare(withActivityItems activityItems: [Any]) {
        for activityItem in activityItems {
            if activityItem is URL {
                URLToOpen = activityItem as? URL
            }
        }
    }

}
