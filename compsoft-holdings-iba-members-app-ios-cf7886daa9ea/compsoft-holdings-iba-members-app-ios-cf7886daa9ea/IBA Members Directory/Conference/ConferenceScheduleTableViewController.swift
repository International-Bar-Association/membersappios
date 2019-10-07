//
//  ConferenceScheduleTableViewController.swift
//  IBA Members Directory
//
//  Created by George Smith on 15/03/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import UIKit

protocol ConferenceScheduleDelegate {
    func didSelectScheduleItem(event: Event,current: Bool)
    func didDeselectScheduleItem(event: Event)
    func didTapScheduleHeader()
    func didSwipeHeader(wasSwipedUp: Bool)
    func topCellDidChange(cellHeight: CGFloat)
    func eventsListDidUpdate()
}

class ConferenceScheduleTableViewController: UIViewController {
    
    let bubblePresentAnimationController = BubblePresentAnimationController()
    
    var collapseToView: UIView!
    var delegate: ConferenceScheduleDelegate!
    var conference: Conference!
    var profile: MemberProfile!
    var allScheduleItems: [Event]!
    var myScheduleItems: [Event]!
    var arrowIsDown = true
    var justMe = true
    var currentlySelectedIndex: Int! {
        didSet {
            guard currentlySelectedIndex != nil else {
                currentSelectedEventId = nil
                return
            }
            if justMe {
                currentSelectedEventId = myScheduleItems[currentlySelectedIndex].eventId
            } else {
                currentSelectedEventId = allScheduleItems[currentlySelectedIndex].eventId
            }
        }
    }
    var currentSelectedEventId: NSNumber!
    var topConstraint: HeaderTopConstraint! 
      
    
    var isEmbedded = false
    var tableviewFullFrameHeight: CGFloat!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var showEventsView: UIView!
    @IBOutlet var switchLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var eventSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allScheduleItems = []
        myScheduleItems = []
        scheduleTableView.rowHeight = UITableViewAutomaticDimension
        scheduleTableView.estimatedRowHeight = 100
        profile = MemberProfile.getMyProfile()!
        conference = Conference.getConference(id: profile.currentConference as! Int)
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(didTapHeader))
        tapGestureRecogniser.numberOfTapsRequired = 1
        headerView.addGestureRecognizer(tapGestureRecogniser)
        
        let swipeUpGestureRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeHeader(_:)))
        swipeUpGestureRecogniser.direction = .up
        headerView.addGestureRecognizer(swipeUpGestureRecogniser)
        
        let swipeDownGestureRecogniser = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeHeader(_:)))
        swipeDownGestureRecogniser.direction = .down
        headerView.addGestureRecognizer(swipeDownGestureRecogniser)
        reloadScheduleTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        eventSegmentedControl.tintColor = Settings.getConferencePrimaryColour()
        self.navigationController?.navigationBar.tintColor = Settings.getConferencePrimaryColour()
        showEventsView.alpha = 0.0
        if !isEmbedded {
            arrowImage.alpha = 0.0
            
        }
        eventSegmentedControl.selectedSegmentIndex = 1
        self.justMe = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshData()
        scheduleTableView.reloadData()
        tableviewFullFrameHeight = self.scheduleTableView.frame.height
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapHeader() {
        guard delegate != nil else {
            return
        }
        delegate.didTapScheduleHeader()
    }
    
    @objc func didSwipeHeader(_ sender: UISwipeGestureRecognizer) {
        guard delegate != nil else {
            return
        }
        delegate.didSwipeHeader(wasSwipedUp: sender.direction == .up)
    }
    
    //MARK: Do all updates to view based on constraint changes here. 
    func updateView(constraint: HeaderTopConstraint) {
        switch constraint.constraint.constant {
        case constraint.closed:
            UIView.animate(withDuration: 0.5, animations: { 
                self.arrowImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                self.showEventsView.alpha = 1.0
            })
 
            scheduleTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            break
        case constraint.open:
            UIView.animate(withDuration: 0.5, animations: {
                self.arrowImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
                self.showEventsView.alpha = 0.0
                if self.tableviewFullFrameHeight != nil {
                    self.scheduleTableView.frame = CGRect(x: self.scheduleTableView.frame.minX, y: self.scheduleTableView.frame.minY,width: self.scheduleTableView.frame.width, height: self.tableviewFullFrameHeight)
                    self.scheduleTableView.setNeedsDisplay()
                }
                
            })
            
            scheduleTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            break
        case constraint.peak:
            UIView.animate(withDuration: 0.5, animations: {
                self.arrowImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
                self.showEventsView.alpha = 0.0
                 if self.tableviewFullFrameHeight != nil {
                    self.scheduleTableView.frame = CGRect(x: self.scheduleTableView.frame.minX, y: self.scheduleTableView.frame.minY,width: self.scheduleTableView.frame.width, height: constraint.peak - 20 ?? 128)
                    self.scheduleTableView.setNeedsDisplay()
                }
            })
            
            scheduleTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            break
        default:
            break
        }
    }
    
    func getScheduleItems() {
        
        Networking.getConferenceEvents(profile.currentConference as! Int, success: { (conference) in
            
            DispatchQueue.global().async {
                for building in conference.buildings {
                    let build = Building()
                    build.buildingId = building.id as NSNumber?
                    build.buildingName = building.name as NSString?
                    build.conference = self.conference
                    build.floorCount = building.floors.count as NSNumber
                    build.commit()
                    for fl in building.floors {
                        var floor = Floor()
                        floor.buildingId = build.buildingId
                        floor.floorIndex = fl.floorIndex as NSNumber?
                        floor.floorName = fl.name 
                        floor.commit()
                    }
                }
                
                for evRes in conference.events {
                    let event = Event()
                    event.roomId = evRes.roomId as NSNumber?
                    event.startTime = evRes.startTime?.stringToDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ") as NSDate?
                    event.endTime = evRes.endTime?.stringToDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ") as NSDate?
                    event.title = evRes.title as NSString?
                    event.subtitle = evRes.subtitle as NSString?
                    event.conference = self.conference
                    if let id = evRes.buildingId {
                        event.building = Building.getBuilding(for: id)
                    }
                    event.eventId = evRes.eventId as NSNumber?
                    event.attending = evRes.attending as NSNumber?
                    event.roomCentreY = evRes.centreY as NSNumber?
                    event.roomCentreX = evRes.centreX as NSNumber?
                    event.roomName = evRes.roomName as NSString?
                    event.roomId = evRes.roomId as NSNumber?
                    event.floor = evRes.floor as NSNumber?
                    event.lat = evRes.lat as NSNumber?
                    event.long = evRes.long as NSNumber?
                    if event.floor == nil {
                        event.floor = 1
                    }
                    if let bId = evRes.buildingId {
                        event.building = Building.getBuilding(for: bId)
                    }
                    _ = event.createPrettyStringForDate()
                    event.commit()
                    
                }
                self.conference.setClosestNextEvent()
                DispatchQueue.main.async(execute: {
                    
                    self.reloadScheduleTable()
                    if self.currentSelectedEventId == nil {
                        self.scrollToEventClosestToNow()
                    }
                    
                })
            }
        }) { (error) in
            print(error)
        }
    }
    
    func reloadScheduleTable() {
        guard conference != nil else {
            return
        }
        
        allScheduleItems.removeAll()
        myScheduleItems.removeAll()
        
      
        if let events = conference.events() {
            for ev in events {
                if let event = ev as? Event {
                    if event.eventId == currentSelectedEventId {
                        event.status = .selected
                    }
                    allScheduleItems.append(event)
                    if event.attending == 1 {
                        myScheduleItems.append(event)
                    }
                }
            }
        }
        
        delegate.eventsListDidUpdate()
        scheduleTableView.reloadData()
        
    }
    
    func refreshData() {
        getScheduleItems()
    }
    
    func scrollToEventClosestToNow() {
        var events: [Event] = []
        if justMe {
            events = myScheduleItems
        } else {
            events = allScheduleItems
        }
        
        if let ev = events.first(where: { (event) -> Bool in
            return event.status == .now
        }) {
            let cellIndex = events.index(of: ev)
            let indexPath = IndexPath(row: cellIndex!, section: 0)
            scrollToTappedEvent(indexPath: indexPath)
        } else {
            if let ev = events.first(where: { (event) -> Bool in
                return event.status == .scheduledClosest
            }) {
                let cellIndex = events.index(of: ev)
                let indexPath = IndexPath(row: cellIndex!, section: 0)
                scrollToTappedEvent(indexPath: indexPath)
            }
        }
    }
    
    func scrollToTappedEvent(indexPath: IndexPath) {
        scheduleTableView.scrollToRow(at: indexPath , at: .top, animated: true)
        self.delegate.topCellDidChange(cellHeight: scheduleTableView.rectForRow(at: indexPath).height + headerView.frame.height + 10)
    }
    
    @IBAction func eventsSwitched(_ sender: UISegmentedControl) {
        self.justMe = !Bool(truncating: sender.selectedSegmentIndex as NSNumber)
        if currentlySelectedIndex != nil {
            var events: [Event] = []
            if justMe {
                events = allScheduleItems
            } else {
                events = myScheduleItems
            }
            _ = IndexPath(item: currentlySelectedIndex, section: 0)
            events[currentlySelectedIndex].configureState()
        }
        currentlySelectedIndex = nil
        self.scheduleTableView.reloadData()
        scrollToEventClosestToNow()
    }
    
    func userHasOnGoingEvent() -> Bool {
        let date = Date()
        
        let currentEvent = self.myScheduleItems.filter { (event) -> Bool in
            return date.isBetween(date: event.startTime! as Date, andDate: event.endTime! as Date)
        }
        
        return currentEvent.count > 0
    }
    
    func getUserNextEventDateTime() -> NSDate? {
        let myEventsSorted = self.myScheduleItems.map{$0.startTime.timeIntervalSinceNow}.filter{$0 > 0}.sorted(by: <)
        if myEventsSorted.count > 0 {
            return NSDate(timeIntervalSinceNow: myEventsSorted.first! )
        } else {
            return nil
        }
        
    }
    
    func getCurrentOngoingEvent(forUser: Bool) -> Event? {
        let date = Date()
        switch forUser {
        case true:
            let currentEvent = self.myScheduleItems.filter { (event) -> Bool in
                return date.isBetween(date: event.startTime! as Date, andDate: event.endTime! as Date)
            }
            return currentEvent.first
        case false:
            let currentEvent = self.allScheduleItems.filter { (event) -> Bool in
                return date.isBetween(date: event.startTime! as Date, andDate: event.endTime! as Date)
            }
            return currentEvent.first
        }
    }
}

