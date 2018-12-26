//
//  BaseRouter.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/12/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

class BaseRouter: SLTargetType {
    init() {}
    
    var parameterEncoding: Moya.ParameterEncoding {
        fatalError("[\(#function))] Must be overridden in subclass")
    }
    var baseURL: NSURL {
        return NSURL(string: Constants.API_HOST)!
    }
    var path: String {
        fatalError("[\(#function))] Must be overridden in subclass")
    }
    var method: Moya.Method {
        fatalError("[\(#function))] Must be overridden in subclass")
    }
    var parameters: [String: AnyObject]? {
        fatalError("[\(#function))] Must be overridden in subclass")
    }
    var sampleData: NSData {
        fatalError("[\(#function))] Must be overridden in subclass")
    }
    var multipartBody: [MultipartFormData]? {
        fatalError("[\(#function))] Must be overridden in subclass")
    }
    var headerFields: [String:String]? {
        return ["Content-Type": "application/json"]
    }
    var fullURL: String {
        return self.baseURL.URLByAppendingPathComponent(self.path).absoluteString
    }
    var requestEndpoint: Endpoint<BaseRouter> {
        let endPoint = Endpoint<BaseRouter>(URL: fullURL, sampleResponseClosure: {.NetworkResponse(200, self.sampleData)}, method: method, parameters: parameters, parameterEncoding: parameterEncoding, httpHeaderFields: headerFields)
        return endPoint
    }
    var limit: Int?
    var skip: Int?
    var networkRetryAttempts: Int = 5
    
    func parseResponse(json: JSON) -> AnyObject? {
        return DataModel(byJSON: json["request_data_result"]) as? AnyObject
    }
}

extension BaseRouter {
    
    func request(provider: Provider = Provider.defaultInstance(), attempts: Int = 0, completion: (APIResult<AnyObject>) -> ()) -> Cancellable? {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        return provider.request(self) { result in
            var apiResult: APIResult<AnyObject>?
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            switch result {
            case let .Success(response):
                let json = response.mapSwiftyJSON()
                if self.status(json) == true {
                    apiResult = APIResult.Ok
                    
                    if let entity = self.parseResponse(json) {
                        apiResult = APIResult.Success(entity)
                    }
                } else {
                    if let errorMessages = json["request_data_result"].arrayObject as? [String] {
                        if errorMessages.count > 0 {
                            apiResult = APIResult.Failure(APIError(statusCode: response.statusCode, message: errorMessages[0]))
                        } else {
                            apiResult = APIResult.Failure(APIError(statusCode: response.statusCode, message: "The request failed. Please try again. Make sure that you are connected internet."))
                        }
                    } else if let errorMessage = json["request_data_result"].string {
                        apiResult = APIResult.Failure(APIError(statusCode: response.statusCode, message: errorMessage))
                    } else {
                        if attempts < self.networkRetryAttempts {
                            let delayInSeconds = 1.0
                            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
                            dispatch_after(delay, dispatch_get_main_queue()) {
                                let nextAttempts = attempts + 1
                                self.request(attempts: nextAttempts, completion: completion)
                            }
                        } else {
                            apiResult = APIResult.Failure(APIError(statusCode: response.statusCode, message: "The request failed. Please try again. Make sure that you are connected internet."))
                        }
                    }
                }
            case let .Failure(error):
                if attempts < self.networkRetryAttempts {
                    let delayInSeconds = 1.0
                    let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
                    dispatch_after(delay, dispatch_get_main_queue()) {
                        let nextAttempts = attempts + 1
                        self.request(attempts: nextAttempts, completion: completion)
                    }
                } else {
                    apiResult = .NetworkError(error)
                }
            }
            
            if let apiResult = apiResult {
                completion(apiResult)
            }
        }
    }
    
    func requestFullData(provider: Provider = Provider.defaultInstance(), attempts: Int = 0, completion: (APIResult<AnyObject>) -> ()) -> Cancellable? {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        return provider.request(self) { result in
            var apiResult: APIResult<AnyObject>?
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            switch result {
            case let .Success(response):
                if let dataString = NSString(data: response.data, encoding: NSUTF8StringEncoding) {
                    apiResult = APIResult.Success(dataString)
                } else {
                    apiResult = APIResult.Failure(APIError(statusCode: response.statusCode, message: "The request failed. Please try again. Make sure that you are connected internet."))
                }
                
            case let .Failure(error):
                if attempts < self.networkRetryAttempts {
                    let delayInSeconds = 1.0
                    let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
                    dispatch_after(delay, dispatch_get_main_queue()) {
                        let nextAttempts = attempts + 1
                        self.requestFullData(attempts: nextAttempts, completion: completion)
                    }
                } else {
                    apiResult = .NetworkError(error)
                }
            }
            
            if let apiResult = apiResult {
                completion(apiResult)
            }
        }
    }
    
    private func status(json: JSON) -> Bool {
        if let status = json["status"].string {
            return status.toBool()
        }
        
        if let status = json["status"].int {
            return status.toBool()
        }
        
        return false
    }
}
