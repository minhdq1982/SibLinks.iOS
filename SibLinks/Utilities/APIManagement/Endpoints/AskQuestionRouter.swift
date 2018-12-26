//
//  AskRouter.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/16/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

enum AskQuestionEndpoint {
    case GetQuestions(userId: Int, subjectId: Int, orderType: OrderType)
    case GetQuestion(questionId: Int)
    case GetQuestionAnswer(userId: Int, questionId: Int)
    case PostQuestion(userId: Int, subjectId: Int, content: String, images: [UIImage])
    case GetCategories()
    case EditQuestion(questionId: Int, userId: Int, subjectId: Int, content: String, imagePath: String, editedImagePath: String, images: [UIImage])
    case DeleteQuestion(questionId: Int)
    case CountQuestion(userId: Int, subjectId: Int, orderType: OrderType)
    case LikeAnswer(userId: Int, answerId: Int)
}

class AskQuestionRouter: BaseRouter {
    var endpoint: AskQuestionEndpoint
    
    init(endpoint: AskQuestionEndpoint) {
        self.endpoint = endpoint
    }
    override var parameterEncoding: Moya.ParameterEncoding {
        switch endpoint {
        case .GetCategories(), .GetQuestion(_), .GetQuestionAnswer(_), .PostQuestion(_), .EditQuestion(_), .DeleteQuestion(_), .LikeAnswer(_):
            return .JSON
        default:
            return .URLEncodedInURL
        }
    }
    
    override var path: String {
        switch endpoint {
        case .GetQuestions(_):
            return "/siblinks/services/post/getPostListMobile"
        case .GetQuestion(_):
            return "/siblinks/services/post/getPostById"
        case .GetQuestionAnswer(_):
            return "/siblinks/services/post/getAnswerByQid"
        case .PostQuestion(_):
            return "/siblinks/services/post/createPost"
        case .GetCategories():
            return "/siblinks/services/subjects/getAllCategory"
        case .EditQuestion(_):
            return "/siblinks/services/post/editPost"
        case .DeleteQuestion(_):
            return "/siblinks/services/post/removePost"
        case .CountQuestion(_):
            return "/siblinks/services/post/countQuestions"
        case .LikeAnswer(_):
            return "/siblinks/services/like/likeAnswer"
        }
    }
    
    override var method: Moya.Method {
        switch endpoint {
        case .PostQuestion(_), .GetQuestion(_), .GetQuestionAnswer(_), .EditQuestion(_), .DeleteQuestion(_), .LikeAnswer(_):
            return .POST
        default:
            return .GET
        }
    }
    
    override var parameters: [String: AnyObject]? {
        switch endpoint {
            case .GetQuestions(let userId, let subjectId, let orderType):
                return ["uid": userId, "subjectid": subjectId, "limit": limit ?? Constants.LIMIT_DEFAULT_NUMBER, "offset": skip ?? 0, "orderType": "\(orderType)"]
            
            case .GetQuestion(let questionId):
                return ["request_data_type": "post", "request_data_method": "getPostById", "request_data": ["pid": questionId]]
            
            case .GetCategories():
                return nil
            
            case .GetQuestionAnswer(let userId, let questionId):
                return ["request_data_type": "post", "request_data_method": "getAnswerByQid", "request_data": ["pid": questionId, "limit": limit ?? Constants.LIMIT_DEFAULT_NUMBER, "offset": skip ?? 0, "uid": userId]]
            
            case .PostQuestion(let userId, let subjectId, let content, _):
                return ["userId": userId, "content": content, "subjectId": subjectId]
            
            case .EditQuestion(let questionId, let userId, let subjectId, let content, let imagePath, let editedImagePath, _):
                return ["qid": questionId, "userId": userId, "content": content, "subjectId": subjectId, "oldImagePath" : imagePath, "oldImagePathEdited": editedImagePath]
            
            case .DeleteQuestion(let questionId):
                return ["request_data_type": "post", "request_data_method": "removePost", "request_data": ["pid": questionId]]
            
            case .CountQuestion(let userId, let subjectId, let orderType):
                return ["uid": userId, "subjectid": subjectId, "orderType": "\(orderType)"]
            
            case .LikeAnswer(let userId, let answerId):
                return ["request_data_type": "answer", "request_data_method": "likeAnswer", "request_data": ["authorID": userId, "aid": answerId]]
        }
    }
    
    override var sampleData: NSData {
        return NSData()
    }
    
    override var multipartBody: [MultipartFormData]? {
        switch endpoint {
        case .PostQuestion(_, _, _, let images):
            var multipartData = [MultipartFormData]()
            for image in images {
                multipartData.append(MultipartFormData(provider: .Data(UIImageJPEGRepresentation(image, 0.7)!), name: "file", mimeType: "image/jpeg", fileName: "image.jpg"))
            }
            
            if multipartData.count == 0 {
                multipartData.append(MultipartFormData(provider: .Data(NSData()), name: "test"))
            }
            return multipartData
            
        case .EditQuestion(_, _, _, _, _, _, let images):
            var multipartData = [MultipartFormData]()
            for image in images {
                multipartData.append(MultipartFormData(provider: .Data(UIImageJPEGRepresentation(image, 0.7)!), name: "file", mimeType: "image/jpeg", fileName: "image.jpg"))
            }
            
            if multipartData.count == 0 {
                multipartData.append(MultipartFormData(provider: .Data(NSData()), name: "test"))
            }
            return multipartData
            
        default:
            return nil
        }
    }
        
    override func parseResponse(json: JSON) -> AnyObject? {
//        logger.info("JSON - AskQuestionRouter: \(json)")
        switch endpoint {
        case .GetQuestions(_):
            return [SLQuestion](byJSON: json["request_data_result"])
        case .GetQuestion(_):
            return [SLQuestion](byJSON: json["request_data_result"])
        case .GetQuestionAnswer(_):
            return [SLAnswer](byJSON: json["request_data_result"])
        case .PostQuestion(_):
            return json["request_data_result"].intValue
        case .GetCategories():
            return [SLCategory](byJSON: json["request_data_result"])
        case .EditQuestion(_):
            return json["request_data_result"] as? AnyObject
        case .DeleteQuestion(_):
            return json["request_data_result"].boolValue
        case .CountQuestion(_):
            return [SLCount](byJSON: json["request_data_result"])
        default:
            return nil
        }
    }
    
}
