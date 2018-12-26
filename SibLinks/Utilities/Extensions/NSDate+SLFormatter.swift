//
//  NSDate+SLFormatter.swift
//  SibLinks
//
//  Created by sanghv on 8/29/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation

/** SLFormatter Extends NSDate

 */
extension NSDate {

    func fullDateTimeString() -> String {
        return fullDateTimeFormatter.stringFromDate(self)
    }

    func fullDateString() -> String {
        return fullDateFormatter.stringFromDate(self)
    }

    func invariantCultureDateString() -> String {
        return invariantCultureFormatter.stringFromDate(self)
    }
    
    func monthFormatterString() -> String {
        return monthFormatter.stringFromDate(self)
    }
    
    func monthAfterFormatterString() -> String {
        return monthAfterFormatter.stringFromDate(self)
    }
    
    func dateTimeInvariantCultureDateString() -> String {
        return dateTimeInvariantCultureFormatter.stringFromDate(self)
    }
    
    func askQuestionDateString() -> String {
        return askQuestionDateFormatter.stringFromDate(self)
    }
}
