//
//  Conference.swift
//  IBA Members Directory
//
//  Created by George Smith on 20/03/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import Foundation
import ObjectMapper

class Conference: SRKObject {
    
    @objc dynamic var conferenceId : NSNumber!
    @objc dynamic var venue : NSString!
    @objc dynamic var name: NSString!
    @objc dynamic var startDate: NSDate!
    @objc dynamic var endDate: NSDate!
    @objc dynamic var _hasSeenCalenderAlert: NSNumber!
    
    func buildings() -> [Building] {
        let buildings = Building.query().where(withFormat: "conference = %@", withParameters: [self.id]).fetch().compactMap {$0 as? Building }
        return buildings.sorted {$0.isOffsite && !$1.isOffsite}
        
    }
    
    func events() -> SRKResultSet? {
        return Event.query().where(withFormat: "conference = %@", withParameters: [self.id]).order(by: "startTime ASC, title ASC ").fetch()
    }
    
    func myEvents() -> SRKResultSet? {
        return Event.query().where(withFormat: "conference = %@ && attending = 1", withParameters: [self.id]).order(by: "startTime ASC, title ASC ").fetch()
    }
    
    func setClosestNextEvent() {
        if let events = events() as? [Event] {
            
            let futureEvents = events.filter({ (ev) -> Bool in
                return ev.status == .scheduled
            })
            let sortedEvents = futureEvents.sorted(by: { (ev1, ev2) -> Bool in
                return (ev1.startTime as Date) < (ev2.startTime as Date)
            })
            if let closestEvent = sortedEvents.first {
                closestEvent.status = .scheduledClosest
                closestEvent.commit()
            }
        }
        
    }
    
    var hasSeenCalenderAlert: Bool {
        get {
            return _hasSeenCalenderAlert == 1
        }
    }
    
    var isOnNow:Bool {
        get {
            if let confStart = startDate as? Date, let confEnd = endDate as? Date {
                return (confStart < Date() && confEnd > Date())
            }
            return false
        }
    }
    
    override func entityWillInsert() -> Bool {
        if Conference.query().where(withFormat: "conferenceId = %@", withParameters: [self.conferenceId]).fetch().count > 0 {
            if let conferenceToUpdate = Conference.query().where(withFormat: "conferenceId = %@", withParameters: [self.conferenceId]).fetch()[0] as? Conference {
                conferenceToUpdate.venue = self.venue
                conferenceToUpdate.name = self.name
                conferenceToUpdate.startDate = self.startDate
                conferenceToUpdate.endDate = self.endDate
                conferenceToUpdate.commit()
                return false
            }
        }
        return true
    }
    
    static func getConference(id: Int) -> Conference? {
        let result = Conference.query().where(withFormat: "conferenceId = %@", withParameters: [id]).fetch()
        if result!.count > 0 {
            if let res = result![0] as? Conference {
                return res
            }
        }
        return nil
    }
    
    static func getConferenceIfRunning() -> Conference? {
        if let result = Conference.query().order(by: "startDate").fetch().lastObject as? Conference {
            return result
        }
        return nil
    }
}

class Attendee: SRKObject {
    
    @objc dynamic var attendeeId: NSNumber!
    @objc dynamic var firstName: NSString!
    @objc dynamic var lastName: NSString!
    @objc dynamic var firmName: NSString!
    @objc dynamic var profilePicture: NSString!
    @objc dynamic var conference: Conference!
    
    
    static func fromJson(json:[String:Any]) -> Attendee {
        let attendee = Attendee()
        attendee.attendeeId = json["UserId"] as? NSNumber
        attendee.firstName = json["FirstName"] as? NSString
        attendee.lastName = json["LastName"] as? NSString
        attendee.firmName = json["FirmName"] as? NSString
        attendee.profilePicture = json["ProfilePicture"] as? NSString
        return attendee
    }
    
    var profile: MemberProfile? {
        get {
            return MemberProfile.getProfileForAttendee(attendee: self)
        }
    }
    
    static func searchByName(name: String) -> [Attendee] {
        return Attendee.query().where(withFormat: "firstName LIKE %@ OR lastName LIKE %@", withParameters: [makeLikeParameter(name),makeLikeParameter(name)]).fetch().compactMap{ $0 as? Attendee }
    }
    
    static func searchById(id: Int) -> Attendee? {
        let results = Attendee.query().where(withFormat: "attendeeId == %@", withParameters: [id]).fetch().compactMap{ $0 as? Attendee }
        if results.count > 0 {
            return results.first
        } else {
            return nil
        }
    }
    
    static func atendeesExist(conference: Conference) -> Bool {
        if let results = Attendee.query().where(withFormat: "conference == %@", withParameters: [conference]).fetchLightweight() {
            return results.count > 0
        }
        return false
    }
    
