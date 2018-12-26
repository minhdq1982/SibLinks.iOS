//
//  SLMentor.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/5/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import SwiftyJSON

class SLMentor: DataModel {
    
    var username: String?
    var firstname: String?
    var lastname: String?
    var profileImageName: String?
    var subscribers: Int?
    var totalVideo: Int?
    var school: String?
    var categories: [SLCategory]?
    var numberLike: Int?
    var numberAnswer: Int?
    var numberVideo: Int?
    var numberRate: Int?
    var averageRate: Float?
    var isSubscriber: Bool?
    var categoriesId: String?
    
    override func mapping(json: JSON) {
        super.mapping(json)
        
        if json["userid"].exists() {
            objectId = json["userid"].intValue
        } else if json["MentorId"].exists() {
            objectId = json["MentorId"].intValue
        } else if json["authorID"].exists() {
            objectId = json["authorID"].intValue
        } else if json["authorId"].exists() {
            objectId = json["authorId"].intValue
        } else if json["mentorID"].exists() {
            objectId = json["mentorID"].intValue
        } else if json["mentorId"].exists() {
            objectId = json["mentorId"].intValue
        }
        
        if json["muserName"].exists() {
            username = json["muserName"].stringValue
        } else if json["userName"].exists() {
            username = json["userName"].stringValue
        } else if json["loginName"].exists() {
            username = json["loginName"].stringValue
        } else if json["username"].exists() {
            username = json["username"].stringValue
        }
        
        if json["mfirstName"].exists() {
            firstname = json["mfirstName"].stringValue
        } else if json["firstName"].exists() {
            firstname = json["firstName"].stringValue
        } else if json["mentorName"].exists() {
            firstname = json["mentorName"].stringValue
        } else if json["name"].exists() {
            firstname = json["name"].stringValue
        } else if json["userName"].exists() {
            firstname = json["userName"].stringValue
        } else if json["firstname"].exists() {
            firstname = json["firstname"].stringValue
        }
        
        if json["mlastName"].exists() {
            lastname = json["mlastName"].stringValue
        } else if json["lastName"].exists() {
            lastname = json["lastName"].stringValue
        } else if json["lastName"].exists() {
            lastname = json["lastname"].stringValue
        }
        
        if json["mavatar"].exists() {
            profileImageName = json["mavatar"].stringValue
        } else if json["imageUrl"].exists() {
            profileImageName = json["imageUrl"].stringValue
        } else if json["avatar"].exists() {
            profileImageName = json["avatar"].stringValue
        }
        
        if json["numsub"].exists() {
            subscribers = json["numsub"].intValue
        } else if json["count_subscribers"].exists() {
            subscribers = json["count_subscribers"].intValue
        }
        
        if json["totalVideo"].exists() {
            totalVideo = json["totalVideo"].intValue
        }
        
        if json["numVideos"].exists() {
            numberVideo = json["numVideos"].intValue
        } else if json["count_videos"].exists() {
            numberVideo = json["count_videos"].intValue
        }
        
        if json["numlike"].exists() {
            numberLike = json["numlike"].intValue
        } else if json["count_likes"].exists() {
            numberLike = json["count_likes"].intValue
        }
        
        if json["numRatings"].exists() {
            numberRate = json["numRatings"].intValue
        }
        
        if json["numAnswers"].exists() {
            numberAnswer = json["numAnswers"].intValue
        } else if json["count_answers"].exists() {
            numberAnswer = json["count_answers"].intValue
        }
        
        if json["avgrate"].exists() {
            averageRate = json["avgrate"].floatValue
        }
        
        if json["schoolName"].exists() {
            school = json["schoolName"].stringValue
        } else if json["accomplishments"].exists() {
            school = json["accomplishments"].stringValue
        }
        
        if json["defaultSubjectId"].exists() {
            categoriesId = json["defaultSubjectId"].stringValue
        }
        
        if json["isSubs"].exists() {
            isSubscriber = json["isSubs"].boolValue
        }
    }
    
    func name() -> String {
        var fullname = ""
        if let firstname = firstname {
            fullname += firstname
        }
        
        if let lastname = lastname {
            fullname += fullname.characters.count > 0 ? " " + lastname : lastname
        }
        
        if fullname.characters.count == 0 {
            if let username = username {
                var name = username
                if username.isEmail() {
                    name = username.getUsernameFromEmail()
                }
                fullname = name
            }
        }
        
        return fullname
    }
}
