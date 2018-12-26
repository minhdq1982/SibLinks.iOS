//
//  SLPlaylist.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/6/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import SwiftyJSON

class SLPlaylist: DataModel {
    
    var name: String?
    var videos: [SLVideo]?
    var thumbnailImageName: String?
    var numberOfVideo: Int?
    var numberOfLike: Int?
    var numberOfView: Int?
    var numberOfComment: Int?
    var numberOfRate: Int?
    var mentor: SLMentor?
    
    override func mapping(json: JSON) {
        super.mapping(json)
        
        if json["plid"].exists() {
            objectId = json["plid"].intValue
        } else if json["pid"].exists() {
            objectId = json["pid"].intValue
        }
        
        if json["name"].exists() {
            name = json["name"].stringValue
        } else if json["title"].exists() {
            name = json["title"].stringValue
        }
        
        if json["numVideos"].exists() {
            numberOfVideo = json["numVideos"].intValue
        }
        
        if json["numLike"].exists() {
            numberOfLike = json["numLike"].intValue
        }
        
        if json["numView"].exists() {
            numberOfView = json["numView"].intValue
        } else if json["numViews"].exists() {
            numberOfView = json["numViews"].intValue
        }
        
        if json["numComment"].exists() {
            numberOfComment = json["numComment"].intValue
        }
        
        if json["numRate"].exists() {
            numberOfRate = json["numRate"].intValue
        }
        
        if json["image"].exists() {
            thumbnailImageName = json["image"].stringValue
        }
        
        if json["timeStamp"].exists() {
            createdAt = json["timeStamp"].stringValue.toDate()
            updatedAt = json["timeStamp"].stringValue.toDate()
        }
        
        mentor = SLMentor(byJSON: json)
    }
}
