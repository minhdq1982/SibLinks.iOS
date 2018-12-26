//
//  EssayRouter.swift
//  SibLinks
//
//  Created by ANHTH on 9/15/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

enum EssayEndpoint {
    case GetEssays(userId: Int)
    case UploadEssay(userId: Int, title: String, content: String, majorId: Int, schoolId: Int, fileName: String, file: NSData)
    case GetAdmission()
    case GetArticles(admissonId: Int)
    case CheckUserRateArticle(userId: Int, admissonId: Int)
    case RateArticleAdmission(userId: Int, articleId: Int, rating: Int)
    case GetTutorialVideos(admissonId: Int)
    case GetSchool()
    case GetSubject()
    case GetEssay(essayId: Int)
    case CheckRateEssay(userId: Int, essayUploadId: Int)
    case RateEssay(userId: Int, uploadEssayId: Int, rating: Int)
    case RemoveEssay(essayId: Int)
    case UpdateEssay(userId: Int, essayId: Int, title: String, content: String, majorId: Int, schoolId: Int, fileName: String?, file: NSData?)
}

class EssayRouter: BaseRouter {
    var endpoint: EssayEndpoint
    
    init(endpoint: EssayEndpoint) {
        self.endpoint = endpoint
    }
        
    override var parameterEncoding: Moya.ParameterEncoding {
        switch endpoint {
        case .GetSchool(), .GetSubject(), .UploadEssay(_), .RemoveEssay(_), .UpdateEssay(_), .RateEssay(_):
            return .JSON
        default:
            return .URLEncodedInURL
        }
    }
    
    override var path: String {
        switch endpoint {
        case .GetEssays(_):
            return "/siblinks/services/essay/getEssayByStudentId"
        case .GetAdmission():
            return "/siblinks/services/admission/getAdmission"
        case .GetArticles(_):
            return "/siblinks/services/article/getArticleAdmission"
        case .CheckUserRateArticle(let userId, let admissonId):
            return "/siblinks/services/article/getUserRateArticle/\(userId)/\(admissonId)"
        case .RateArticleAdmission(_):
            return "/siblinks/services/article/rateArticleAdmission"
        case .GetTutorialVideos(_):
            return "/siblinks/services/videoAdmission/getVideoTuttorialAdmission"
        case .GetSchool():
            return "/siblinks/services/user/collegesOrUniversities"
        case .GetSubject():
            return "/siblinks/services/user/listOfMajors"
        case .UploadEssay(_):
            return "/siblinks/services/essay/uploadEssayStudent"
        case .GetEssay(_):
            return "/siblinks/services/essay/getEssayById"
        case .CheckRateEssay(let userId, let essayUploadId):
            return "siblinks/services/essay/getUserRateEssay/\(userId)/\(essayUploadId)"
        case .RateEssay(_):
            return "/siblinks/services/essay/rateEssay"
        case .RemoveEssay(_):
            return "/siblinks/services/essay/removeEssay"
        case .UpdateEssay(_):
            return "/siblinks/services/essay/updateEssayStudent"
        }
    }
    
    override var method: Moya.Method {
        switch endpoint {
        case .GetSchool(), .GetSubject(), .UploadEssay(_), .RateEssay(_), .RemoveEssay(_), .UpdateEssay(_), .RateArticleAdmission(_):
            return .POST
        default:
            return .GET
        }
    }
    
    override var headerFields: [String:String]? {
        switch endpoint {
        case .UpdateEssay(_):
            return nil
        default:
            return ["Content-Type": "application/json"]
        }
    }
    
