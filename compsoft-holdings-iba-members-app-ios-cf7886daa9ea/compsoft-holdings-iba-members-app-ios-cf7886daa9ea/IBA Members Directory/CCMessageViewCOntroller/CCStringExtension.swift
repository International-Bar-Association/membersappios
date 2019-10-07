//
//  CCStringExtension.swift
//  IBA Members Directory
//
//  Created by George Smith on 28/07/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import Foundation


extension String {
    
    func height(considering width: CGFloat, and font: UIFont) -> CGFloat {
        
        let constraintBox = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundRect = self.boundingRect(with: constraintBox, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return boundRect.height
        
    }
    
    func width(considering height: CGFloat, and font: UIFont) -> CGFloat {
        
        let constraintBox = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundRect = self.boundingRect(with: constraintBox, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return boundRect.width
        
    }
    
    
}
