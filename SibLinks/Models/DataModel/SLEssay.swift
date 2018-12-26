//
//  SLEssay.swift
//  SibLinks
//
//  Created by ANHTH on 9/15/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import SwiftyJSON

enum EssayStatus: String {
    case Wait = "W"
    case Progress = "P"
    case Reviewed = "R"
}

class SLEssay: DataModel {
    
    var title: String?
    var desc: String?
    var status: String?
    var mentor: SLMentor?
    var user: SLUser?
    var essay: String?
    var essayDownloaded: NSURL?
    var essayReviewDownloaded: NSURL?
    var fileName: String?
    var fileSize: Double?
    var comment: String?
    var essayReviewed: String?
    var fileReviewedName: String?
    var fileReviewedSize: Double?
    var reviewedAt: NSDate?
    var school: SLSchool?
    var major: SLMajor?
    
    override func mapping(json: JSON) {
        super.mapping(json)
        
        if json["uploadEssayId"].exists() {
            objectId = json["uploadEssayId"].intValue
        }
        
        if json["nameOfEssay"].exists() {
            title = json["nameOfEssay"].stringValue
        }
        
        if json["descriptionOfEssay"].exists() {
            desc = json["descriptionOfEssay"].stringValue
        }
        
        if json["docSubmittedDate"].exists() {
            updatedAt = json["docSubmittedDate"].stringValue.toDate()
        }
        
        if json["docSubmittedDate"].exists() {
            createdAt = json["docSubmittedDate"].stringValue.toDate()
        }
        
        if json["downloadYourEssay"].exists() {
            essay = json["downloadYourEssay"].stringValue
        } else if json["downloadLinkS"].exists() {
            essay = json["downloadLinkS"].stringValue
        }
        
        if json["urlFile"].exists() {
            fileName = json["urlFile"].stringValue
        }
        
        if json["odFilesize"].exists() {
            fileSize = json["odFilesize"].doubleValue
        }
        
        if json["STATUS"].exists() {
            status = json["STATUS"].stringValue
        } else if json["status"].exists() {
            status = json["status"].stringValue
        }
        
        if json["mentorComment"].exists() {
            comment = json["mentorComment"].stringValue
        }
        
        if json["downloadLinkM"].exists() {
            essayReviewed = json["downloadLinkM"].stringValue
        }
        
        if json["urlReview"].exists() {
            fileReviewedName = json["urlReview"].stringValue
        }
        
        if json["rdFilesize"].exists() {
            fileReviewedSize = json["rdFilesize"].doubleValue
        }
        
        if json["docReviewedDate"].exists() && json["docReviewedDate"] != nil {
            reviewedAt = json["docReviewedDate"].stringValue.toDate()
        } else {
            reviewedAt = json["timestamp"].stringValue.toDate()
        }
        
        mentor = SLMentor(byJSON: json)
        user = SLUser(byJSON: json)
        school = SLSchool(byJSON: json)
        major = SLMajor(byJSON: json)
    }
}
