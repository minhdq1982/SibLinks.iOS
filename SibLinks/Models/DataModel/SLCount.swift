//
//  SLCount.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/4/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import SwiftyJSON

class SLCount: DataModel {
    
    var numberOfQuestion: Int?
    var mentorAnswered: Int?
    var mentorSubcribed: Int?
    var mentorVideos: Int?
    var userVideoLike: Int?
    var userVideoWatched: Int?
    
    override func mapping(json: JSON) {
        super.mapping(json)
        
        if json["numquestion"].exists() {
            numberOfQuestion = json["numquestion"].intValue
        }
        
        if json["answered"].exists() {
            mentorAnswered = json["answered"].intValue
        }
        
        if json["subcribed"].exists() {
            mentorSubcribed = json["subcribed"].intValue
        }
        
        if json["videos"].exists() {
            mentorVideos = json["videos"].intValue
        }
        
        if json["video_watched"].exists() {
            userVideoLike = json["video_watched"].intValue
        }
        
        if json["video_like"].exists() {
            userVideoWatched = json["video_like"].intValue
        }
    }
}
