//
//  MessageListViewController.swift
//  IBA Members Directory
//
//  Created by George Smith on 15/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import UIKit


protocol MessageListDelegate {
    func deleteMessage()
    func moveDown() -> Bool // Returns false when there is no message to move down to.
    func moveUp()
    func reloadMessageList()
}

class MessageListViewController: UIViewController {
    
    @IBOutlet var messagesTableView: UITableView!
    var messages: [MessageListProtocol]!
    var selectedIndex = 0
    var refreshControl: UIRefreshControl!
    var messageDetailDelegate: MessageDetailDelegate!
    var messageThreadDelegate : P2PMessageThreadDelegate!
    var arrivedFromPush: Bool = false // re-used for navigating from profile
    var messageIdFromPush:Int = 0
    
    @IBOutlet var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        messagesTableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        messages = [Message]()
        addPullToRefresh()
        
        refreshTableData()
        getAllMessages()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {

        Settings.setBadgeAmount(0)
        
        refreshTableData()
        getAllMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if  !splitViewController!.isCollapsed {
            P2PMessageThread.CheckForEmptyThreadsAndRemoveThem()
            self.reloadMessageList()
        }
    }
    
    @IBAction func editButtonHit(_ sender: AnyObject) {
        //Crashlytics.sharedInstance().crash()
        if editButton.tag == 0 {
           messagesTableView.setEditing(true, animated: true)
            editButton.title = "Done"
            editButton.tag = 1
        } else {
            messagesTableView.setEditing(false, animated: true)
            editButton.title = "Edit"
            editButton.tag = 0
        }
    }
    
    func viewAppearFromPush(isP2P: Bool) {
        if arrivedFromPush {
            arrivedFromPush = false
            showPushedMessage(isP2P: isP2P)
            if messagesTableView != nil {
                messagesTableView.reloadData()
            }
        }
    }
    
    func showPushedMessage(isP2P: Bool) {
        if !isP2P {
            if let message = DataProvider.getMessageById(messageIdFromPush) {
                getAllMessages()
                message.setHasRead()
                messagesTableView.reloadData()
                self.performSegue(withIdentifier: "showMessageDetailSegue", sender: message)
            } else {
                Networking.getMessage(messageIdFromPush, success: { (results) in
                    
                    guard let message = Message.createAndGetMessagesFromMessageResponseModel(results) else {
                        return
                    }
                    message.setHasRead()
                    self.messagesTableView.reloadData()
                    self.messages.insert(message, at: 0)
                    self.messagesTableView.reloadData()
                    self.performSegue(withIdentifier: "showMessageDetailSegue", sender: message)
                    
                }) { (error) in
                    
                }
            }
        } else {
            
        }
       
    }
    
    @objc func getAllMessages() {
        var requestMadeCount = 0
        
        
        Networking.getMessages("", success: { (results) in
            requestMadeCount += 1
            print(results)
            Message.createMessagesFromMessageResponseModel(results)
            if requestMadeCount == 1 {
                self.endGetAllMessages(success: true)
            }
            
        }) { (error) in
            if requestMadeCount == 1 {
                self.endGetAllMessages(success: false)
            }
        }
        
    }
    
    func endGetAllMessages(success: Bool) {
        if success {
            self.refreshTableData()
            if !self.arrivedFromPush {
                self.selectFirstCellIfDetailViewShowing()
            }
        } else {
            self.refreshControl.endRefreshing()
        }
    }
    
