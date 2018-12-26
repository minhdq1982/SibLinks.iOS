//
//  SLVideo.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/12/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import SwiftyJSON

class SLVideo: DataModel {
    
    var title: String?
    var duration: String?
    var numberOfViews: Int?
    var numberOfRatings: Int?
    var numberOfComments: Int?
    var numberOfFavourite: Int?
    var isFavourited: Bool?
    var isRated: Bool?
    var rate: SLRate?
    var rating: Float?
    var thumbnailImageName: String?
    var videoLink: String?
    var descriptionVideo: String?
    var mentor: SLMentor?
    var suggestedVideos: [SLVideo]?
    var category: SLCategory?
    
    override func mapping(json: JSON) {
        super.mapping(json)
        
        if json["vid"].exists() {
            objectId = json["vid"].intValue
        } else if json["vId"].exists() {
            objectId = json["vId"].intValue
        }
        
        if json["title"].exists() {
            title = json["title"].stringValue
        }
        
        if json["description"].exists() {
            descriptionVideo = json["description"].stringValue
        }
        
        if json["runningTime"].exists() {
            duration = json["runningTime"].stringValue
        }
        
        if json["numViews"].exists() {
            numberOfViews = json["numViews"].intValue
        }
        
        if json["numRatings"].exists() {
            numberOfRatings = json["numRatings"].intValue
        }
        
        if json["numComments"].exists() {
            numberOfComments = json["numComments"].intValue
        }
        
        if json["numFavourite"].exists() {
            numberOfFavourite = json["numFavourite"].intValue
        }
        
        if json["averageRating"].exists() {
            rating = json["averageRating"].floatValue
        }
        
        if json["image"].exists() {
            thumbnailImageName = json["image"].stringValue
        }
        
        if json["url"].exists() {
            videoLink = json["url"].stringValue
        } else if json["youtubeUrl"].exists() {
            videoLink = json["youtubeUrl"].stringValue
        }
        
        if json["timeStamp"].exists() {
            createdAt = json["timeStamp"].stringValue.toDate()
        } else if json["creationDate"].exists() {
            createdAt = json["creationDate"].stringValue.toDate()
        }
        
        if json["timeStamp"].exists() {
            updatedAt = json["timeStamp"].stringValue.toDate()
        } else if json["creationDate"].exists() {
            updatedAt = json["creationDate"].stringValue.toDate()
        }
        
        mentor = SLMentor(byJSON: json)
        category = SLCategory(byJSON: json)
    }
}

class SLRate: DataModel {
    
    var rating: Int?
    
    override func mapping(json: JSON) {
        super.mapping(json)
        
        if json["rating"].exists() {
            rating = json["rating"].intValue
        }
    }
}
