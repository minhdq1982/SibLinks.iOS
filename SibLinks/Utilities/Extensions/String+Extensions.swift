//
//  String+Extensions.swift
//  SibLinks
//
//  Created by Jana on 9/14/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    // MARK: - Validate email
    
    func isEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(self)
    }
    
    func getUsernameFromEmail() -> String {
        let array = self.componentsSeparatedByString("@")
        if array.count > 0 {
            return array[0]
        }
        
        return ""
    }
    
    func toBool() -> Bool {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return false
        }
    }
    
    func toDate() -> NSDate {
        return NSDate(timeIntervalSince1970: NSTimeInterval(atof(self)))
    }
    
    var lastPathComponent: String {
        get {
            return (self as NSString).lastPathComponent
        }
    }
    
    var pathExtension: String {
        get {
            
            return (self as NSString).pathExtension
        }
    }
    
    func toDictionary() -> [String : AnyObject]? {
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    func toInt() -> Int {
        return (Int(self) != nil) ? Int(self)! : 0
    }
    
    func toDouble() -> Double {
        return (Double(self) != nil) ? Double(self)! : 0
    }
}

extension Int {
    
    func toBool() -> Bool {
        switch self {
        case 1:
            return true
        case 0:
            return false
        default:
            return false
        }
    }
    
    // Dynamic font
    func dynamicFont2() -> CGFloat {
        if Constants.greater(568) {
            let newFont = self + 2
            return CGFloat(newFont)
        }
        return CGFloat(self)
    }
    
    func dynamicFont3() -> CGFloat {
        if Constants.greater(568) {
            let newFont = self + 3
            return CGFloat(newFont)
        }
        return CGFloat(self)
    }
    
    func dynamicFont4() -> CGFloat {
        if Constants.greater(568) {
            let newFont = self + 4
            return CGFloat(newFont)
        }
        return CGFloat(self)
    }
}