    func refreshTableData() {
        messages = DataProvider.getCmsMessages()!
        refreshControl.endRefreshing()
        if messages.count == 0 {
            
        }
        

        self.messagesTableView.reloadData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showMessageDetailSegue"
        {

            //the destinationViewController is a UINavigationController for iOS 8 and is the ProfileViewController for iOS7 - so check class before using to prevent crash.
            let destinationViewController: UIViewController = segue.destination
            var messageDetailViewController : MessageDetailViewController!
            
            if destinationViewController.isKind(of: UINavigationController.self)
            {
                let navController = destinationViewController as! ContentNavController
                let contentStoryboard = UIStoryboard(name: "ContentMessagesStoryboard", bundle: nil)
                messageDetailViewController = contentStoryboard.instantiateViewController(withIdentifier: "MessgesViewController") as! MessageDetailViewController
                navController.setViewControllers([messageDetailViewController], animated: false)
            }
            else if destinationViewController.isKind(of: MessageDetailViewController.self)
            {
                messageDetailViewController = destinationViewController as! MessageDetailViewController
            }
            
            if messageDetailViewController != nil
            {
                if let message : Message = messages![selectedIndex] as? Message {
                    messageDetailViewController.message = message
                }
                
                if let pushMessage = sender as? Message {
                    messageDetailViewController.message = pushMessage
                }

                messageDetailViewController.messageListDelegate = self
                messageDetailDelegate = messageDetailViewController
                
            }
        } else if segue.identifier == "showP2PMessageDetailSegue" {
            //the destinationViewController is a UINavigationController for iOS 8 and is the ProfileViewController for iOS7 - so check class before using to prevent crash.
            guard let messageThread = messages[selectedIndex] as? P2PMessageThread else {
                return
            }
            
            
            let destinationViewController: UIViewController = segue.destination
            var messageDetailViewController : P2PMessagesContainingViewController!
            
            if destinationViewController.isKind(of: UINavigationController.self)
            {
                let navController = destinationViewController as! ContentNavController
                let contentStoryboard = UIStoryboard(name: "ContentMessagesStoryboard", bundle: nil)
                messageDetailViewController = contentStoryboard.instantiateViewController(withIdentifier: "P2PMessagesViewController") as! P2PMessagesContainingViewController
                messageDetailViewController.messageThread = messageThread
                navController.setViewControllers([messageDetailViewController], animated: false)
            }
            else if destinationViewController.isKind(of: P2PMessagesContainingViewController.self)
            {
                messageDetailViewController = destinationViewController as! P2PMessagesContainingViewController
            }
            
            if let splitView = self.parent?.parent as? UISplitViewController {
                
                messageDetailViewController.isMessageListVisible = !splitView.isCollapsed
                
            }
            
            if messageDetailViewController != nil
            {
                //Pass what needs to be passed to view
                
                messageDetailViewController.messageThread = messageThread
                messageDetailViewController.messageListDelegate = self
                self.messageThreadDelegate = messageDetailViewController
            }

        } else if segue.identifier == "showNoMessageViewController" {
            let navVc = segue.destination as! UINavigationController
            let vc = navVc.childViewControllers[0] as! NoContentMessagesViewController
            vc.labelText = "No Messages"
        }
    }
    
