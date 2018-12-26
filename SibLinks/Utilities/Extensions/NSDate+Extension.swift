//
//  NSDate+Extension.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/16/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation

extension NSDate {
    // MARK: Intervals In Seconds
    private static func minuteInSeconds() -> Double { return 60 }
    private static func hourInSeconds() -> Double { return 3600 }
    private static func dayInSeconds() -> Double { return 86400 }
    private static func weekInSeconds() -> Double { return 604800 }
    private static func yearInSeconds() -> Double { return 31556926 }
    
    // MARK: Retrieving Intervals
    /**
     Gets the number of seconds after a date.
     
     - Parameter date: the date to compare.
     - Returns The number of seconds
     */
    func secondsAfterDate(date: NSDate) -> Int {
        return Int(self.timeIntervalSinceDate(date))
    }
    
    /**
     Gets the number of seconds before a date.
     
     - Parameter date: The date to compare.
     - Returns The number of seconds
     */
    func secondsBeforeDate(date: NSDate) -> Int {
        return Int(date.timeIntervalSinceDate(self))
    }
    
    /**
     Gets the number of minutes after a date.
     
     - Parameter date: the date to compare.
     - Returns The number of minutes
     */
    func minutesAfterDate(date: NSDate) -> Int {
        let interval = self.timeIntervalSinceDate(date)
        return Int(interval / NSDate.minuteInSeconds())
    }
    
    /**
     Gets the number of minutes before a date.
     
     - Parameter date: The date to compare.
     - Returns The number of minutes
     */
    func minutesBeforeDate(date: NSDate) -> Int {
        let interval = date.timeIntervalSinceDate(self)
        return Int(interval / NSDate.minuteInSeconds())
    }
    
    /**
     Gets the number of hours after a date.
     
     - Parameter date: The date to compare.
     - Returns The number of hours
     */
    func hoursAfterDate(date: NSDate) -> Int {
        let interval = self.timeIntervalSinceDate(date)
        return Int(interval / NSDate.hourInSeconds())
    }
    
    /**
     Gets the number of hours before a date.
     
     - Parameter date: The date to compare.
     - Returns The number of hours
     */
    func hoursBeforeDate(date: NSDate) -> Int {
        let interval = date.timeIntervalSinceDate(self)
        return Int(interval / NSDate.hourInSeconds())
    }
    
    /**
     Gets the number of days after a date.
     
     - Parameter date: The date to compare.
     - Returns The number of days
     */
    func daysAfterDate(date: NSDate) -> Int {
        let interval = self.timeIntervalSinceDate(date)
        return Int(interval / NSDate.dayInSeconds())
    }
    
    /**
     Gets the number of days before a date.
     
     - Parameter date: The date to compare.
     - Returns The number of days
     */
    func daysBeforeDate(date: NSDate) -> Int {
        let interval = date.timeIntervalSinceDate(self)
        return Int(interval / NSDate.dayInSeconds())
    }
    
    /**
     Gets the number of weeks after a date.
     
     - Parameter date: The date to compare.
     - Returns The number of years
     */
    func weeksAfterDate(date: NSDate) -> Int {
        let interval = self.timeIntervalSinceDate(date)
        return Int(interval / NSDate.weekInSeconds())
    }
    
    /**
     Gets the number of weeks before a date.
     
     - Parameter date: The date to compare.
     - Returns The number of years
     */
    func weeksBeforeDate(date: NSDate) -> Int {
        let interval = date.timeIntervalSinceDate(self)
        return Int(interval / NSDate.weekInSeconds())
    }
    /**
     Gets the number of years after a date.
     
     - Parameter date: The date to compare.
     - Returns The number of years
     */
    func yearsAfterDate(date: NSDate) -> Int {
        let interval = self.timeIntervalSinceDate(date)
        return Int(interval / NSDate.yearInSeconds())
    }
    
    /**
     Gets the number of years before a date.
     
     - Parameter date: The date to compare.
     - Returns The number of years
     */
    func yearsBeforeDate(date: NSDate) -> Int {
        let interval = date.timeIntervalSinceDate(self)
        return Int(interval / NSDate.yearInSeconds())
    }
    
}
