//
//  SLCategory.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/16/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import SwiftyJSON

class SLCategory: DataModel {
    
    var subject: String?
    var level: Int?
    var image: String?
    var parentId: String?
    var isForum: Bool?
    
    override func mapping(json: JSON) {
        super.mapping(json)

        if json["subjectId"].exists() {
            objectId = json["subjectId"].intValue
        } else if json["SUBJECTID"].exists() {
            objectId = json["SUBJECTID"].intValue
        }
        
        if json["subject"].exists() {
            subject = json["subject"].stringValue
        } else if json["SUBJECT"].exists() {
            subject = json["SUBJECT"].stringValue
        }
        
        if json["level"].exists() {
            level = json["level"].intValue
        }
        
        if json["image"].exists() {
            image = json["image"].stringValue
        }
        
        if json["parentId"].exists() {
            parentId = json["parentId"].stringValue
        }
        
        if json["isForum"].exists() {
            isForum = json["isForum"].boolValue
        }
    }
    
}