    override var parameters: [String: AnyObject]? {
        switch endpoint {
        case .GetEssays(let userId):
            return ["userId": userId, "limit": limit ?? Constants.LIMIT_DEFAULT_NUMBER, "offset": skip ?? 0, "totalCountFlag": "true"]
        case .GetArticles(let admissionId):
            return ["idAdmission": admissionId]
        case .CheckUserRateArticle(_):
            return nil
        case .RateArticleAdmission(let userId, let articleId, let rating):
            return ["request_data_type": "addmission", "request_data_method": "rateVideoAddmission", "request_data_article": ["uid": userId, "arId": articleId, "rating": rating]]
        case .GetTutorialVideos(let admissionId):
            return ["idAdmission": admissionId]
        case .GetSchool():
            return ["request_data_type": "POST", "request_data_method": "collegesOrUniversities", "request_data":["":""]]
        case .GetSubject():
            return ["request_data_type": "POST", "request_data_method": "listOfMajors", "request_data":["":""]]
        case .UploadEssay(let userId, let title, let content, let majorId, let schoolId, let fileName, _):
            return ["userId": userId, "title": title, "desc": content, "majorId": majorId, "schoolId": schoolId, "fileName": fileName]
        case .UpdateEssay(let userId, let essayId, let title, let content, let majorId, let schoolId, let fileName, _):
            if let fileName = fileName {
                return ["userId": userId, "essayId": essayId, "title": title, "desc": content, "majorId": majorId, "schoolId": schoolId, "fileName": fileName]
            } else {
                return ["userId": userId, "essayId": essayId, "title": title, "desc": content, "majorId": majorId, "schoolId": schoolId]
            }
        case .GetEssay(let essayId):
            return ["essayId": "\(essayId)"]
        case .RateEssay(let userId, let uploadEssayId, let rating):
            return ["uid": userId, "uploadEssayId": uploadEssayId,"rating": rating]
        case .RemoveEssay(let essayId):
            return ["request_data_type": "POST", "request_data_method": "removeEssay", "request_data":["essayId": essayId]]
        default:
            return nil
        }
    }
    
    override var sampleData: NSData {
        return NSData()
    }
    override var multipartBody: [MultipartFormData]? {
        switch endpoint {
        case .UploadEssay(_, _, _, _, _, let fileName, let file):
            var multipartData = [MultipartFormData]()
            multipartData.append(MultipartFormData(provider: .Data(file), name: "file", mimeType: "", fileName: fileName))
            
            return multipartData
        case .UpdateEssay(_, _, _, _, _, _, let fileName, let file):
            if let fileName = fileName, let file = file {
                var multipartData = [MultipartFormData]()
                multipartData.append(MultipartFormData(provider: .Data(file), name: "file", mimeType: "", fileName: fileName))
                
                return multipartData
            } else {
                var multipartData = [MultipartFormData]()
                multipartData.append(MultipartFormData(provider: .Data(NSData()), name: "test"))
                return multipartData
            }
        default:
            return nil
        }
    }

    override func parseResponse(json: JSON) -> AnyObject? {
//        logger.info("JSON - EssayRouter: \(json)")
        switch endpoint {
        case .GetArticles(_):
            return [SLArticle](byJSON: json["request_data_result"])
        case .CheckUserRateArticle(_):
            let value = json["request_data_result"][0]["rating"].intValue
            return value
        case .RateArticleAdmission(_):
            return json as? AnyObject
        case .GetTutorialVideos(_):
            return [SLVideo](byJSON: json["request_data_result"])
        case .GetSchool():
            return [SLSchool](byJSON: json["request_data_result"])
        case .GetSubject():
            return [SLMajor](byJSON: json["request_data_result"])
        case .UploadEssay(_):
            // Done
            let result = json["request_data_result"].stringValue
            var status = false
            if result == "Done" {
                status = true
            }
            return status
        case .UpdateEssay(_):
            // Done
            let result = json["request_data_result"].stringValue
            var status = false
            if result == "" || result == "Done" {
                status = true
            }
            return status
        case .CheckRateEssay(_):
            let value = json["request_data_result"][0]["rating"].intValue
            return value
        case .RateEssay(_):
            return json as? AnyObject
        case .RemoveEssay(_):
            let result = json["request_data_result"].stringValue
            var status = false
            if result == "Done" {
                status = true
            }
            
            return status
        default:
            return [SLEssay](byJSON: json["request_data_result"])
        }
    }
    
}
