//
//  Constants.swift
//  SibLinks
//
//  Created by sanghv on 8/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import UIKit
import SwiftHEXColors
import SDCAlertView

func colorFromHex(hexString: String) -> UIColor {
    let color = UIColor(hexString: hexString)

    return color
}

/** Constants Struct

 */
struct Constants {

}

extension Constants {

    // MARK: - Hex color constant

//    static let SIBLINKS_COMMON_HEX_COLOR                    = "#f3c303"
    static let SIBLINKS_COMMON_HEX_COLOR                    = "#22589b"
    static let SIBLINKS_INTRODUCE_BACKGROUND_HEX_COLOR      = "#DFDFDF"
    static let SIBLINKS_TEXTFIELD_RED_COLOR                 = "#FF0000"
    static let SIBLINKS_TEXTFIELD_GREEN_COLOR               = "#559E2B"
    static let SIBLINKS_TABBAR_NORMAL_TEXT_COLOR            = "#b3b5b7"
    static let SIBLINKS_TABBAR_SELECTED_TEXT_COLOR          = "#505050"
    static let SIBLINKS_TABBAR_BACKGROUND_COLOR             = "#f5f8fb"
    static let SIBLINKS_TABBAR_SEPARATOR_COLOR              = "#e8ecf0"
//    static let SIBLINKS_NAV_COLOR                           = "#505050"
    static let SIBLINKS_NAV_COLOR                           = "#FFFFFF"
    static let SIBLINKS_SIDE_MENU_BACK_COLOR                = "#2B2B2B"
    static let SIBLINKS_PAGE_MENU_COLOR                     = "#828282"
    static let SIBLINKS_SEGMENTED_TEXT_COLOR                = "#909090"
    static let SIBLINKS_DELETE_BUTTON_COLOR                 = "#FF4D51"
    static let SIBLINKS_EDIT_BUTTON_COLOR                   = "#D1D1D1"
    static let SIBLINKS_UNSUBSCRIBER_COLOR                  = "#bbc6d0"
    static let SIBLINKS_SUBSCRIBER_COLOR                    = "#ff5353"
    static let SIBLINKS_LIKE_COLOR                          = "#FF5C64"
    static let SIBLINKS_UNLIKE_COLOR                        = "#E4E4E4"
    static let SIBLINKS_UNDERLINE_SELECTED                  = "#5A98E2"
    static let SIBLINKS_PAGE_BACKGROUND_COLOR               = "#1A4881"
}

extension Constants {

    // MARK: - Number constant

    static let BUTTON_CORNER_RADIUS_VALUE: CGFloat              = 5
    static let MINIMUM_PASSWORD_CHARACTERS: Int                 = 6
    static let NAVIGATION_BAR_PORTRAIT_HEIGHT: CGFloat          = 64
    static let NAVIGATION_BAR_LANDSCAPE_HEIGHT: CGFloat         = 52
    static let TAB_BAR_CENTER_NUMBER: Int                       = 2
    static let TAB_BAR_MENTOR_NUMBER: Int                       = 4
    static let SPLASH_SCREEN_ANIMATION_DURATION: Double         = 0.9
    static let LIMIT_DEFAULT_NUMBER: Int                        = 10
}

extension Constants {

    // MARK: - String constant

    static let kPLIST_TYPE              = "plist"
    static let kJSON_TYPE               = "json"
    static let EMPTY_STRING             = ""
    static let EMPTY_PERCENT_STRING     = "0%"
    static let PERCENT_STRING           = "%"
    static let NEW_LINE_STRING          = "\n"
    static let ZERO_STRING              = "0"
    static let ZERO_DATE_TIME           = "0000-00-00 00:00:00"

    // MARK: - Icon string
    static let EMAIL_ICON               = "\u{f007}"
    static let PASSWORD_ICON            = "\u{f023}"
    
    // MARK: - Notification
    static let POST_QUESTION_CHANGE     = "com.siblinks.reload_question"
    static let POST_QUESTION_SEND       = "com.siblinks.post_question"
    static let SUBSCRIBER_CHANGE        = "com.siblinks.subscriber"
    static let UPLOAD_ESSAY             = "com.siblinks.upload_essay"
    
