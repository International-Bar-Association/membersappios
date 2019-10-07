//
//  ConferenceMessagingViewController.swift
//  IBA Members Directory
//
//  Created by George Smith on 02/08/2018.
//  Copyright © 2018 Compsoft plc. All rights reserved.
//

import Foundation

//HINT: Using alot of KVO here to style the SearchBar - if there is issues here check those first

class ConferenceMessagingViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchContainerViewHeightConstraint: NSLayoutConstraint!
    
    var selectedIndex: Int!
    var threads: [P2PMessageThread]! = []
    
    //NOTE: Nasty old searchViewController code.
    var embeddedSearch: SearchViewController!
    var currentSearchMaxHeight : CGFloat!
    var searchIsAnimating = false
    var tableTopConstraintOriginalValue: CGFloat!
    var searchPanelIsOpen: Bool {
        return self.searchContainerViewHeightConstraint.constant != 44
    }
    
    var manager: TableViewManager! {
        didSet {
            self.navigationItem.setLeftBarButton(self.manager.getLeftBarButtonItemForState(selector: #selector(ConferenceMessagingViewController.didHitLeftBarButton), target: self), animated: true)
            if let searchBar = self.embeddedSearch.searchButton {
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    searchBar.backgroundColor = self.manager.searchBarColour
                })
            }
        }
    }
    
    var searchJobs: [DispatchWorkItem]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = UIColor.white
        reloadData()
        
        refreshConnections()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshConnections), name: NSNotification.Name(rawValue: "P2PMessageReceived"), object: nil)

        let searchGR = UIPanGestureRecognizer(target: self, action: #selector(SearchResultsViewController.searchButtonMoved(_:)))
        searchGR.delegate = self
        embeddedSearch.searchButton.addGestureRecognizer(searchGR)
    }
    

    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func viewAppearFromPush(messageId: Int) {
        
        if let existingThread = threads.first(where: { (thread) -> Bool in
            return thread.threadId == (messageId as NSNumber)
        }) {
            performSegue(withIdentifier: "ShowP2PMessageThread", sender: existingThread)
        } else {
            //NOTE: Need to download the thread to use
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(ConferenceMessagingViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConferenceMessagingViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        setupView()
        reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchJobs.forEach { (item) in
            item.cancel()
        }
        Settings.setBadgeP2PAmount(0)
    }
    
    @objc func didHitLeftBarButton() {
        switch self.manager! {
        case .empty(let isSearching):
            if isSearching {
                
                if threads.count > 0 {
                    manager = TableViewManager.messages(threads: threads)
                } else {
                    manager = TableViewManager.empty(isSearching: false)
                }
                tableview.reloadData()
            } else {
                closeHit(self)
            }
        case .directory:
            reloadThreads()
            manager = TableViewManager.messages(threads: threads)
            tableview.reloadData()
            return
        case .messages:
            closeHit(self)
        case .searchPanel:
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.embeddedSearch.searchButton.backgroundColor = self.embeddedSearch.searchType.searchButtonActiveColor
                self.searchContainerViewHeightConstraint.constant = 44
                self.view.layoutIfNeeded()
            })
            if threads.count > 0 {
                reloadThreads()
                manager = TableViewManager.messages(threads: threads)
            } else {
                manager = TableViewManager.empty(isSearching: false)
            }
            reloadData()
        case .loading:
            
            searchJobs.forEach { (item) in
                //Cancel previous searches
                item.cancel()
            }
            if threads.count > 0 {
                manager = TableViewManager.messages(threads: threads)
            } else {
                manager = TableViewManager.empty(isSearching: false)
            }
            
            tableview.reloadData()
            return
        }
    }
    
    
    func reloadThreads() {
         threads = P2PMessageThread.getThreads()
    }
    
    func reloadData() {
        
    
       reloadThreads()
        
        guard manager == .messages(threads: []) || manager == nil else {
            return
        }
        if threads.count > 0 {
            manager = TableViewManager.messages(threads: threads)
        } else {
            manager = TableViewManager.empty(isSearching: false)
        }
        tableview.reloadData()
    }
    
    @objc func refreshConnections() {
        
        Networking.getP2PMessageConnections(success: { (threads) in
            
            for t in threads {
                
                var newThread = P2PMessageThread()
                let currentThreads = P2PMessageThread.query().where(withFormat: "threadId = %@", withParameters: [t.userId!]).fetch()
                if currentThreads!.count > 0 {
                    newThread = currentThreads![0] as! P2PMessageThread
                    newThread.imageURLString = t.userProfileImageUrl as NSString?
                } else {
                    newThread.imageURLString = t.userProfileImageUrl as NSString?
                    newThread.threadId = t.userId as NSNumber?
                    newThread.title = t.name as NSString?
                    newThread.senderId = t.userId as NSNumber?
                    newThread.commit()
                }
                
                let latestMessage = P2PMessage()
                latestMessage.messageBody = t.lastMessage!.message as NSString?
                latestMessage.messageId = t.lastMessage!.messageId as NSNumber?
                latestMessage.messageThread = newThread
                latestMessage.sentByMe = t.lastMessage?.sentByMe as NSNumber?
                newThread.text = latestMessage.messageBody
                
                if let sentTime = t.lastMessage?.sentTime {
                    latestMessage.sentTime = sentTime.stringToDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                    if latestMessage.sentByMe == 0 {
                        latestMessage.messageThread.messageStatus = .unread
                    } else {
                        latestMessage.messageThread.messageStatus = .read
                    }
                    
                    newThread.timeSent = latestMessage.sentTime!
                }
                
                if let readTime = t.lastMessage!.readTime {
                    latestMessage.readTime = readTime.stringToDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                    latestMessage.messageThread.messageStatus = .read
                }
                
                latestMessage.messageThread.commit()
                latestMessage.commit()
                
            }
            self.reloadData()
            
        }) { (error) in
            debugPrint("Failed to get the p2p connections.")
        }
        
    }
    
    func setupView(){
        currentSearchMaxHeight = view.frame.height
        self.navigationController?.navigationBar.barTintColor = Settings.getConferencePrimaryColour()
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowP2PMessageThread" {
            //the destinationViewController is a UINavigationController for iOS 8 and is the ProfileViewController for iOS7 - so check class before using to prevent crash.
            
            var thread: P2PMessageThread!
            
            if let pthread = sender as? P2PMessageThread {
                thread = pthread
            }
            
            let destinationViewController: UIViewController = segue.destination
            var messageDetailViewController : P2PMessagesContainingViewController!
            
            if destinationViewController.isKind(of: UINavigationController.self)
            {
                let navController = destinationViewController as! ContentNavController
                let contentStoryboard = UIStoryboard(name: "ContentMessagesStoryboard", bundle: nil)
                messageDetailViewController = contentStoryboard.instantiateViewController(withIdentifier: "P2PMessagesViewController") as! P2PMessagesContainingViewController
                messageDetailViewController.messageThread = thread
                navController.navigationBar.barTintColor = Settings.getConferencePrimaryColour()
                navController.setViewControllers([messageDetailViewController], animated: false)
                navController.setNavigationBarHidden(false, animated: true)
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
                
                messageDetailViewController.messageThread = thread
                messageDetailViewController.messageListDelegate = self
                
                //self.messageThreadDelegate = messageDetailViewController
            }
            
        } else if segue.identifier == "showNoMessageViewController" {
            let navVc = segue.destination as! UINavigationController
            let vc = navVc.childViewControllers[0] as! NoContentMessagesViewController
            vc.labelText = "No Messages"
        } else if segue.identifier == "embeddedSearch" {
            embeddedSearch = segue.destination as! SearchViewController
            embeddedSearch.searchType = SearchType.conferenceProfile
            embeddedSearch.delegate = self
        }
    }
    
    @IBAction func closeHit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ConferenceMessagingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard manager! != .searchPanel else {
            debugPrint("Can't deque cell for search panel is open")
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: manager.identifierForRow(), for: indexPath)
        
        if let directoryCell = cell as? ConferenceDirectorySearchTableViewCell {
            if let attendee = manager.attendeeForRow(indexPath: indexPath) {
                directoryCell.setup(attendee: attendee, delegate: self)
            }
            
            return directoryCell
        }
        
        if let messageCell = cell as? ConferenceP2PMessageTableViewCell {
            
            var mes = threads[indexPath.row] as MessageListProtocol
            messageCell.createFromMessage(&mes)
            return messageCell
        }
        
        if let noContentCell = cell as? ConferenceNoFoundEntriesTableViewCell {
            if let type = manager.emptyStateType {
                noContentCell.setup(type: type)
            }
            
            return noContentCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return manager.heightForRow(indexPath: indexPath, tableViewHeight: tableView.frame.height)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        
        if manager.identifierForRow() == "ConferenceDirectorySearchTableViewCell" {
            guard let attendee = manager.currentData[indexPath.row] as? Attendee else {
                return
            }
            let newThread = self.createNewThread(attendee)
            performSegue(withIdentifier: "ShowP2PMessageThread", sender: newThread)
        } else if manager.identifierForRow() == "ConferenceP2PMessageTableViewCell" {
            let thread = self.threads[indexPath.row]
            selectedIndex = indexPath.row
            performSegue(withIdentifier: "ShowP2PMessageThread", sender: thread)
        }
    }
    
    func createNewThread(_ attendee: Attendee) -> P2PMessageThread? {
        
        var _P2PMessageThread = P2PMessageThread()
        if let existingThread = P2PMessageThread.getById(threadId: attendee.attendeeId) {
            _P2PMessageThread = existingThread
        }else {
            _P2PMessageThread.threadId = attendee.attendeeId
            _P2PMessageThread.senderId = MemberProfile.getMyProfile()?.id
            _P2PMessageThread.title = "\(attendee.firstName!) \(attendee.lastName!)"  as NSString
            _P2PMessageThread.imageURLString = attendee.profilePicture
            
        }
        return _P2PMessageThread
    }
}