    override func entityWillInsert() -> Bool {
        if let existing = Attendee.searchById(id: self.attendeeId as! Int) {
            //NEEDS TO UPDATE INSTEAD
            existing.firstName = self.firstName
            existing.lastName = self.lastName
            existing.firmName = self.firmName
            existing.profilePicture = self.profilePicture
            existing.commit()
            return false
        }
        return true
    }
}

class Building: SRKObject {
    
    @objc dynamic var buildingName: NSString!
    @objc dynamic var buildingId: NSNumber!
    @objc dynamic var conference: Conference!
    @objc dynamic var floorCount: NSNumber!
    
    var isOffsite: Bool {
        get {
            return buildingName == "Offsite" || buildingName == "N/A"
        }
    }
    
    func getEvents() -> [Event]{
        let events = Event.query().where(withFormat: "buildingId=%@", withParameters: [buildingId]).fetch().compactMap{$0 as? Event}
        return events
    }
    
    
    func getFloorPlans() -> [UIImage] {
        guard let count = floorCount as? Int, !self.isOffsite else {
            return []
        }
        var floors: [UIImage] = []
        for i in 0..<count {
            let filename = "\(buildingName!.replacingOccurrences(of: " ", with: ""))" + "-" + "\(i)"
            if let image = UIImage(named: filename) {
                floors.append(image)
            } else {
                assertionFailure("CAN'T FIND MAP")
            }
        }
        
        return floors
    }
    
    func getFloorNames() -> [String] {
        let names = Floor.query().where(withFormat:"buildingId = %@", withParameters: [self.buildingId]).order(by: "floorIndex").fetch().compactMap{$0 as? Floor}.map {$0!.floorName!}
        return names
    }
    
    private var _floors:[UIImage]!
    
    var floors:[UIImage] {
        if _floors == nil {
            _floors = getFloorPlans()
            return _floors
        } else {
            return _floors
        }
    }
    
    static func getBuilding(for id: Int) -> Building? {
        let result = Building.query().where(withFormat: "buildingId=%@", withParameters: [id]).limit(1).fetch().compactMap{ $0 as? Building }
        return result.count > 0 ? result[0] : nil
    }
    
    override func entityWillInsert() -> Bool {
        if let existing = Building.query().where(withFormat: "buildingId=%@", withParameters: [self.buildingId]).limit(1).fetch(), existing.count > 0 , let build = existing[0] as? Building {
            build.buildingName = self.buildingName
            build.floorCount = self.floorCount
            build.commit()
            return false
        }
        return true
    }
}

class Floor: SRKObject {
    @objc dynamic var floorName:String!
    @objc dynamic var floorIndex: NSNumber!
    @objc dynamic var buildingId: NSNumber!
    
    override func entityWillInsert() -> Bool {
        
        let matchingFloors = Floor.query().where(withFormat: "floorIndex = %@ AND buildingId = %@", withParameters: [self.floorIndex, self.buildingId]).fetch()
        if matchingFloors!.count > 0 {
            
            if let floor = matchingFloors?.firstObject as? Floor {
                floor.floorName = self.floorName
                floor.commit()
            }
            return false
        }
        return true
        
    }
}

class Event: SRKObject {
    @objc dynamic var eventId: NSNumber!
    @objc dynamic var conference: Conference!
    @objc dynamic var startTime: NSDate!
    @objc dynamic var endTime: NSDate!
    @objc dynamic var roomId: NSNumber!
    @objc dynamic var eventDescription: NSString!
    @objc dynamic var title: NSString!
    @objc dynamic var subtitle: NSString!
    @objc dynamic var attending: NSNumber!
    @objc dynamic private var _status: NSNumber! = 2
    @objc dynamic var prettyEventTimeString: NSString!
    @objc dynamic var floor: NSNumber!
    @objc dynamic var roomName: NSString!
    @objc dynamic var roomCentreX: NSNumber!
    @objc dynamic var roomCentreY: NSNumber!
    
    @objc dynamic var lat: NSNumber!
    @objc dynamic var long: NSNumber!
    
    @objc dynamic var building: Building!
    
    
    var status: ConferenceScheduleItemState {
        get {
            if _status == nil {
                _status = 2
                self.commit()
            }
            return ConferenceScheduleItemState(rawValue: _status as! Int)!
        }
        set {
            _status = newValue.rawValue as NSNumber?
        }
    }
    
    override func entityWillInsert() -> Bool {
        
        let matchingEvents = Event.query().where(withFormat: "eventId = %@", withParameters: [self.eventId]).fetch()
        if matchingEvents!.count > 0 {
            let event = matchingEvents![0] as! Event
            event.startTime = self.startTime
            event.endTime = self.endTime
            event.attending = self.attending
            event.prettyEventTimeString = self.prettyEventTimeString
            event.conference = self.conference
            event.building = self.building
            event._status = nil
            event.configureState()
            event.eventId = self.eventId
            event.roomName = self.roomName
            event.roomId = self.roomId
            event.roomCentreX = self.roomCentreX
            event.roomCentreY = self.roomCentreY
            event.lat = self.lat
            event.long = self.long
            event.floor = self.floor
            event.commit()
            return false
        } else {
            configureState()
        }
        return true
        
    }
    
