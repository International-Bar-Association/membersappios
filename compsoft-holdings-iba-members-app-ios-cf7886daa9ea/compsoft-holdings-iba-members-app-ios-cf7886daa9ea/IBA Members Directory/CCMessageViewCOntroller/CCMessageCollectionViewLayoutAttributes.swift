//
//  CCMessageCollectionViewLayoutAttributes.swift
//  IBA Members Directory
//
//  Created by George Smith on 27/07/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import UIKit

class CCMessageCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
    // MARK: - Properties
    
    var direction: MessageDirection = .outgoing
    
    var messageFont: UIFont = UIFont.preferredFont(forTextStyle: .body)
    
    var messageContainerSize: CGSize = .zero
    
    var messageContainerInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! CCMessageCollectionViewLayoutAttributes
        copy.direction = direction
        copy.messageFont = messageFont
        copy.messageContainerSize = messageContainerSize
        copy.messageContainerInsets = messageContainerInsets
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let _ = object as? CCMessageCollectionViewLayoutAttributes {
            return super.isEqual(object)
        } else {
            return false
        }
    }
}

public enum MessageDirection {
    
    case incoming
    case outgoing
    
}
