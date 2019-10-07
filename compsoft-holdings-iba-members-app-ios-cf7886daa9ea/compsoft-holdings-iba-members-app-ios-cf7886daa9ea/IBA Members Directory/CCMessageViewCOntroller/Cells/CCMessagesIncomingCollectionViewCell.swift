//
//  CCMessagesIncomingCollectionViewCell.swift
//  IBA Members Directory
//
//  Created by George Smith on 25/07/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class CCMessagesIncomingCollectionViewCell: CCMessagesCollectionViewCell {
    
    override init(frame: CGRect) {
        //CREATE CELL
        super.init(frame: frame)
        self.messageBubbleTopLabel?.textAlignment = NSTextAlignment.left
        self.cellBottomLabel?.textAlignment = NSTextAlignment.left
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override class func cellReuseIdentifier() -> String {
        return "CCIncomingCollectionViewCell"
    }
    
    override class func mediaCellReuseIdentifier() -> String {
        return ""
    }

}

class CCMessagesOutgoingCollectionViewCell: CCMessagesCollectionViewCell {
    override init(frame: CGRect) {
        //CREATE CELL
        super.init(frame: frame)
        self.messageBubbleTopLabel?.textAlignment = NSTextAlignment.right
        self.cellBottomLabel?.textAlignment = NSTextAlignment.right
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func cellReuseIdentifier() -> String {
        return "CCOutgoingCollectionViewCell"
    }
    
    override class func mediaCellReuseIdentifier() -> String {
        return ""
    }
}