    // MARK: - Push notification
    static let PUSH_NOTIFICATION        = "com.siblinks.notification"
    static let PUSH_ANSWERRED           = "com.siblinks.answerred"
    static let PUSH_ESSAY               = "com.siblinks.essay"
    static let PUSH_POST_ASK_SUCCESS    = "com.siblinks.post.ask.success"
    
    // MARK: - Alert string
    static let NOTICE_ALERT_TITLE       = "Notice"
    static let APP_NAME_ALERT_TITLE     = "SibLinks"
    static let OK_ALERT_BUTTON          = "OK"
    static let CANCEL_ALERT_BUTTON      = "Cancel"
    static let YES_ALERT_BUTTON         = "YES"
    static let NO_ALERT_BUTTON          = "NO"
    static let IOS_SETTINGS_APP         = "Settings"
    static let WIFI_SCHEME              = "prefs:root=WIFI"

    // MARK: - Networks

    static let NETWORK_OFFLINE          = "Network error. Please try again."
    static let LOST_CONNECTION_MSG      = "Network isn't reachable. Please check network connection. Go to WIFI setting?"
    static let SERVER_ERROR_MSG         = "Server process error. Please try again."

    // MARL: - Download file

    static let URL_NOT_AVAILABLE        = "URL is not available."
    static let DOWNLOADING              = "Downloading"
    static let DOWNLOAD_FAIL            = "Download fail."
    static let DOWNLOAD_COMPLETED       = "Download completed."
}

extension Constants {

    // MARK: - NSUserdefault
    
    static let kUser                    = "User"
    
    static let kIntroduction            = "Introduction"
    static let kLogin                   = "Login"
}

extension Constants {

    // MARK: - Storyboard name
    static let INTRODUCE_STORYBOARD                 = "IntroduceScreen"
    static let SIGN_IN_STORYBOARD                   = "SignInScreen"
    static let VIDEO_STORYBOARD                     = "VideoScreen"
    static let ASK_STORYBOARD                       = "AskQuestionScreen"
    static let ADMISSION_STORYBOARD                 = "AdmissionScreen"
    static let MENTOR_STORYBOARD                    = "TopMentorsScreen"
    static let SLIDE_MENU_STORYBOARD                = "SlideMenuScreen"
    static let NOTIFICATION_STORYBOARD              = "NotificationsScreen"
    static let STUDENT_PROFILE_STORYBOARD           = "StudentProfileScreen"
    static let UPLOAD_ESSAY_STORYBOARD              = "UploadEssayScreen"
    
    // MARK: - Storyboard id
    
    // MARK: - Segue
    static let SLIDE_MENU_SEGUE                     = "kSegueToSlideMenu"
    static let SIGN_IN_SEGUE                        = "kShowSignInScreen"
    static let SIGN_OUT_SEGUE                       = "kShowSignOutScreen"
    static let LOG_OUT_SEGUE                        = "kShowSignInScreen"
    static let QUESTION_DETAIL_SEGUE                = "kShowAskDetailScreen"
    static let SUBSCRIBER_DETAIL_SEGUE              = "kShowSubscriberScreen"
    static let EDIT_STUDENT_PROFILE                 = "kEditStudentProfile"
}

extension Constants {

    // MARK: - Font
    
    static let DELTA_FONT_FOR_PAD: CGFloat = 3

    static func fontOfSize(fontSize: CGFloat, increaseFont: Bool = true) -> UIFont {
        var newFontSize = fontSize
        if Constants.isPad && !increaseFont {
            newFontSize += Constants.DELTA_FONT_FOR_PAD
        }

        let font = UIFont.systemFontOfSize(newFontSize)

        return font
    }

    static func boldFontOfSize(fontSize: CGFloat, increaseFont: Bool = true) -> UIFont {
        var newFontSize = fontSize
        if Constants.isPad && !increaseFont {
            newFontSize += Constants.DELTA_FONT_FOR_PAD
        }

        guard let font = UIFont.init(name: "Lato-Black", size: newFontSize) else {
            return Constants.fontOfSize(newFontSize)
        }

        return font
    }

