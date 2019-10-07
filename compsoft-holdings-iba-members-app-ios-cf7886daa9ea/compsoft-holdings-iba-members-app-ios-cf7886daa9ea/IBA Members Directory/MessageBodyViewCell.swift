//
//  MessageBodyViewCell.swift
//  IBA Members Directory
//
//  Created by George Smith on 15/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import UIKit

class MessageBodyViewCell: UITableViewCell {
    
    @IBOutlet var messageBody: UILabel!
    @IBOutlet var messageWebView: UIWebView!
    var webViewHeightConstraint: NSLayoutConstraint!
    
    func setupHeightConstraintForWebView(_ remaningSpace: CGFloat) {
        webViewHeightConstraint = NSLayoutConstraint(item: messageWebView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: remaningSpace)
        messageWebView.addConstraint(webViewHeightConstraint)
    }
    
    func removeHeightConstraint() {
        if webViewHeightConstraint != nil {
            messageWebView.removeConstraint(webViewHeightConstraint)
            messageWebView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
