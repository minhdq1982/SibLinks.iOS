//
//  APIManagement.swift
//  SibLinks
//
//  Created by sanghv on 8/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import Alamofire
import Moya
import SwiftyJSON
import SDCAlertView
import XCGLogger

typealias JSONClosure = (JSON) -> ()
typealias SLObjectsClosure = ([DataModel]?) -> ()
typealias SLObjectClosure = (DataModel?) -> ()
typealias SLBooleanResultClosure = (Bool) -> ()
typealias SLObjectIdResultClosure = (Int?) -> ()
typealias ErrorClosure = (NSError?) -> ()
typealias DownloadCompletedClosure = (NSURL?, NSError?) -> ()

/** APIManagement Class

 */
class APIManagement {

    static let sharedInstance = APIManagement()

    private init(){
        self.startNetworkReachabilityListening()
    }

    private static let BACKGROUND_CONFIGURATION_IDENTIFIER: String = (NSBundle.mainBundle().infoDictionary?["CFBundleIdentifier"] as! String) + ".background"
    let sessionDelegate = SLSessionDelegate()

    lazy private var networkReachabilityManager: NetworkReachabilityManager? = self.creatNenetworkReachabilityManager()

    var networkAvailable = true {
        didSet {
            self.observerNetworkChanged()
        }
    }

    var isNetworkAvailable: Bool {
        get {
            return self.networkAvailable
        }
    }

    lazy var manager: Alamofire.Manager = self.createManager()
    lazy var managerForLongTask: Alamofire.Manager = self.createManagerForLongTask()
    lazy var backgroundManager: Alamofire.Manager = self.createBackgroundManager()
    
    var categories = [SLCategory]()
    
    // MARK: - Create property
    private func creatNenetworkReachabilityManager() -> NetworkReachabilityManager? {
        let networkReachabilityManager = NetworkReachabilityManager() // NetworkReachabilityManager(host: Constants.API_HOST)
        
        networkReachabilityManager?.listener = { [unowned self] status in
            self.networkAvailable = (status == .Reachable(.EthernetOrWiFi) || status == .Reachable(.WWAN))
        }
        
        return networkReachabilityManager
    }
    
    private func observerNetworkChanged() {
        if !self.networkAvailable {
            Constants.showAlert(message: Constants.LOST_CONNECTION_MSG, actions:
                AlertAction(title: Constants.CANCEL_ALERT_BUTTON, style: .Default),
                                AlertAction(title: Constants.IOS_SETTINGS_APP, style: .Preferred, handler: { (_) in
                                    let wifiSettingsUrl = NSURL(string: Constants.WIFI_SCHEME)
                                    if let url = wifiSettingsUrl {
                                        UIApplication.sharedApplication().openURL(url)
                                    }
                                }))
        }
    }
    
    private func createManager() -> Alamofire.Manager {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
        
        configuration.timeoutIntervalForRequest = Constants.timeoutIntervalForRequest
        configuration.timeoutIntervalForResource = Constants.timeoutIntervalForResource
        
        let manager = Alamofire.Manager(configuration: configuration)
        
        return manager
    }
    
    private func createManagerForLongTask() -> Alamofire.Manager {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
        
        configuration.timeoutIntervalForRequest = Constants.timeoutIntervalForRequest * 40
        configuration.timeoutIntervalForResource = Constants.timeoutIntervalForResource * 10
        
        let managerForLongTask = Alamofire.Manager(configuration: configuration)
        
        return managerForLongTask
    }
    
    private func createBackgroundManager() -> Alamofire.Manager {
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(APIManagement.BACKGROUND_CONFIGURATION_IDENTIFIER)
        configuration.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
        
        let backgroundManager = Alamofire.Manager(configuration: configuration, delegate: self.sessionDelegate)
        
        return backgroundManager
    }
}

extension APIManagement {

    // MARK: - Network Reachability
    func startNetworkReachabilityListening() {
        self.networkReachabilityManager?.startListening()
    }

    func stopNetworkReachabilityListening() {
        self.networkReachabilityManager?.listener = nil
        self.networkReachabilityManager?.stopListening()
    }
}

extension APIManagement {
    
    // MARK: - Get Category
    func getCategories() {
        AskQuestionRouter(endpoint: AskQuestionEndpoint.GetCategories()).request { (result) in
            switch result {
            case .Success(let objects):
                if let objects = objects as? [SLCategory] {
                    self.categories = objects
                }
            default:
                print("Not get categories")
            }
        }
    }
}

extension APIManagement {

    // MARK: - Download

    func download(urlString: String?, fileName: String?, completionHandler: DownloadCompletedClosure?) {
        guard let urlStringTemp = urlString, let url = NSURL(string: urlStringTemp) else {
            return
        }

        if let fileName = fileName {
            let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            let essayFolder = documents.stringByAppendingString("/Essays")
            let essayDirectory = NSURL(fileURLWithPath: essayFolder)
            
            APIManagement.removeFile(fileName, inDirectory: essayDirectory)
        }
        
        let urlRequest = NSURLRequest(URL: url)
        let destination: Request.DownloadFileDestination = { _, _ in
            let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            let essayFolder = documents.stringByAppendingString("/Essays/")
            
            //  Create essay folder if need
            if !NSFileManager.defaultManager().fileExistsAtPath(essayFolder) {
                //  Create essay folder at path
                do {
                    try NSFileManager.defaultManager().createDirectoryAtPath(essayFolder, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Could not create essay folder")
                }
            }
            
            let path = essayFolder.stringByAppendingString(fileName ?? "essay")
            let fileURL = NSURL(fileURLWithPath: path)
            
            return (fileURL ?? NSURL())
        }
        
        let downloadRequest = backgroundManager.download(urlRequest, destination: destination)
        downloadRequest.progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
            guard totalBytesExpectedToWrite != 0 else {
                return
            }

            let _ = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            dispatch_async(dispatch_get_main_queue()) {
            }
        }

        downloadRequest.response { (urlRequest, httpURLResponse, _, error) in
            if let error = error {

                completionHandler?(nil, error)

                return
            }

            guard let url = urlRequest?.URL, let response = httpURLResponse else {
                completionHandler?(nil, error)

                return
            }

            let destinationURL = destination(url, response)

            completionHandler?(destinationURL, error)
        }
    }
    
    // MARK: - Status
    private func status(json: [String: AnyObject]) -> Bool {
        if let status = json["status"] as? String {
            return status.toBool()
        }
        
        if let status = json["status"] as? Int {
            return status.toBool()
        }
        
        return false
    }
    
    private func otherStatus(json: JSON) -> Bool {
        if let status = json["status"].string {
            return status.toBool()
        }
        
        if let status = json["status"].int {
            return status.toBool()
        }
        
        return false
    }
}

extension APIManagement {

    // MARK: - Document Directory

    class func applicationDirectory (directory: NSSearchPathDirectory = .DocumentDirectory, domain: NSSearchPathDomainMask = .UserDomainMask) -> NSURL? {
        let directoryURLs = NSFileManager.defaultManager().URLsForDirectory(directory, inDomains: domain)
        
        guard !directoryURLs.isEmpty else {
            return nil
        }
        
        return directoryURLs[0]
    }
    
    // MARK: - Remove file
    
    class func removeFile(name: String, inDirectory directory: NSURL) {
        let filePathURL = directory.URLByAppendingPathComponent(name)
        
        
        if let filePath = filePathURL.path {
            if NSFileManager.defaultManager().fileExistsAtPath(filePath) == true {
                try! NSFileManager.defaultManager().removeItemAtURL(filePathURL)
            }
        }
    }
}
