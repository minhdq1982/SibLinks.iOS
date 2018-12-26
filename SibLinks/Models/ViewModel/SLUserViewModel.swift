//
//  SLUserViewModel.swift
//  SibLinks
//
//  Created by Jana on 9/19/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import UIKit
import Moya

class SLUserViewModel: SLBaseViewModel {

    static let sharedInstance = SLUserViewModel()
    
    var currentUser: SLSaveUser? {
        
        set {
            if let currentUser = newValue {
                let encodeUser = NSKeyedArchiver.archivedDataWithRootObject(currentUser)
                NSUserDefaults.standardUserDefaults().setObject(encodeUser, forKey: Constants.kUser)
            }
        }
        
        get {
            if NSUserDefaults.standardUserDefaults().objectForKey(Constants.kUser) != nil {
                let data = NSUserDefaults.standardUserDefaults().objectForKey(Constants.kUser) as! NSData
                if let objects = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? SLSaveUser {
                    return objects
                }
            }
            return nil
        }
    }
}

extension SLUserViewModel {
    
    // MARK: - Sign In
    func signInWithEmail(email: String, password: String, success: (() -> Void)?, failure: ((APIError?) -> Void)?, networkFailure: ((Moya.Error?) -> Void)?) {
        UserRouter(endpoint: UserEndpoint.SignInWithEmail(email: email, password: password)).request { (result) in
            switch result {
            case .Success(let object):
                if let data = object as? SLUser {
                    Constants.appDelegate().getCategories()
                    self.currentUser = SLSaveUser(user: data)
                    SLLocalDataManager.sharedInstance.refreshDataWhenSwitchUser()
                    success?()
                } else {
                    failure?(nil)
                }
            case .Failure(let error):
                failure?(error)
            case .NetworkError(let error):
                networkFailure?(error)
            default:
                failure?(nil)
            }
        }
    }
    
    // MARK: - Sign Up
    func signUpWithEmail(email: String, password: String, firstname: String, lastname: String, highSchool: String, success: (() -> Void)?, failure: ((APIError?) -> Void)?, networkFailure: ((Moya.Error?) -> Void)?) {
        UserRouter(endpoint: UserEndpoint.SignUpWithEmail(email: email, password: password, firstname: firstname, lastname: lastname, highSchool: highSchool)).request { (result) in
            switch result {
            case .Ok:
                success?()
            case .Failure(let error):
                failure?(error)
            case .NetworkError(let error):
                networkFailure?(error)
            default:
                failure?(nil)
            }
        }
    }
    
    // MARK: - Sign In with Facebook
    func signInWithFacebook(email: String, firstname: String, lastname: String, facebookId: String, success: (() -> Void)?, failure: ((APIError?) -> Void)?, networkFailure: ((Moya.Error?) -> Void)?) {
        UserRouter(endpoint: UserEndpoint.SignInWithFacebook(email: email, firstname: firstname, lastname: lastname, facebookId: facebookId)).request { (result) in
            switch result {
            case .Success(let objects):
                if let result = objects as? [SLUser] {
                    if result.count > 0 {
                        Constants.appDelegate().getCategories()
                        self.currentUser = SLSaveUser(user: result[0])
                        SLLocalDataManager.sharedInstance.refreshDataWhenSwitchUser()
                        success?()
                    } else {
                        failure?(nil)
                    }
                } else {
                    failure?(nil)
                }
            case .Failure(let error):
                failure?(error)
            case .NetworkError(let error):
                networkFailure?(error)
            default:
                failure?(nil)
            }
        }
    }
    
