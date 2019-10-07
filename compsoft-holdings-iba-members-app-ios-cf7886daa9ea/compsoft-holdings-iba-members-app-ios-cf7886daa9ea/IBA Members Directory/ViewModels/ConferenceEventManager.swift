//
//  ConferenceEventVIewModel.swift
//  IBA Members Directory
//
//  Created by George Smith on 02/08/2018.
//  Copyright © 2018 Compsoft plc. All rights reserved.
//

import Foundation
import EventKit
import EventKitUI

//NOTE: This class is to manage event actions i.e sharing, get directions.

public class ConferenceEventManager: NSObject {
    
    static let instance: ConferenceEventManager = ConferenceEventManager()
    
    let eventStore : EKEventStore = EKEventStore()
    var selectedCalender: Set<EKCalendar>!
    var currentEvent: EKEvent!
    
    
    func presentChoseCalanders(viewController: UIViewController) {
        let eventStore : EKEventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) { (granted, error) in
            
            if (granted) && (error == nil) {
                let chooser = EKCalendarChooser(selectionStyle: EKCalendarChooserSelectionStyle.multiple, displayStyle: EKCalendarChooserDisplayStyle.writableCalendarsOnly, entityType: EKEntityType.event, eventStore: self.eventStore)
                chooser.delegate = self
                chooser.showsDoneButton = true
                chooser.showsCancelButton = true
                chooser.selectedCalendars = Set<EKCalendar>()
                let navVc = UINavigationController(rootViewController: chooser)
                navVc.navigationBar.barStyle = .black
                navVc.navigationBar.barTintColor = Settings.getConferencePrimaryColour()
                navVc.navigationBar.tintColor = UIColor.white
                DispatchQueue.main.async {
                    viewController.present(navVc, animated: true)
                }
            } else {
                debugPrint("Unable to get access to calenders")
            }
        }
    }
    
    func addEventToCalender(cEvent: Event, vc: UIViewController) {
        
        
        eventStore.requestAccess(to: .event) { (granted, error) in
            
            if (granted) && (error == nil) {
                self.currentEvent = EKEvent(eventStore: self.eventStore)
                self.currentEvent.title = "\(cEvent.title!) at \(cEvent.building.buildingName!)"
                self.currentEvent.startDate = cEvent.startTime as Date
                self.currentEvent.endDate = cEvent.endTime as Date
                self.currentEvent.notes = Environment().baseURL + "Applinks/ViewEvent?id=\(cEvent.eventId!)"
                self.presentChoseCalanders(viewController: vc)
            }
            else{

            }
        }
    }
    
    func getDirectionsToEvent(event: Event) {
        
    }
}


extension ConferenceEventManager: EKCalendarChooserDelegate {
    
    public func calendarChooserDidFinish(_ calendarChooser: EKCalendarChooser) {
        selectedCalender = calendarChooser.selectedCalendars
        for cal in selectedCalender {
            do {
                currentEvent.calendar = cal
                try eventStore.save(currentEvent, span: .thisEvent)
            } catch let error as NSError {
                print("failed to save event with error : \(error)")
            }
        }
        calendarChooser.dismiss(animated: true, completion: nil)
    }
    
    public func calendarChooserSelectionDidChange(_ calendarChooser: EKCalendarChooser) {
        debugPrint("didChange")
    }
    
    public func calendarChooserDidCancel(_ calendarChooser: EKCalendarChooser) {
        selectedCalender = nil
        calendarChooser.dismiss(animated: true, completion: nil)
    }
}
