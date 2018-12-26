//
//  UserRouter.swift
//  SibLinks
//
//  Created by Jana on 9/19/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import FirebaseInstanceID

enum UserType {
    case Student
    case Mentor
}

enum UserEndpoint {
    case SignInWithEmail(email: String, password: String)
    case SignUpWithEmail(email: String, password: String, firstname: String, lastname: String, highSchool: String)
    case SignInWithFacebook(email: String, firstname: String, lastname: String, facebookId: String)
    case SignInWithGooglePlus(email: String, firstname: String, lastname: String, googleID: String, image: String)
    case SignOut()
    case ForgotPassword(email: String)
    case GetUserProfile(userId: Int, type: UserType)
    case GetSubscribers(userId: Int)
    case UpdateProfileWithUser(user: SLUser)
    case UploadAvatar(user: SLUser, avatarImage: UIImage)
    case Subscriber(studentId: Int, mentorId: Int)
    case CheckSubscriber(studentId: Int, mentorId: Int)
    case GetTimeFromServer()
}

class UserRouter: BaseRouter {
    typealias DeserializedType = SLUser
    var endpoint: UserEndpoint
    
    init(endpoint: UserEndpoint) {
        self.endpoint = endpoint
    }
    
    override var parameterEncoding: Moya.ParameterEncoding {
        switch endpoint {
        case .SignInWithEmail(_:_):
            return .URLEncodedInURL
        case .SignUpWithEmail(_:_), .Subscriber(_:), .UploadAvatar(_:_), .UpdateProfileWithUser(_:), .ForgotPassword(_:), .SignInWithGooglePlus(_:_), .SignInWithFacebook(_:_):
            return .JSON
        default:
            return .URLEncodedInURL
        }
    }
    
    override var path: String {
        switch endpoint {
        case .SignInWithEmail(_:_):
            return "/siblinks/services/user/login"
        case .SignUpWithEmail(_:_):
            return "/siblinks/services/user/registerUser"
        case .SignInWithFacebook(_:_):
            return "/siblinks/services/user/loginFacebook"
        case .SignInWithGooglePlus(_:_):
            return "/siblinks/services/user/loginGoogle"
        case .SignOut():
            return "/siblinks/services/user/logout"
        case .ForgotPassword(_:):
            return "/siblinks/services/contact/forgotPassword"
        case .GetUserProfile(_:):
            return "/siblinks/services/user/getUserProfile"
        case .GetSubscribers(_:):
            return "/siblinks/services/student/getAllInfoMentorSubscribed"
        case .UpdateProfileWithUser(_:):
            return "/siblinks/services/user/updateUserProfile"
        case .UploadAvatar(_:):
            return "/siblinks/services/user/uploadAvatar"
        case .Subscriber(_:):
            return "/siblinks/services/video/setSubscribeMentor"
        case .CheckSubscriber(_):
            return "/siblinks/services/videodetail/checkSubscribe"
        case .GetTimeFromServer():
            return "/siblinks/services/timeDB"
        }
    }
    
    override var method: Moya.Method {
        switch endpoint {
        case .SignInWithEmail(_:_), .Subscriber(_:), .UploadAvatar(_:), .UpdateProfileWithUser(_:), .ForgotPassword(_:), .SignOut(), .SignInWithGooglePlus(_:_), .SignInWithFacebook(_:_), .SignUpWithEmail(_:_):
            return .POST
        default:
            return .GET
        }
    }
    