    static func regularFontOfSize(fontSize: CGFloat, increaseFont: Bool = true) -> UIFont {
        var newFontSize = fontSize
        if Constants.isPad && !increaseFont {
            newFontSize += Constants.DELTA_FONT_FOR_PAD
        }
        
        guard let font = UIFont.init(name: "Lato-Regular", size: newFontSize) else {
            return Constants.fontOfSize(newFontSize)
        }
        
        return font
    }
    
    static func italicFontOfSize(fontSize: CGFloat, increaseFont: Bool = true) -> UIFont {
        var newFontSize = fontSize
        if Constants.isPad && !increaseFont {
            newFontSize += Constants.DELTA_FONT_FOR_PAD
        }

        guard let font = UIFont.init(name: "Lato-Italic", size: newFontSize) else {
            return Constants.fontOfSize(newFontSize)
        }
        
        return font
    }

    static func mediumFontOfSize(fontSize: CGFloat, increaseFont: Bool = true) -> UIFont {
        var newFontSize = fontSize
        if Constants.isPad && !increaseFont {
            newFontSize += Constants.DELTA_FONT_FOR_PAD
        }

        guard let font = UIFont.init(name: "Lato-Medium", size: newFontSize) else {
            return Constants.fontOfSize(newFontSize)
        }

        return font
    }

    static func mediumItalicFontOfSize(fontSize: CGFloat, increaseFont: Bool = true) -> UIFont {
        var newFontSize = fontSize
        if Constants.isPad && !increaseFont {
            newFontSize += Constants.DELTA_FONT_FOR_PAD
        }

        guard let font = UIFont.init(name: "Lato-MediumItalic", size: newFontSize) else {
            return Constants.fontOfSize(newFontSize)
        }
        
        return font
    }
    
    static func fontAwesomeOfSize(fontSize: CGFloat, increaseFont: Bool = true) -> UIFont {
        var newFontSize = fontSize
        if Constants.isPad && !increaseFont {
            newFontSize += Constants.DELTA_FONT_FOR_PAD
        }
        
        guard let font = UIFont.init(name: "FontAwesome", size: newFontSize) else {
            return Constants.fontOfSize(newFontSize)
        }
        
        return font
    }
}

extension Constants {

    // MARK: - API

    #if SANDBOX_VERSION
        static let API_HOST = "http://192.168.50.64:8071"
    #else
        static let API_HOST = "http://113.160.22.42:8070"
    #endif

    static let TOKEN_EXPIRED_STATUS_CODE: Int       = 403
    static let SERVER_ERROR_STATUS_CODE: Int        = 500
    static let SERVER_RESPONSE_STATUS_CODE: Int     = 200
    
    static let LOST_NETWORK_CODE: Int               = 1000
    static let BAD_REQUEST_CODE: Int                = 1001
    static let LOGIN_NOT_CORRECT_CODE:Int           = 1002
    static let PARSE_ERROR_CODE: Int                = 1003
    static let timeoutIntervalForRequest: NSTimeInterval = 15
    static let timeoutIntervalForResource: NSTimeInterval = 60
    
    static let ErrorDomain = "com.siblinks.error"
    static let NetworkError = NSError(domain: ErrorDomain, code: Constants.LOST_NETWORK_CODE, userInfo: nil)
    static let RequestError = NSError(domain: ErrorDomain, code: Constants.BAD_REQUEST_CODE, userInfo: nil)
    static let LoginError = NSError(domain: ErrorDomain, code: Constants.LOGIN_NOT_CORRECT_CODE, userInfo: nil)
    static let ParseError = NSError(domain: ErrorDomain, code: Constants.PARSE_ERROR_CODE, userInfo: nil)
}

extension Constants {

    // MARK: - Alert

    static func showAlert(title: String? = Constants.APP_NAME_ALERT_TITLE, message: String, actions: AlertAction...) {
        let alert = AlertController(title: title, message: message)

        actions.forEach {
            alert.addAction($0)
        }

        alert.present()
    }

