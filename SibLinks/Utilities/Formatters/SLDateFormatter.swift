//
//  SLDateFormatter.swift
//  SibLinks
//
//  Created by sanghv on 8/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation

let fullDateTimeFormatter = SLDateFormatter.sharedInstance.fullDateTimeFormatter
let fullDateFormatter = SLDateFormatter.sharedInstance.fullDateFormatter
let invariantCultureFormatter = SLDateFormatter.sharedInstance.invariantCultureFormatter
let monthFormatter = SLDateFormatter.sharedInstance.monthFormatter
let monthAfterFormatter = SLDateFormatter.sharedInstance.monthAfterFormatter
let dateTimeInvariantCultureFormatter = SLDateFormatter.sharedInstance.dateTimeInvariantCultureFormatter
let askQuestionDateFormatter = SLDateFormatter.sharedInstance.askQuestionDataFormatter
let birthDateFormatter = SLDateFormatter.sharedInstance.birthDateFormatter

/** SLDateFormatter Class

 */
class SLDateFormatter {

    static let sharedInstance = SLDateFormatter()

    private init(){}

    lazy var fullDateTimeFormatter: NSDateFormatter = self.createFullDateTimeFormatter()
    private func createFullDateTimeFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter
    }
    lazy var fullDateFormatter: NSDateFormatter = self.createFullDateFormatter()
    private func createFullDateFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter
    }
    lazy var invariantCultureFormatter: NSDateFormatter = self.createInvariantCultureFormatter()
    private func createInvariantCultureFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        
        return dateFormatter
    }
    lazy var monthFormatter: NSDateFormatter = self.createMonthFormatter()
    private func createMonthFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        return dateFormatter
    }
    lazy var monthAfterFormatter: NSDateFormatter = self.createMonthAfterFormatter()
    private func createMonthAfterFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy"
        
        return dateFormatter
    }
    lazy var dateTimeInvariantCultureFormatter: NSDateFormatter = self.createDateTimeInvariantCultureFormatter()
    private func createDateTimeInvariantCultureFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy HH:mm:ss"
        
        return dateFormatter
    }
    lazy var askQuestionDataFormatter: NSDateFormatter = self.createAskQuestionDataFormatter()
    private func createAskQuestionDataFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, HH:mm"
        
        return dateFormatter
    }
    lazy var birthDateFormatter: NSDateFormatter = self.createBirthDateFormatter()
    private func createBirthDateFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy"
        
        return dateFormatter
    }

}

func convertDateFormater(date: String) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = NSTimeZone(name: "UTC")

    guard let date = dateFormatter.dateFromString(date) else {
        return ""
    }

    dateFormatter.dateFormat = "dd/MM/yyyy"
    dateFormatter.timeZone = NSTimeZone(name: "UTC")
    let timeStamp = dateFormatter.stringFromDate(date)

    return timeStamp
}

func convertDateFormaterToText(date: String) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = NSTimeZone(name: "UTC")

    guard let date = dateFormatter.dateFromString(date) else {
        return ""
    }

    dateFormatter.dateStyle = .LongStyle
    dateFormatter.timeStyle = .ShortStyle
    dateFormatter.timeZone = NSTimeZone(name: "UTC")
    let timeStamp = dateFormatter.stringFromDate(date)
    
    return timeStamp
}