extension ConferenceMessagingViewController: MessageListDelegate, ViewProfileDelegate {
    func didWantToViewProfile(memberId: NSNumber) {
        debugPrint("View Profile: \(memberId)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if self.view.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact {
            //Use storyboard intended for iPhone originally.
            let navController = storyboard.instantiateViewController(withIdentifier: "navPro-iPhone") as! UINavigationController
            let vc = navController.viewControllers[0] as! ProfileViewController
            
            let tempProfile = MemberProfile() // Causes profile view to download profile
            tempProfile.userId = memberId
            vc.currentProfile = tempProfile
            
            vc.shouldShowClose = true
            vc.profileDisplayType = .directoryProfile
            self.present(navController, animated: true, completion: nil)
            
        } else {
            
            
            let navController = storyboard.instantiateViewController(withIdentifier: "navPro") as! UINavigationController
            let vc = navController.viewControllers[0] as! ProfileViewController

            let tempProfile = MemberProfile() // Causes profile view to download profile
            tempProfile.userId = memberId
            vc.currentProfile = tempProfile

            vc.shouldShowClose = true
            vc.profileDisplayType = .directoryProfile
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    func deleteMessage() {
        reloadMessageList()
    }
    
    func moveDown() -> Bool {
        return false
    }
    
    func moveUp() {
        
    }
    
    func reloadMessageList() {
        reloadData()
    }
    
    
}

extension ConferenceMessagingViewController: SearchDelegate, UIGestureRecognizerDelegate {
    func searchButtonPressed(_ firstName: String?, lastName: String?, firmName: NSString?, city: String?, country: String?, committee: NSNumber?, areaOfPractice: NSNumber?, conference: Bool) {
        
        if self.searchContainerViewHeightConstraint.constant == 44
        {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.searchContainerViewHeightConstraint.constant = self.currentSearchMaxHeight
                self.view.layoutIfNeeded()
            })
            self.manager = TableViewManager.searchPanel
            
            return
        }
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.embeddedSearch.searchButton.backgroundColor = self.embeddedSearch.searchType.searchButtonActiveColor
            self.searchContainerViewHeightConstraint.constant = 44
            self.view.layoutIfNeeded()
        })
        
        searchJobs.forEach { (item) in
            //Cancel previous searches
            item.cancel()
        }
        var searchJob: DispatchWorkItem!
        
        searchJob = DispatchWorkItem{ Networking.getAttendeesWithSearchParameters(firstName, lastName: lastName, firmName: firmName, city: city, country: country != nil ? country!.encryptCountryString() : nil, committee: committee, areaOfPractice: areaOfPractice, conference: conference,take:10,skip:0, completion: {memberProfileArray, wasSuccess in
            guard !searchJob.isCancelled else {
                return
            }
            self.reloadViewWithSearchResults(memberProfileArray, successful: wasSuccess)
        })}
        
        searchJobs.append(searchJob)
        
        DispatchQueue.global(qos: .userInteractive).async(execute: searchJob)
        
        self.manager = .loading
        self.tableview.reloadData()
    }
    
    func reloadViewWithSearchResults(_ updatedMemberArray: [Attendee]?, successful:Bool)
    {
        if !successful || updatedMemberArray == nil || updatedMemberArray?.count == 0 {
            DispatchQueue.main.async {
                self.manager = TableViewManager.empty(isSearching: true)
                self.tableview.reloadData()
            }
        } else {
            //NOTE Must be a success
            DispatchQueue.main.async {
                self.manager = TableViewManager.directory(users: updatedMemberArray!)
                self.tableview.reloadData()
            }
        }
    }
    
    //MARK: Keyboard notification methods
    @objc func keyboardWillShow(_ notification: Notification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        var keyboardHeight : CGFloat!
        if !UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) && (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)
        {
            keyboardHeight = keyboardFrame.width
        }
        else
        {
            keyboardHeight = keyboardFrame.height
        }
        
        let visibileAreaHeight = view.frame.height - keyboardHeight
        
        currentSearchMaxHeight = visibileAreaHeight
        if searchContainerViewHeightConstraint.constant > visibileAreaHeight
        {
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.searchContainerViewHeightConstraint.constant = self.currentSearchMaxHeight
                self.view.layoutIfNeeded()
                self.view.updateConstraints()
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let previousSearchMaxHeight = currentSearchMaxHeight
        currentSearchMaxHeight = view.frame.height
        
        if !searchIsAnimating && searchContainerViewHeightConstraint.constant == previousSearchMaxHeight
        {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.searchContainerViewHeightConstraint.constant = self.currentSearchMaxHeight
                self.view.layoutIfNeeded()
                self.view.updateConstraints()
            })
        }
    }
    
    //MARK: Search view methods
    @objc func searchButtonMoved(_ gestureRecognizer: UIPanGestureRecognizer)   {
        
        embeddedSearch.view.endEditing(true)
        
        if gestureRecognizer.state == UIGestureRecognizerState.began
        {
            embeddedSearch.searchScrollView.isScrollEnabled = false
        }
        else if gestureRecognizer.state == UIGestureRecognizerState.ended
        {
            embeddedSearch.searchScrollView.isScrollEnabled = true
        }
        let velocity = gestureRecognizer.velocity(in: self.view)
        if(velocity.y > 0)
        {
            searchIsAnimating = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.searchContainerViewHeightConstraint.constant = self.currentSearchMaxHeight
                self.view.layoutIfNeeded()
            }, completion: { (completed) -> Void in
                self.searchIsAnimating = false
                
            })
        }
        else
        {
            
            if gestureRecognizer.state == UIGestureRecognizerState.began
            {
                self.embeddedSearch.touchUpSearch(self.embeddedSearch.searchButton)
            }
            
        }
    }
}

