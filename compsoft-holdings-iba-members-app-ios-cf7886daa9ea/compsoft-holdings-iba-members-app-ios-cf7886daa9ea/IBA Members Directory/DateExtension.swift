//
//  DateExtension.swift
//  IBA Members Directory
//
//  Created by George Smith on 02/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import Foundation

extension Date {
    
    func utcToLocal() -> Date {
        let dtf = DateFormatter()
        dtf.timeZone = TimeZone.current
        dtf.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dtStr = dtf.string(from: self)
        
       
         return dtf.date(from: dtStr)!
    }
    
    func yearsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    func monthsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    func weeksFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    func daysFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    func hoursFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    func minutesFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    func secondsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    
    func offsetFrom(_ date:Date) -> String {
        var currentDate = date.utcToLocal()
        if yearsFrom(currentDate)   > 0 { return "6d+"   }
        if monthsFrom(currentDate)  > 0 { return "6d+"  }
        if weeksFrom(currentDate)   > 0 { return "6d+"   }
        if daysFrom(currentDate)    > 0 { return "\(daysFrom(currentDate))day"    }
        if hoursFrom(currentDate)   > 0 { return "\(hoursFrom(currentDate))hr"   }
        if minutesFrom(currentDate) > 0 { return "\(minutesFrom(currentDate))min" }
        if secondsFrom(currentDate) > 0 { return "\(secondsFrom(currentDate))s" }
        return ""
    }
    
    func toShortDayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: self)
    }
    
    func toShortDayString(timezone: String) -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.timeZone = TimeZone(abbreviation: timezone)
        
        return formatter.string(from: self)
    }
    
    
    func toShortLocalDayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: self)
    }
    
    func toShortConferenceTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(from: self)
    }
    
    func toShortConferenceTimeString(timezone: String) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(abbreviation: timezone)
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(from: self)
    }
    
    func toShortConferenceLocalTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(from: self)
    }
    
    func toTimeString(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func toLocalTimeString(_ format: String?) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none

        formatter.timeStyle = .short
        if format == nil {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = format
        }
        
        formatter.timeZone = NSTimeZone.local
        
        return formatter.string(from: self)
    }
    
    func addDays(_ amount: Double) -> Date {
        return self.addingTimeInterval(60 * 60 * 24 * amount)
    }
    
    func getPrettyConferenceTitleDateString(endDate: Date) -> String! {
        let isInSameMonth = self.monthsFrom(endDate) == 0
        let dayFromSelf = Calendar.current.component(.day, from: self)
        let dayFromTo = Calendar.current.component(.day, from: endDate)
        let month = Calendar.current.component(.month, from: self)
        let toMonth = Calendar.current.component(.month, from: endDate)
        let dateFormatter = DateFormatter()

        if isInSameMonth {
            return "\(dayFromSelf) - \(dayFromTo) \(dateFormatter.monthSymbols[month - 1])"
        }
        return "\(dayFromSelf) \(dateFormatter.shortMonthSymbols[month - 1])   - \(dayFromTo) \(dateFormatter.shortMonthSymbols[toMonth - 1])"
    }
    
    func isBetween(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0
    }
    
    static func daySuffix(dayOfMonth: Int) -> String {
        switch dayOfMonth {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
}
