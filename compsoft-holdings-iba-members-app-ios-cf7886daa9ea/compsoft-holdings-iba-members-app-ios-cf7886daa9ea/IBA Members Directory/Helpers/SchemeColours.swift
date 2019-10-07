//
//  SchemeColours.swift
//  IBA Members Directory
//
//  Created by Jacob King on 14/05/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import UIKit

let schemeColour_DeepBlue = UIColor(red: 27/255, green: 43/255, blue: 120/255, alpha: 1)
let schemeColour_MidBlue = UIColor(red: 123/255, green: 129/255, blue: 167/255, alpha: 1)
let schemeColour_LightBlue = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
let schemeColour_BackgroundLightGrey = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)

let schemeColour_LightGreyText = UIColor.lightGray
let schemeColour_DarkGreyText = UIColor.darkGray


extension UIColor
{
    convenience init(red: Int, green: Int, blue: Int)
    {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
    
    static func darkGreenColor() -> UIColor {
        return UIColor(red: 59, green: 114, blue: 18)
    }
    
    static func darkRedColor() -> UIColor {
        return UIColor(red: 149, green: 0, blue: 21)
    }
}
