//
//  AppDelegate.swift
//  SibLinks
//
//  Created by sanghv on 8/27/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SwiftHEXColors
import GoogleSignIn
import GGLCore
import Firebase
import FirebaseMessaging
//import UserNotifications
import SDCAlertView
import Fabric
import Crashlytics

enum NotificationDataType: Int {
    case Unknown = 0, Answer = 1, CommentVideo, Essay = 4
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid

    var appLauched = false
    
    var categories = [SLCategory]()
    var university = [SLSchool]()
    var faculty = [SLMajor]()
    var differenceTime: Double = 0.0
    
    // Notification
    var dataType: NotificationDataType = .Unknown
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Set up view
        self.setupView()
        
        // Customize UIAppearance
        self.customizeUIAppearance()
        
        // Google: Initialize sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        GIDSignIn.sharedInstance().delegate = self
        
        // Google: In-app event tracking
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true
        gai.logger.logLevel = GAILogLevel.Verbose
        
        // Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Firebase
        FIRApp.configure()
        
        // Fabric
        Fabric.with([Crashlytics.self])

        // Register notification
        // FIXME: iOS 10, xcode 8.0 require user notification
//        if #available(iOS 10.0, *) {
//            let authOptions : UNAuthorizationOptions = [.Alert, .Badge, .Sound]
//            UNUserNotificationCenter.currentNotificationCenter().requestAuthorizationWithOptions(authOptions, completionHandler: { (_, _) in
//                
//            })
//            // For iOS 10 display notification (sent via APNS)
//            UNUserNotificationCenter.currentNotificationCenter().delegate = self
//            // For iOS 10 data message (sent via FCM)
//            FIRMessaging.messaging().remoteMessageDelegate = self
//        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
//        }
        
        application.registerForRemoteNotifications()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.tokenRefreshNotification(_:)), name: kFIRInstanceIDTokenRefreshNotification, object: nil)
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let google = GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
        let facebook = FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        return google || facebook
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        FIRMessaging.messaging().disconnect()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        self.endBackgroundTask()
        self.connectToFcm()
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Sandbox)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        let dataString = userInfo["aps"]?["category"] as? String
        let data = dataString?.toDictionary()
        
        var showAlert = true
        if application.applicationState == .Inactive || application.applicationState == .Background {
            showAlert = false
        }
        
        self.pushNotificationWithData(data, alert: showAlert)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        let dataString = userInfo["aps"]?["category"] as? String
        let data = dataString?.toDictionary()
        
        var showAlert = true
        if application.applicationState == .Inactive || application.applicationState == .Background {
            showAlert = false
        }
        
        self.pushNotificationWithData(data, alert: showAlert)
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connectWithCompletion { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
                if let refreshedToken = FIRInstanceID.instanceID().token() {
                    print("InstanceID token: \(refreshedToken)")
                }
            }
        }
    }
    
}

// FIXME: iOS 10, xcode 8.0 require user notification
//extension AppDelegate: UNUserNotificationCenterDelegate {
//    
//    // MARK: - UNUserNotificationCenterDelegate
//    
//    @available(iOS 10.0, *)
//    func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
//        let userInfo = notification.request.content.userInfo
//        let dataString = userInfo["aps"]?["category"] as? String
//        let data = dataString?.toDictionary()
//        
//        self.pushNotificationWithData(data, alert: true)
//    }
//    
//    @available(iOS 10.0, *)
//    func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
//        let userInfo = response.notification.request.content.categoryIdentifier;
//        let data = userInfo.toDictionary()
//        
//        self.pushNotificationWithData(data)
//    }
//}

extension AppDelegate {
    
    // MARK: - Push notification
    
    func pushNotificationWithData(data: [String : AnyObject]?, alert: Bool = false) {
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.PUSH_NOTIFICATION, object: data)
        if alert {
            if let data = data {
                if let dataType = data["datatype"] as? String {
                    self.dataType = NotificationDataType(rawValue: dataType.toInt()) ?? .Unknown
                    switch self.dataType {
                    case .Answer:
                        print("Answer")
                        var objectId = 0
                        if let dataId = data["dataid"] as? String {
                            objectId = dataId.toInt()
                        }
                        
                        // Alert
                        Constants.showAlert("SibLinks", message: "A new message has arrived. Do you want to open it?", actions:
                            AlertAction(title: Constants.CANCEL_ALERT_BUTTON, style: .Default),
                                            AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred, handler: { (_) in
                                                NSNotificationCenter.defaultCenter().postNotificationName(Constants.PUSH_ANSWERRED, object: objectId)
                                            }))
                    case .Essay:
                        print("Essay")
                        var objectId = 0
                        if let dataId = data["dataid"] as? String {
                            objectId = dataId.toInt()
                        }
                        
                        Constants.showAlert("SibLinks", message: "A new message has arrived. Do you want to open it?", actions:
                            AlertAction(title: Constants.CANCEL_ALERT_BUTTON, style: .Default),
                                            AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred, handler: { (_) in
                                                NSNotificationCenter.defaultCenter().postNotificationName(Constants.PUSH_ESSAY, object: objectId)
                                            }))
                    default:
                        print("Unknown")
                    }
                }
            }
        } else {
            // No Alert
            if let data = data {
                if let dataType = data["datatype"] as? String {
                    self.dataType = NotificationDataType(rawValue: dataType.toInt()) ?? .Unknown
                    switch self.dataType {
                    case .Answer:
                        print("Answer")
                        var objectId = 0
                        if let dataId = data["dataid"] as? String {
                            objectId = dataId.toInt()
                        }
                        NSNotificationCenter.defaultCenter().postNotificationName(Constants.PUSH_ANSWERRED, object: objectId)
                        
                    case .Essay:
                        print("Essay")
                        var objectId = 0
                        if let dataId = data["dataid"] as? String {
                            objectId = dataId.toInt()
                        }
                        NSNotificationCenter.defaultCenter().postNotificationName(Constants.PUSH_ESSAY, object: objectId)
                        
                    default:
                        print("Unknown")
                    }
                }
            }
        }
    }
    
}