extension ConferenceScheduleTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var event:Event!
        if justMe {
            event = myScheduleItems[indexPath.row]
        } else {
            event = allScheduleItems[indexPath.row]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConferenceScheduleTableViewCell", for: indexPath) as? ConferenceScheduleTableViewCell
        cell?.createItem(event: event)
        cell?.delegate = self
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if justMe {
            return myScheduleItems.count
        } else {
            return allScheduleItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard delegate != nil else {
            return
        }
        
        var events: [Event] = []
        if justMe {
            events = myScheduleItems
        } else {
            events = allScheduleItems
        }
        guard events.count > 0 else {
            return
        }
        events[indexPath.row].status = .selected
        var pathsToReload: [IndexPath]! = []
        pathsToReload.append(indexPath)
        
        if currentlySelectedIndex != nil {
            if currentlySelectedIndex == indexPath.row {
                events[currentlySelectedIndex].configureState()
                
                tableView.reloadRows(at: [IndexPath(item: currentlySelectedIndex, section: 0)], with: .automatic)
                delegate.didDeselectScheduleItem(event: events[currentlySelectedIndex])
                currentlySelectedIndex = nil
                return
            }
            let oldIndexPath = IndexPath(item: currentlySelectedIndex, section: 0)
            events[currentlySelectedIndex].configureState()
            
            pathsToReload.append(oldIndexPath)
        }
        
        tableView.reloadRows(at: pathsToReload, with: .automatic)
        currentlySelectedIndex = indexPath.row
        delegate.didSelectScheduleItem(event: events[indexPath.row], current: false)
        scrollToTappedEvent(indexPath: indexPath)
    }
    
    func selectEvent(event: Event) -> Bool {
        if justMe {
            eventSegmentedControl.selectedSegmentIndex = 1
            eventsSwitched(eventSegmentedControl)
        }
        
        if let index = allScheduleItems.index(where: {$0.eventId == event.eventId}){
            selectRow(at: IndexPath(row: index, section: 0))
        }
        scheduleTableView.reloadData()
        return false
    }
    
    func selectRow(at indexPath:IndexPath){
        self.tableView(self.scheduleTableView, didSelectRowAt: indexPath)
    }
    
}

