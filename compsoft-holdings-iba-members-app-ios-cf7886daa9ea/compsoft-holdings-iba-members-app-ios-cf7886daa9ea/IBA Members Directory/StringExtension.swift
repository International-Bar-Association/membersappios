//
//  StringExtension.swift
//  IBA Members Directory
//
//  Created by George Smith on 02/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import Foundation

extension String {
    func escapeStringForUrl() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!
    }
    
    func stringToDate(_ format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)!
    }
    
    /** Creates attributed string of self with given colour and font */
    func toAttributedString(withColour colour: UIColor, andFont font: Fonts = .regular(.regular), andAlpha alpha: CGFloat = 1.0, andParagraphStyle pStyle: NSMutableParagraphStyle? = nil) -> NSAttributedString {
        
        var attributes = [NSAttributedStringKey : Any]()
        
        attributes[.foregroundColor] = colour.withAlphaComponent(alpha)
        
        if let pStyle = pStyle {
            attributes[.paragraphStyle] = pStyle
        }
        attributes[.font] = font.font
        
        return NSAttributedString(string: self, attributes: attributes)
    }
    
    func encryptCountryString() -> String? {
        
        let path = Bundle.main.path(forResource: "Countries", ofType: "plist")
        let countriesDict = NSDictionary(contentsOfFile: path!)!
        
        for key in countriesDict.allKeys {
            
            if countriesDict[key as! String] as? String == self {
                
                return key as? String
            }
        }
        return nil
    }
}
