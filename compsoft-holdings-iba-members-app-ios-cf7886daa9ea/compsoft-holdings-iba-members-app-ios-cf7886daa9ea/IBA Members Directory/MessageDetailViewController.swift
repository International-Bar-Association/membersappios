//
//  MessageDetailViewController.swift
//  IBA Members Directory
//
//  Created by George Smith on 15/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import UIKit

protocol MessageDetailDelegate {
    func reloadMessage(_ message: Message)
    func removeMessage()
    func showHideDelete()
}

class MessageDetailViewController: UIViewController {
    
    @IBOutlet var messageDetailsTableView: UITableView!
    @IBOutlet var deleteButton: UIBarButtonItem!
    var message: Message!
    var messageListDelegate: MessageListDelegate!
    var originalFrame: CGRect!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
    }
    
    @IBAction func deleteMessage(_ sender: AnyObject) {
        originalFrame = self.messageDetailsTableView.frame
        UIView.animate(withDuration: 0.15, animations: {
            self.messageDetailsTableView.alpha = 0.0
            self.messageDetailsTableView.frame = CGRect(x: 300, y: 0, width: 0, height: 0)
        }, completion: { (finsihed) in
            self.messageListDelegate.deleteMessage()
            self.messageDetailsTableView.reloadData()
        }) 
    }
    
    @IBAction func moveDown(_ sender: AnyObject) {
        moveMailDown(false)
    }
    
    func moveMailDown(_ delete: Bool) {
        messageListDelegate.moveDown()
    }
    
    @IBAction func moveUp(_ sender: AnyObject) {
        moveMailUp(false)
    }
    
    func moveMailUp(_ delete: Bool) {
        messageListDelegate.moveUp()
    }
    
}

extension MessageDetailViewController: MessageDetailDelegate {
    func reloadMessage(_ message: Message) {
        self.message = message
        self.messageDetailsTableView.alpha = 1.0
        if let frame = originalFrame {
            //Had run animation previous
            self.messageDetailsTableView.frame = frame
        }
        messageDetailsTableView.reloadData()
    }
    
    func showHideDelete() {
        deleteButton.isEnabled = !deleteButton.isEnabled
    }
    
    func removeMessage() {
        originalFrame = self.messageDetailsTableView.frame
        
        UIView.animate(withDuration: 0.15, animations: {
            self.messageDetailsTableView.alpha = 0.0
            self.messageDetailsTableView.frame = CGRect(x: 300, y: 0, width: 0, height: 0)
        }, completion: { (finsihed) in
            self.messageDetailsTableView.reloadData()
        }) 
    }
}

extension MessageDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        messageDetailsTableView.estimatedRowHeight = 100
        messageDetailsTableView.rowHeight = UITableViewAutomaticDimension
        messageDetailsTableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTitleViewCell") as! MessageTitleViewCell
            cell.messageTitle.text = message.title as String
            cell.messageTime.text = message.timeSent.toShortDayString()
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageBodyViewCell") as! MessageBodyViewCell
            cell.messageBody.text = message.text as String
            if message.hasUrl() {
                let rowSpace = tableView.rectForRow(at: IndexPath(row: 0, section: 0))
                let emptySpaceHeight = tableView.frame.size.height - (rowSpace.origin.y + rowSpace.size.height)
                
                cell.messageWebView.alpha = 1
                cell.setupHeightConstraintForWebView(emptySpaceHeight)
                
                let request = URLRequest(url: URL(string: message.url as String)!)
                cell.messageWebView.loadRequest(request)
            } else {
                cell.messageWebView.alpha = 0
                cell.removeHeightConstraint()
            }
            cell.layoutMargins = UIEdgeInsets.zero
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
}
