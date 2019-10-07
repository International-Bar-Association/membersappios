//
//  URL+Extension.swift
//  IBA Members Directory
//
//  Created by John Green on 28/09/2018.
//  Copyright © 2018 Compsoft plc. All rights reserved.
//

import UIKit

extension URL {

    static func cleaned(root: String, path: String) -> URL? {
        
        var output = path
        
        //if the path contains the root, remove it and clean it before re-assembly
        if let range = path.range(of: root) {
            output.removeSubrange(range)
            output = output.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            return URL(string: "\(root)\(output)")
        }
        return URL(string: "\(root)\(path)")
    }
    
}
