//
//  NotificationRouter.swift
//  SibLinks
//
//  Created by Jana on 10/31/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON

enum NotificationEndpoint {
    case GetNotificationNotReaded(userId: Int)
    case GetNotificationReaded(userId: Int)
    case UpdateStatusNotification(notificationId: Int, status: Bool)
    case GetAllNotification(userId: Int, pageNo: Int, limit: Int)
    case UpdateStatusAllNotification(userId: Int)
}

class NotificationRouter: BaseRouter {
    
    var endpoint: NotificationEndpoint
    
    init(endpoint: NotificationEndpoint) {
        self.endpoint = endpoint
    }
    
    override var parameterEncoding: Moya.ParameterEncoding {
        switch endpoint {
        case .UpdateStatusNotification(_), .UpdateStatusAllNotification(_):
            return .JSON
        default:
            return .URLEncodedInURL
        }
    }
    
    override var path: String {
        switch endpoint {
        case .GetNotificationNotReaded(_):
            return "/siblinks/services/notification/getNotificationNotReaded"
        case .GetNotificationReaded(_):
            return "/siblinks/services/notification/getNotificationReaded"
        case .UpdateStatusNotification(_):
            return "/siblinks/services/notification/updateStatusNotification"
        case .GetAllNotification(_):
            return "/siblinks/services/notification/getAllNotification"
        case .UpdateStatusAllNotification(_):
            return "/siblinks/services/notification/updateStatusAllNotification"
        }
    }
    
    override var method: Moya.Method {
        switch endpoint {
        case .UpdateStatusNotification(_), .UpdateStatusAllNotification(_):
            return .POST
        default:
            return .GET
        }
    }
    
    override var parameters: [String: AnyObject]? {
        switch endpoint {
        case .GetNotificationNotReaded(let userId):
            return ["uid": "\(userId)"]
        case .GetNotificationReaded(_):
            return nil
        case .UpdateStatusNotification(let notificationId, let status):
            return ["request_data_type": "mentor",
                    "request_data_method": "getTopMentorsByLikeRateSubcrible",
                    "request_data": [
                        "nid": notificationId,
                        "status": (status == true) ? "Y" : "N"
                    ]]
        case .GetAllNotification(let userId, let pageNo, let limit):
            return ["uid": userId, "pageno": pageNo, "limit": limit]
        case .UpdateStatusAllNotification(let userId):
            return ["uid": userId]
        }
    }
    
    override var sampleData: NSData {
        return NSData()
    }
    
    override var multipartBody: [MultipartFormData]? {
        return nil
    }
    
    override func parseResponse(json: JSON) -> AnyObject? {
        logger.info("JSON - NotificationRouter: \(json)")
        switch endpoint {
        case .GetNotificationNotReaded(_):
            let result = json["count"].intValue
            return result
        case .GetNotificationReaded(_):
            return nil
        case .UpdateStatusNotification(_):
            return nil
        case .GetAllNotification(_):
            return [SLNotification](byJSON: json["request_data_result"])
        case .UpdateStatusAllNotification(_):
            return nil
        }
    }
}