    // MARK: - Sign In with Google
    func signInWithGooglePlus(email: String, firstname: String, lastname: String, googleId: String, image: String, success: (() -> Void)?, failure: ((APIError?) -> Void)?, networkFailure: ((Moya.Error?) -> Void)?) {
        UserRouter(endpoint: UserEndpoint.SignInWithGooglePlus(email: email, firstname: firstname, lastname: lastname, googleID: googleId, image: image)).request { (result) in
            switch result {
            case .Success(let objects):
                if let result = objects as? [SLUser] {
                    if result.count > 0 {
                        Constants.appDelegate().getCategories()
                        self.currentUser = SLSaveUser(user: result[0])
                        SLLocalDataManager.sharedInstance.refreshDataWhenSwitchUser()
                        success?()
                    }
                } else {
                    failure?(nil)
                }
            case .Failure(let error):
                failure?(error)
            case .NetworkError(let error):
                networkFailure?(error)
            default:
                failure?(nil)
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut(success: (() -> Void)?, failure: ((APIError?) -> Void)?, networkFailure: ((Moya.Error?) -> Void)?) {
        UserRouter(endpoint: UserEndpoint.SignOut()).request { (result) in
            switch result {
            case .Ok:
                success?()
                break
            case .Failure(let error):
                failure?(error)
            case .NetworkError(let error):
                networkFailure?(error)
            default:
                failure?(nil)
            }
        }
    }
    
    // MARK: - Forgot password
    func forgotPassword(email: String, success: (() -> Void)?, failure: ((APIError?) -> Void)?, networkFailure: ((Moya.Error?) -> Void)?) {
        UserRouter(endpoint: UserEndpoint.ForgotPassword(email: email)).request { (result) in
            switch result {
            case .Ok:
                success?()
            case .Failure(let error):
                failure?(error)
            case .NetworkError(let error):
                networkFailure?(error)
            default:
                failure?(nil)
            }
        }
    }
    
    // MARK: - Get profile
    func getProfileWithUserId(userId: Int, success: ((SLUser?) -> Void)?, failure: ((APIError?) -> Void)?, networkFailure: ((Moya.Error?) -> Void)?) {
        UserRouter(endpoint: UserEndpoint.GetUserProfile(userId: userId, type: UserType.Student)).request { (result) in
            switch result {
            case .Success(let object):
                if let user = object as? SLUser {
                    self.currentUser = SLSaveUser(user: user)
                    success?(user)
                } else {
                    failure?(nil)
                }
            case .Failure(let error):
                failure?(error)
            case .NetworkError(let error):
                networkFailure?(error)
            default:
                failure?(nil)
            }
        }
    }
    
    // MARK: - Update profile
    func updateProfileWithUser(user: SLUser, success: (() -> Void)?, failure: ((APIError?) -> Void)?, networkFailure: ((Moya.Error?) -> Void)?) {
        UserRouter(endpoint: UserEndpoint.UpdateProfileWithUser(user: user)).request { (result) in
            switch result {
            case .Success(let status):
                if let status = status as? Bool {
                    if status {
                        success?()
                    } else {
                        failure?(nil)
                    }
                } else {
                    failure?(nil)
                }
            case .Failure(let error):
                failure?(error)
            case .NetworkError(let error):
                networkFailure?(error)
            case .Ok:
                success?()
            }
        }
    }
    
    // MARK: - Upload avatar
    func uploadAvatar(user: SLUser, avatarImage: UIImage, success: (() -> Void)?, failure: ((APIError?) -> Void)?, networkFailure: ((Moya.Error?) -> Void)?) {
        UserRouter(endpoint: UserEndpoint.UploadAvatar(user: user, avatarImage: avatarImage)).request { (result) in
            switch result {
            case .Ok:
                success?()
            case .Failure(let error):
                failure?(error)
            case .NetworkError(let error):
                networkFailure?(error)
            default:
                failure?(nil)
            }
        }
    }
    
    // MARK: - Subscriber
    func checkSubscriber(mentorId: Int, success: ((Bool) -> Void)?, failure: ((APIError?) -> Void)?, networkFailure: ((Moya.Error?) -> Void)?) {
        UserRouter(endpoint: UserEndpoint.CheckSubscriber(studentId: (self.currentUser?.userId)!, mentorId: mentorId)).request { (result) in
            switch result {
            case .Success(let status):
                success?(status as! Bool)
            case .Failure(let error):
                failure?(error)
            case .NetworkError(let error):
                networkFailure?(error)
            default:
                failure?(nil)
            }
        }
    }
    
    func changeSubscriber(mentorId: Int, success: (() -> Void)?, failure: ((APIError?) -> Void)?, networkFailure: ((Moya.Error?) -> Void)?) {
        UserRouter(endpoint: UserEndpoint.Subscriber(studentId: (self.currentUser?.userId)!, mentorId: mentorId)).request { (result) in
            switch result {
            case .Success(let objects):
                if let mentor = objects as? SLMentor {
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.SUBSCRIBER_CHANGE, object: mentor.isSubscriber)
                    success?()
                } else {
                    failure?(nil)
                }
            case .Failure(let error):
                failure?(error)
            case .NetworkError(let error):
                networkFailure?(error)
            default:
                failure?(nil)
            }
        }
    }
}
