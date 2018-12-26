//
//  SLArticle.swift
//  SibLinks
//
//  Created by Jana on 10/12/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import SwiftyJSON

class SLArticle: DataModel {

    var title: String?
    var articleDescription: String?
    var content: String?
    var image: String?
    var numViews: Int?
    var numComments: Int?
    var mentor: SLMentor?
    var contentParsed: NSAttributedString?
    
    override func mapping(json: JSON) {
        super.mapping(json)
        
        if json["arId"].exists() {
            objectId = json["arId"].intValue
        }
        
        if json["title"].exists() {
            title = json["title"].stringValue
        }
        
        if json["description"].exists() {
            articleDescription = json["description"].stringValue
        }
        
        if json["content"].exists() {
            content = json["content"].stringValue
        }
        
        if json["image"].exists() {
            image = json["image"].stringValue
        }
        
        if json["numView"].exists() {
            numViews = json["numView"].intValue
        }
        
        if json["numComments"].exists() {
            numComments = json["numComments"].intValue
        }
        
        if json["createDate"].exists() {
            createdAt = json["createDate"].stringValue.toDate()
            updatedAt = json["createDate"].stringValue.toDate()
        }
        
        mentor = SLMentor(byJSON: json)
    }
}