extension AppDelegate: FIRMessagingDelegate {
    
    // MARK: - FIRMessagingDelegate
    
    func applicationReceivedRemoteMessage(remoteMessage: FIRMessagingRemoteMessage) {
        
    }
    
}

extension AppDelegate: GIDSignInDelegate {
    
    // MARK: - GIDSignInDelegate
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        print("didSignInForUser")
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        print("didDisconnectWithUser")
    }
}

extension AppDelegate {
    // MARK - Set up View
    func setupView() {
        if window == nil {
            window = UIWindow(frame: UIScreen.mainScreen().bounds)
        }
        
        var rootViewController = UIViewController()
        if !AppDelegate.introduction {
            rootViewController = UIStoryboard(name: Constants.INTRODUCE_STORYBOARD, bundle: nil).instantiateInitialViewController()!
        } else if !AppDelegate.login {
            rootViewController = UIStoryboard(name: Constants.SIGN_IN_STORYBOARD, bundle: nil).instantiateInitialViewController()!
        } else {
            let slideMenuController = SLSideMenuViewController.instantiateFromStoryboard(Constants.SLIDE_MENU_STORYBOARD)
            rootViewController = slideMenuController
        }
        
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
    
    // MARK: - Tab Bar Controller
    func setupTabBar() -> UITabBarController {
        let tabBarController = SLTabBarViewController()
        return tabBarController
    }
    
    func tokenRefreshNotification(notification: NSNotification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        self.connectToFcm()
    }
}

extension AppDelegate {

    // MARK: - Customize UI appearance
    func customizeUIAppearance() {
        // Navigation bar appearance
        UINavigationBar.appearance().setBackgroundImage(UIImage(color: colorFromHex(Constants.SIBLINKS_COMMON_HEX_COLOR)), forBarMetrics: .Default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = UIColor(hexString: Constants.SIBLINKS_NAV_COLOR)
        UINavigationBar.appearance().barTintColor = UIColor(hexString: Constants.SIBLINKS_NAV_COLOR)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR),
                                                            NSFontAttributeName: Constants.boldFontOfSize(16.0, increaseFont: false)]
        UINavigationBar.appearance().translucent = false

        UIBarButtonItem.appearance().tintColor = UIColor(hexString: Constants.SIBLINKS_NAV_COLOR)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR),
            NSFontAttributeName: Constants.regularFontOfSize(14.0, increaseFont: false)], forState: .Normal)
        
        // Tab bar appearance
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(hexString: Constants.SIBLINKS_TABBAR_NORMAL_TEXT_COLOR), NSFontAttributeName : Constants.boldFontOfSize(12)], forState: .Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(hexString: Constants.SIBLINKS_TABBAR_SELECTED_TEXT_COLOR), NSFontAttributeName : Constants.boldFontOfSize(12)], forState: .Selected)
        UITabBar.appearance().tintColor = UIColor.blackColor()
        UITabBar.appearance().barTintColor = UIColor(hexString: Constants.SIBLINKS_TABBAR_BACKGROUND_COLOR)
        if #available(iOS 9.0, *) {
            UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).defaultTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: Constants.regularFontOfSize(14.0, increaseFont: false)]
        }
    }
}

extension AppDelegate {

    // MARK: - Register background task

    func reinstateBackgroundTask() {
        if (backgroundTask == UIBackgroundTaskInvalid) {
            registerBackgroundTask()
        }
    }

    func registerBackgroundTask() {
        backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
            [unowned self] in
            self.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }

    func endBackgroundTask() {
        UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
}

extension AppDelegate {
    // MARK: - Background Handler
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        APIManagement.sharedInstance.sessionDelegate.addCompletionHandler(completionHandler, identifier: identifier)
    }
}

extension AppDelegate {
    // MARK: - App state
    static var introduction: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(Constants.kIntroduction)
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: Constants.kIntroduction)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    static var login: Bool {
        
        get {
            if NSUserDefaults.standardUserDefaults().objectForKey(Constants.kUser) != nil {
                return true
            }
            return false
        }
        
    }
}

extension AppDelegate {
    
    func getCategories() {
        AskQuestionRouter(endpoint: AskQuestionEndpoint.GetCategories()).request { (result) in
            switch result {
            case .Success(let objects):
                if let objects = objects as? [SLCategory] {
                    self.categories = objects
                }
            default:
                print("Get categories: error")
            }
        }
        
        EssayRouter(endpoint: EssayEndpoint.GetSchool()).request { (result) in
            switch result {
            case .Success(let objects):
                if let schools = objects as? [SLSchool] {
                    self.university = schools
                }
            default:
                print("Get university: error")
            }
        }
        
        EssayRouter(endpoint: EssayEndpoint.GetSubject()).request { (result) in
            switch result {
            case .Success(let objects):
                if let subjects = objects as? [SLMajor] {
                    self.faculty = subjects
                }
            default:
                print("Get faculty: error")
            }
        }
        
        UserRouter(endpoint: UserEndpoint.GetTimeFromServer()).requestFullData { (result) in
            switch result {
            case .Success(let objects):
                if let dateString = objects as? String {
                    let dateInt = dateString.toDouble()
                    let currentDate = NSDate().timeIntervalSince1970
                    let currentDateInt = currentDate
                    self.differenceTime = dateInt - currentDateInt
                }
                
            default:
                print("Get time: Error")
            }
        }
    }
    
}
