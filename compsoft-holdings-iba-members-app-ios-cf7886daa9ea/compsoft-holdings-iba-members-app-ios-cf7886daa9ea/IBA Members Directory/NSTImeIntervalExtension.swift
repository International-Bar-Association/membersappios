//
//  NSTImeIntervalExtension.swift
//  IBA Members Directory
//
//  Created by George Smith on 08/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    func toString() -> String {
        let interval = Int(self)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
