//
//  MentorRouter.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/17/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

enum MentorType: String {
    case Subscribe = "subs"
    case Rate = "rate"
    case Like = "like"
}

enum MentorEndpoint {
    case GetMentor(userId: Int, subjectId: Int, type: MentorType, search: String)
    case GetAnswers(mentorId: Int)
}

class MentorRouter: BaseRouter {
    
    var endpoint: MentorEndpoint
    
    init(endpoint: MentorEndpoint) {
        self.endpoint = endpoint
    }
    
    override var parameterEncoding: Moya.ParameterEncoding {
        return .URLEncodedInURL
    }
    
    override var path: String {
        switch endpoint {
        case .GetAnswers(_):
            return "/siblinks/services/mentor/getNewestAnswers"
        case .GetMentor(_):
            return "/siblinks/services/mentor/getTopMentorsByLikeRateSubcrible"
        }
    }
    
    override var method: Moya.Method {
        return .GET
    }
    
    override var parameters: [String: AnyObject]? {
        switch endpoint {
        case .GetAnswers(let mentorId):
            return ["authorId": mentorId, "limit": limit ?? Constants.LIMIT_DEFAULT_NUMBER, "offset": skip ?? 0]
        case .GetMentor(let userId, let subjectId, let type, let search):
            return ["uid": userId, "subjectId": (subjectId == -1) ? "" : "\(subjectId)", "type": type.rawValue, "content": search, "limit": limit ?? 0, "offset": skip ?? 0]
        }
    }
    
    override var sampleData: NSData {
        return NSData()
    }
    
    override var multipartBody: [MultipartFormData]? {
        return nil
    }
        
    override func parseResponse(json: JSON) -> AnyObject? {
//        logger.info("JSON - MentorRouter: \(json)")
        switch endpoint {
        case .GetAnswers(_):
            return [SLAnswer](byJSON: json["request_data_result"])
        default:
            return [SLMentor](byJSON: json["request_data_result"])
        }
    }
}