extension ConferenceScheduleTableViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        bubblePresentAnimationController.originalFrame = appDel.bubbleContainerView.frame
        if let vc = presenting as? ConferenceMenuViewController {
            bubblePresentAnimationController.viewTransforming = vc.scheduleButton
            collapseToView = vc.scheduleButton
        } else {
            bubblePresentAnimationController.viewTransforming = self.view
        }
        
        return bubblePresentAnimationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        bubblePresentAnimationController.dismissing = true
        bubblePresentAnimationController.viewTransforming = collapseToView
        return bubblePresentAnimationController
    }
}

extension ConferenceScheduleTableViewController:EventActionDelegate {
    func didTapGetDirections() {
        
    }
    
    func didTapAddToCalender(event: Event) {
        if !self.conference.hasSeenCalenderAlert {
            self.showAlert(title: "Information", message: "The event times shown here are shown in Rome time (CEST) - your calender will show events relative to your phones saved timezone settings.", okTitle: "Got it!") { (action) in
                ConferenceEventManager.instance.addEventToCalender(cEvent: event, vc: self)
                self.conference._hasSeenCalenderAlert = 1
                self.conference.commit()
            }
        } else {
            ConferenceEventManager.instance.addEventToCalender(cEvent: event, vc: self)
        }
    }
}
