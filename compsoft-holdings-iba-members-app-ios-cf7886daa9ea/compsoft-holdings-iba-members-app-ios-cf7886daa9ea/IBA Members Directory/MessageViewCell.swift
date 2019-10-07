//
//  MessageViewCell.swift
//  IBA Members Directory
//
//  Created by George Smith on 15/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import UIKit

class MessageViewCell: UITableViewCell {
    
    @IBOutlet var messageTitle: UILabel!
    @IBOutlet var timeRecieved: UILabel!
    @IBOutlet var messageText: UILabel!
    @IBOutlet var newMessageIndicator: UIImageView!
    
    var message: MessageListProtocol!
    
    @IBOutlet var selectedIndicatorView: UIView!
    func createFromMessage(_ message: MessageListProtocol) {
        self.message = message
        self.messageTitle.text = message.title as String
        self.messageText.text = message.text as String
        
        if Date().daysFrom(message.timeSent) > 0 {
            self.timeRecieved.text = message.timeSent.toLocalTimeString("dd/MM/yyyy")
        } else {
            self.timeRecieved.text = Date().offsetFrom(message.timeSent)
        }
        if message.status == 0 {
            newMessageIndicator.alpha = 1
        } else {
            newMessageIndicator.alpha = 0
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if (selected) {
            selectedIndicatorView.backgroundColor = schemeColour_LightBlue
        } else {
            selectedIndicatorView.backgroundColor = UIColor(red: 245, green: 245, blue: 245)
        }
    }
    
    func setRead() {
        if message.status == 0 {
            newMessageIndicator.alpha = 1
        } else {
            newMessageIndicator.alpha = 0
        }
    }
}