extension ConferenceMessagingViewController {
    enum TableViewManager: Equatable {
        
        static func ==(lhs: TableViewManager, rhs: TableViewManager) -> Bool {
            switch (lhs, rhs) {
            case (.directory, .directory):
                return true
            case (.messages, .messages):
                return true
            case (.empty, .empty):
                return true
            case (.loading, .loading):
                return true
            default: return false
            }
        }
        
        case directory(users: [Attendee])
        case messages(threads: [P2PMessageThread])
        case searchPanel
        case empty(isSearching: Bool)
        case loading
        
        var numberOfRows: Int {
            get {
                switch self {
                case .directory(let users):
                    return users.count
                case .messages(let threads):
                    return threads.count
                case .empty,.loading:
                    return 1
                case .searchPanel:
                    return 0
                }
            }
        }
        
        var searchBarColour: UIColor {
            switch self {
            case .directory:
                return SearchType.conferenceProfile.searchButtonActiveColor
            case .loading:
                return SearchType.conferenceProfile.searchButtonActiveColor
            case .empty(let isSearching):
                if isSearching {
                    return SearchType.conferenceProfile.searchButtonActiveColor
                } else {
                    return SearchType.conferenceProfile.searchButtonColour
                }
            case .messages:
                return SearchType.conferenceProfile.searchButtonColour
            case .searchPanel:
                return SearchType.conferenceProfile.searchButtonActiveColor
            }
        }
        
