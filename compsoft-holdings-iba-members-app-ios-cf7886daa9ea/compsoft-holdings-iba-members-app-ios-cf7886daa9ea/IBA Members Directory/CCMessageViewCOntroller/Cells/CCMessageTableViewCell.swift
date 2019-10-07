//
//  CCMessageTableViewCell.swift
//  IBA Members Directory
//
//  Created by George Smith on 01/08/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class CCMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var cellTopLabel: UILabel!
    @IBOutlet weak var bubbleTopLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bubbleImageView: UIImageView!
    @IBOutlet weak var cellBottomLabel: UILabel!
    @IBOutlet weak var bubbleImageWidthConstraint: NSLayoutConstraint!
    
    class func reuseIdentifier(outgoing: Bool) -> String {
        return outgoing ? "CCMessageOutgoingTableViewCell" : "CCMessageIncomingTableViewCell"
    }
}