    func configureState() {
        let eventStart = startTime as Date
        let eventEnd = endTime as Date
        
        let dateTimeForm = DateFormatter()
        dateTimeForm.dateFormat = "HH:mm"
        dateTimeForm.timeZone =  TimeZone(abbreviation: "UTC")
        
        let newDateTime = dateTimeForm.date(from: Date().toShortConferenceLocalTimeString())!
        let newStartDateTime = dateTimeForm.date(from: eventStart.toShortConferenceTimeString(timezone: "CEST"))!
        let newEndDateTime = dateTimeForm.date(from: eventEnd.toShortConferenceTimeString(timezone: "CEST"))!
        
        let dBetween = daysBetween(eventStart: eventStart)
        switch dBetween {
        case .today:
            guard newStartDateTime < newEndDateTime  else {
                self.status = .finished
                return
            }
            if (newStartDateTime...newEndDateTime).contains(newDateTime) {
                self.status = .now
            } else if newStartDateTime.minutesFrom(newDateTime) > 0 {
                self.status = .scheduled
            } else if newStartDateTime.minutesFrom(newDateTime) < 0 {
                self.status = .finished
            }
        case .tomorrow:
            self.status = .scheduled
        case .future:
            self.status = .scheduled
        case .yesterday:
            self.status = .finished
        default:
            self.status = .finished
        }
        
        return
    }
    
    private func daysBetween(eventStart: Date) -> DaysBetween {
        let date = Date()
        let dateForm = DateFormatter()
        dateForm.dateFormat = "dd/MM/yyyy"
        dateForm.timeZone =  TimeZone(abbreviation: "UTC")
        //NOTE: Strip the time fragment from date
        
        let nowWithNoTime = dateForm.date(from: date.toShortLocalDayString())
        let startWithNoTime = dateForm.date(from: eventStart.toShortDayString())
        guard nowWithNoTime != nil, startWithNoTime != nil else {
            return .wayBack
        }
        
        return DaysBetween(fromInt: startWithNoTime!.daysFrom(nowWithNoTime!))
    }
    
    func createPrettyStringForDate() -> String {
        let start = startTime as Date // Event UTC time
        let end = endTime as Date //Event UTC time
        
        let dBetween = daysBetween(eventStart: start)
        switch dBetween {
        case .today:
            self.prettyEventTimeString = "TODAY " as NSString
        case .tomorrow:
            self.prettyEventTimeString = "TOMORROW " as NSString
        case .yesterday:
            self.prettyEventTimeString = "YESTERDAY " as NSString
        default:
            self.prettyEventTimeString = "\(start.toShortDayString(timezone: "CEST")) " as NSString?
        }
        
        let str = "\(start.toShortConferenceTimeString(timezone: "CEST")) - \(end.toShortConferenceTimeString(timezone: "CEST"))"
        prettyEventTimeString = prettyEventTimeString.appending(str) as NSString?
        return self.prettyEventTimeString as String
        
    }
    
    class func getEventById(id: String) -> Event? {
        if let idNumber = Int(id) {
            let found = Event.query().where(withFormat: "eventId = %@", withParameters: [idNumber]).fetch().compactMap{$0 as? Event}
            return found.first
        }
        return nil
        
    }

}

enum DaysBetween: Int {
    case future = 99
    case today = 0
    case tomorrow = 1
    case yesterday = -1
    case wayBack = -99
    case unknown = -100
    
    init(fromInt: Int) {
        switch fromInt {
        case let x where x > 1:
            self = .future
        case 0:
            self = .today
        case 1:
            self = .tomorrow
        case -1:
            self = .yesterday
        case let x where x < -1:
            self = .wayBack
        default:
            self = .unknown
        }
    }
}

enum ConferenceScheduleItemState: Int {
    case now = 0
    case selected = 1
    case scheduled = 2
    case finished = 3
    case scheduledClosest = 4
    
    func backgroundColourForState() -> UIColor {
        switch self {
        case .now:
            return Settings.getConferencePrimaryColour()
        case .scheduled,.scheduledClosest:
            return UIColor.white
        case .selected:
            return Settings.getSelectedEventColour()
        case .finished:
            return UIColor.white
        }
    }
    
    func headerTextColourForState() -> UIColor {
        switch self {
        case .now:
            return UIColor.white
        case .scheduled,.scheduledClosest:
            return Settings.getConferencePrimaryColour()
        case .selected:
            return UIColor.white
        case .finished:
            return UIColor.black
        }
    }
    
    func bodyTextColourForState() -> UIColor {
        switch self {
        case .now:
            return UIColor.white
        case .scheduled,.scheduledClosest:
            return UIColor.black
        case .selected:
            return UIColor.white
        case .finished:
            return UIColor.black
        }
    }
}