        func identifierForRow() -> String {
            switch self {
            case .directory:
                return "ConferenceDirectorySearchTableViewCell"
            case .messages:
                return "ConferenceP2PMessageTableViewCell"
            case .empty:
                return "NoMessagesTableViewCell"
            case .loading:
                return "LoadingTableViewCell"
            case .searchPanel:
                return ""
                
            }
        }
        
        func heightForRow(indexPath: IndexPath,tableViewHeight: CGFloat) -> CGFloat {
            switch self {
            case .directory:
                return 128
            case .messages:
                return 128
            case .empty,.loading:
                return tableViewHeight
            case .searchPanel:
                return 0
            }
        }
        
        var currentData:[Any] {
            get {
                switch self {
                case .directory(let users):
                    return users
                case .messages(let threads):
                    return threads
                case .loading:
                    return []
                case .empty:
                    return []
                case .searchPanel:
                    return []
                }
            }
        }
        
        var showNavbar: Bool {
            get {
                return true
            }
        }
        
        func getLeftBarButtonItemForState(selector: Selector?,target: Any) -> UIBarButtonItem {
            switch self {
            case .empty(let isSearching):
                if isSearching {
                    return UIBarButtonItem(title: "Cancel", style: .done, target: target, action: selector)
                } else {
                    return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: target, action: selector)
                }
            case .messages:
                return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: target, action: selector)
            case .directory,.loading:
                return UIBarButtonItem(title: "Cancel", style: .done, target: target, action: selector)
            case .searchPanel:
                return UIBarButtonItem(title: "Cancel", style: .done, target: target, action: selector)
            }
        }
        
        var emptyStateType: ConferenceNoFoundEntriesTableViewCell.EntryType? {
            switch self {
            case .empty(let isSearching):
                return isSearching ? ConferenceNoFoundEntriesTableViewCell.EntryType.directory : ConferenceNoFoundEntriesTableViewCell.EntryType.threads
            default:
                return nil
            }
        }
        
        func attendeeForRow(indexPath: IndexPath) -> Attendee? {
            switch self {
            case .directory(let users):
                guard users.count > indexPath.row else {
                    return nil
                }
                return users[indexPath.row]
            default:
                return nil
            }
        }
        
    }
}
