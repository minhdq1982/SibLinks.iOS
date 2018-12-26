//
//  SLTrackingEvent.swift
//  SibLinks
//
//  Created by Jana on 11/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import Crashlytics

class SLTrackingEvent: NSObject {
    
    static let sharedInstance = SLTrackingEvent()
    
    // Screen name
    static let kSLSignInScreen                  = "SignInScreen"
    static let kSLSignUpScreen                  = "SignUpScreen"
    static let kSLForgotPasswordScreen          = "ForgotPasswordScreen"
    static let kSLAskAQuestionScreen            = "AskAQuestionScreen"
    static let kSLUploadEssayScreen             = "UploadEssayScreen"
    static let kSLMentorProfileScreen           = "MentorProfileScreen"
    static let kSLVideoDetailScreen             = "VideoDetailScreen"
    static let kSLSubscriptionsScreen           = "SubscriptionsScreen"
    
    
    private let tracker = GAI.sharedInstance().defaultTracker
    private func sendEventName(eventName: String) {
        tracker.send(GAIDictionaryBuilder.createEventWithCategory("", action: "", label: "", value: nil).build() as [NSObject : AnyObject])
    }
    
    private func sendScreenName(screenName: String) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIDescription, value: screenName)
        let eventTracker: NSObject = GAIDictionaryBuilder.createScreenView().build()
        tracker.send(eventTracker as! [NSObject : AnyObject])
    }
    
    // MARK: - Public methods
    // Send event name
    func sendSignInWithEmailEvent(screenName: String) {
        self.sendEventName("Sign In With Email")
        Answers.logCustomEventWithName("Sign In With Email", customAttributes: nil)
    }
    
    func sendSignInWithFacebookEvent(screenName: String) {
        self.sendEventName("Sign In With Facebook")
        Answers.logCustomEventWithName("Sign In With Facebook", customAttributes: nil)
    }
    
    func sendSignInWithGooglePlusEvent(screenName: String) {
        self.sendEventName("Sign In With Google Plus")
        Answers.logCustomEventWithName("Sign In With Google Plus", customAttributes: nil)
    }
    
    func sendSignUpWithEmailEvent(screenName: String) {
        self.sendEventName("Sign Up With Email")
        Answers.logCustomEventWithName("Sign Up With Email", customAttributes: nil)
    }
    
    func sendForgotPasswordEvent(screenName: String) {
        self.sendEventName("Forgot Password")
        Answers.logCustomEventWithName("Forgot Password", customAttributes: nil)
    }
    
    func sendAskAQuestionEvent(screenName: String) {
        self.sendEventName("Ask A Question")
        Answers.logCustomEventWithName("Ask A Question", customAttributes: nil)
    }
    
    func sendEditAQuestionEvent(screenName: String) {
        self.sendEventName("Edit A Question")
        Answers.logCustomEventWithName("Edit A Question", customAttributes: nil)
    }
    
    func sendSubmitEssayEvent(screenName: String) {
        self.sendEventName("Submit Essay")
        Answers.logCustomEventWithName("Submit Essay", customAttributes: nil)
    }
    
    func sendSubscribeMentorEvent(screenName: String) {
        self.sendEventName("Subscribe Mentor")
        Answers.logCustomEventWithName("Subscribe Mentor", customAttributes: nil)
    }
    
    func sendUnsubscribeMentorEvent(screenName: String) {
        self.sendEventName("Unsubscribe Mentor")
        Answers.logCustomEventWithName("Unsubscribe Mentor", customAttributes: nil)
    }
}