    func selectFirstCellIfDetailViewShowing()
    {
        //only perform segue if both views on screen
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            return
        }
        if messages != nil && messages!.count > 0
        {
            let firstIndexPath = IndexPath(row: 0, section: 0)
            if messages[firstIndexPath.row] is Message {
                if let cell = messagesTableView.cellForRow(at: firstIndexPath) {
                    selectedIndex = 0
                    performSegue(withIdentifier: "showMessageDetailSegue", sender: cell)
                }
            } else if messages[firstIndexPath.row] is P2PMessageThread {
                if let cell = messagesTableView.cellForRow(at: firstIndexPath) {
                    selectedIndex = 0
                    performSegue(withIdentifier: "showP2PMessageDetailSegue", sender: cell)
                }
            }
            messagesTableView.selectRow(at: firstIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
            
        }
        else
        {
            performSegue(withIdentifier: "showNoMessageViewController", sender: self)

        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.resetMessagesView()
    }
    
    func resetMessagesView() {
        guard messagesTableView != nil else {
            return
        }
        let lastIndexPath = IndexPath(item: selectedIndex, section: 0)
        tableView(messagesTableView, didSelectRowAt: lastIndexPath)

    }
}

extension MessageListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func addPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull To Refresh")
        refreshControl.addTarget(self, action: #selector(getAllMessages), for: .valueChanged)
        messagesTableView.addSubview(refreshControl)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let m = messages[indexPath.row]
        
        if let message = m as? Message {
            let cell : MessageViewCell = tableView.dequeueReusableCell(withIdentifier: "MessageViewCell") as! MessageViewCell
            cell.createFromMessage(message)
            return cell
        } else if let p2pMessage = m as? P2PMessageThread {
            let cell : P2PMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "P2PMessageTableViewCell") as! P2PMessageTableViewCell
            var mes = p2pMessage as MessageListProtocol
            cell.createFromMessage(&mes)
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? MessageViewCell {
            selectedIndex = indexPath.row
            messages[selectedIndex].setHasRead()
            cell.setRead()
            if let contentDetail = navigationController?.visibleViewController as? MessageDetailViewController {
                let messageProto = messages[selectedIndex]
                if let message = messageProto as? Message {
                    contentDetail.message = message
                }
                contentDetail.messageDetailsTableView.reloadData()
            } else {
                performSegue(withIdentifier: "showMessageDetailSegue", sender: cell)
            }
        } else if let cell = tableView.cellForRow(at: indexPath) as? P2PMessageTableViewCell {
            selectedIndex = indexPath.row
            messages[selectedIndex].setHasRead()
            
            if let contentDetail =  navigationController?.visibleViewController as? P2PMessagesContainingViewController {
                let messageProto = messages[selectedIndex]
                if messageProto is P2PMessageThread {
                    contentDetail.changeMessageThread(messageThread: messageProto as! P2PMessageThread)
                }
            } else {
                performSegue(withIdentifier: "showP2PMessageDetailSegue", sender: cell)
            }

        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            deleteMessageByIndexPath(indexPath)
            if messageDetailDelegate != nil {
                messageDetailDelegate.removeMessage()
            }
            
            break
        default:
            break
        }
    }
    
}

extension MessageListViewController: MessageListDelegate {

    func deleteMessage() {
        let selectedIndexPath = IndexPath(row: selectedIndex, section: 0)
        deleteMessageByIndexPath(selectedIndexPath)
        self.reloadMessageList()
        
    }
    
    func deleteMessageByIndexPath(_ selectedIndexPath: IndexPath)
    {
        if selectedIndexPath.row < messages.count {
            messages[selectedIndexPath.row].deleteMessage()
            messages.remove(at: (selectedIndexPath.row))
            messagesTableView.reloadData()
            if let cell = messagesTableView.cellForRow(at: selectedIndexPath) {
                cell.setSelected(true, animated: true)
                selectedIndex = selectedIndexPath.row
                
            } else {
                if let cell = messagesTableView.cellForRow(at: IndexPath(row: selectedIndexPath.row - 1, section: 0)){
                    cell.setSelected(true, animated: false)
                    selectedIndex = selectedIndexPath.row - 1
                }
            }
            if messageDetailDelegate != nil {
                if messages.count > 0 {
                    let messageProto = messages[selectedIndex]
                    if let message = messageProto as? Message {
                         messageDetailDelegate.reloadMessage(message)
                    }
                } else {
                    messageDetailDelegate.showHideDelete()
                }
            }
        }
    }
    
    func moveUp() {
        let selectedIndexPath = IndexPath(row: selectedIndex, section: 0)
        if selectedIndexPath.row > 0 && messages.count > 0 {
            let oldSelection = messagesTableView.cellForRow(at: selectedIndexPath)
            oldSelection?.setSelected(false, animated: true)
            selectedIndex -= 1
            let indexPath = IndexPath(row: selectedIndex, section: 0)
            messagesTableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            tableView(messagesTableView, didSelectRowAt: indexPath)
        }
    }
    
    func moveDown() -> Bool {
        let selectedIndexPath = IndexPath(row: selectedIndex, section: 0)
        if selectedIndexPath.row < messages.count - 1 {
            let oldSelection = messagesTableView.cellForRow(at: selectedIndexPath)
            oldSelection?.setSelected(false, animated: true)
            selectedIndex += 1
            let indexPath = IndexPath(row: selectedIndex, section: 0)
            messagesTableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            tableView(messagesTableView, didSelectRowAt: indexPath)
            return true

        } else {
            return false
        }
    }
    
    func reloadMessageList() {
        self.getAllMessages()
    }
}