    static func showAlertWithOnlyOKAction(title: String? = Constants.APP_NAME_ALERT_TITLE, message: String) {
        AlertController.alertWithTitle(title, message: message, actionTitle: Constants.OK_ALERT_BUTTON)
    }
}

extension Constants {

    // MARK: - AppDelegate instance

    static func appDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    static var window: UIView {
        get {
            return Constants.appDelegate().window!
        }
    }
}

extension Constants {

    // MARK: - Device info

    static var isPad: Bool {
        get {
            switch UI_USER_INTERFACE_IDIOM() {
            case .Pad:
                return true

            default:
                return false
                
            }
        }
    }
}

extension Constants {
    
    // MARK: - Size
    static var screenSize: CGSize {
        return UIScreen.mainScreen().bounds.size
    }
    
}

extension Constants {
    // MARK: - Time
    static func secondsToHoursMinutesSeconds (seconds : Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let second = (seconds % 3600) % 60
        let hoursString: String = {
            let hs = String(hours)
            return hs
        }()
        
        let minutesString: String = {
            var ms = ""
            if  (minutes <= 9 && minutes >= 0) {
                ms = "0\(minutes)"
            } else{
                ms = String(minutes)
            }
            return ms
        }()
        
        let secondsString: String = {
            var ss = ""
            if  (second <= 9 && second >= 0) {
                ss = "0\(second)"
            } else{
                ss = String(second)
            }
            return ss
        }()
        
        var label = ""
        if hours == 0 {
            label =  minutesString + ":" + secondsString
        } else{
            label = hoursString + ":" + minutesString + ":" + secondsString
        }
        return label
    }
    
    static func dateToTime(updatedAt: NSDate?) -> String {
        var time = ""
        if let updateAt = updatedAt {
            let now = NSDate().dateByAddingTimeInterval(self.appDelegate().differenceTime)
            if updateAt.compare(now) == .OrderedDescending {
                return time
            }
            
            if updateAt.yearsBeforeDate(now) > 0 {
                let year = updateAt.yearsBeforeDate(now)
                if year == 1 {
                    time = "\(year) year ago"
                } else {
                    time = "\(year) years ago"
                }
            } else if updateAt.weeksBeforeDate(now) > 0 {
                let week = updateAt.weeksBeforeDate(now)
                if week == 1 {
                    time = "\(week) week ago"
                } else {
                    time = "\(week) weeks ago"
                }
            } else if updateAt.daysBeforeDate(now) > 0 {
                let day = updateAt.daysBeforeDate(now)
                if day == 1 {
                    time = "\(day) day ago"
                } else {
                    time = "\(day) days ago"
                }
            } else if updateAt.hoursBeforeDate(now) > 0 {
                let hour = updateAt.hoursBeforeDate(now)
                if hour == 1 {
                    time = "\(hour) hour ago"
                } else {
                    time = "\(hour) hours ago"
                }
            } else if updateAt.minutesBeforeDate(now) > 0 {
                let minute = updateAt.minutesBeforeDate(now)
                if minute == 1 {
                    time = "\(minute) minute ago"
                } else {
                    time = "\(minute) minutes ago"
                }
            } else if updateAt.secondsBeforeDate(now) > 0 {
                let second = updateAt.secondsBeforeDate(now)
                if second == 1 {
                    time = "\(second) second ago"
                } else {
                    time = "\(second) seconds ago"
                }
            } else {
                time = "just now"
            }
        }
        
        return time
    }
}

extension Constants {
    
    // MARK: - Formatter
    static var viewsCount: NSNumberFormatter {
        let viewsCount = NSNumberFormatter()
        viewsCount.numberStyle = .DecimalStyle
        
        return viewsCount
    }
}

extension Constants {
    
    // MARK: - Image
    static let noAvatarImage = UIImage(named: "NoAvatar")!
}

extension Constants {
    
    // MARK: - Device
    static func greater(size: CGFloat) -> Bool {
        let screenWidth = UIScreen.mainScreen().bounds.size.height
        if screenWidth > size  {
            return true
        }
        return false
    }
}