    override var parameters: [String: AnyObject]? {
        var params: [String: AnyObject]?
        
        switch endpoint {
        case .SignInWithEmail(let email, let password):
            params = ["username": email, "password": password, "token" : FIRInstanceID.instanceID().token() ?? "", "userType": "S"]
        case .SignUpWithEmail(let email, let password, let firstname, let lastname, let highSchool):
            params = ["username": email, "password": password, "firstname": firstname, "lastname": lastname, "highSchool": highSchool]
        case .SignInWithFacebook(let email, let firstname, let lastname, let facebookId):
            params = ["request_data_type": "user", "request_data_method": "loginFacebook", "request_data": ["username": email, "firstname": firstname, "lastname": lastname, "facebookid": facebookId, "image": "http://graph.facebook.com/\(facebookId)/picture?type=large", "usertype": "S", "token" : FIRInstanceID.instanceID().token() ?? ""]]
        case .SignInWithGooglePlus(let email, let firstname, let lastname, let googleId, let image):
            params = ["request_data_type": "user", "request_data_method": "loginGoogle", "request_data": ["username": email, "firstname": firstname, "lastname": lastname, "googleid": googleId, "image": image, "usertype": "S", "token" : FIRInstanceID.instanceID().token() ?? ""]]
        case .ForgotPassword(let email):
            params = ["request_data_type": "user", "request_data_method": "forgotPassword", "request_data": ["email": email]]
        case .GetUserProfile(let userId, _):
            params = ["userid": userId]
        case .GetSubscribers(let userId):
            params = ["studentId": userId, "limit": limit ?? Constants.LIMIT_DEFAULT_NUMBER, "offset": skip ?? 0]
        case .UpdateProfileWithUser(let user):
            let birthday = user.birthday?.monthAfterFormatterString() ?? ""
            let favorite = user.favoritesSubject()
            params = ["request_data_type": "user", "request_data_method": "updateUserProfile", "request_user": ["userid": "\(user.objectId!)", "firstName": user.firstname ?? "", "lastName": user.lastname ?? "", "school": user.school ?? "", "gender": user.gender ?? "", "defaultSubjectId": user.defaultSubjectId ?? "", "favorite": favorite, "bio": user.aboutMe ?? "", "role" : "S", "dob": birthday]]
        case .UploadAvatar(let user, _):
            params = ["userid": "\(user.objectId!)", "imageUrl": "\(user.imageUrl)"]
        case .Subscriber(let studentId, let mentorId):
            params = ["request_data_type": "subscribe", "request_data_method": "setSubscribeMentor", "request_data": ["studentId": studentId, "mentorId": mentorId]]
        case .CheckSubscriber(let studentId, let mentorId):
            params = ["mentorid" : mentorId, "studentid": studentId]
        default:
            return nil
        }
        
        return params
    }
    
    override var sampleData: NSData {
        return NSData()
    }
    
    override var multipartBody: [MultipartFormData]? {
        switch endpoint {
        case .UploadAvatar(_, let image):
            var multipartData = [MultipartFormData]()
            multipartData.append(MultipartFormData(provider: .Data(UIImageJPEGRepresentation(image, 0.7)!), name: "uploadfile", mimeType: "image/jpeg", fileName: "image.jpg"))
            
            return multipartData
            
        default:
            return nil
        }
    }
    
    override func parseResponse(json: JSON) -> AnyObject? {
//        logger.info("JSON - UserRouter: \(json)")
        switch endpoint {
        case .SignInWithEmail(_):
            return SLUser(byJSON: json)
        case .SignUpWithEmail(_):
            return nil
        case .SignInWithFacebook(_):
            return [SLUser](byJSON: json["request_data_result"])
        case .SignInWithGooglePlus(_):
            return [SLUser](byJSON: json["request_data_result"])
        case .SignOut():
            return nil
        case .ForgotPassword(_):
            return nil
        case .GetUserProfile(_, let type):
            switch type {
            case .Mentor:
                return SLMentor(byJSON: json["request_data_result"]) as? AnyObject
            default:
                return SLUser(byJSON: json["request_data_result"]) as? AnyObject
            }
        case .GetSubscribers(_):
            return [SLMentor](byJSON: json["request_data_result"])
        case .UpdateProfileWithUser(_):
            let result = json["request_data_result"]
            if result.stringValue == "Success" {
                return true
            }
            return false
        case .UploadAvatar(_):
            return nil
        case .Subscriber(_):
            return SLMentor(byJSON: json["request_data_result"]) as? AnyObject
        case .CheckSubscriber(_):
            let subscriber = json["request_data_result"][0]["isSubs"]
            return subscriber.boolValue
        case .GetTimeFromServer():
            return json as? AnyObject
        }
    }
    
}
