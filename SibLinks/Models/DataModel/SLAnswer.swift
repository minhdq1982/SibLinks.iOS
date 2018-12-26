//
//  SLAsk.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/16/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import SwiftyJSON

class SLAnswer: DataModel {
    
    var answer: String?
    var answerImages: [String]?
    var mentor: SLMentor?
    var like: Bool = false
    var questionId: Int?
    var numberOfLike: Int?
    
    override func mapping(json: JSON) {
        super.mapping(json)
        objectId = json["aid"].intValue
        questionId = json["pid"].intValue
        numberOfLike = json["numlikes"].intValue
        answer = json["content"].stringValue
        like = json["like"].boolValue
        let image = json["imageAnswer"].stringValue
        if image.characters.count > 0 {
            let answerImages = image.componentsSeparatedByString(";")
            self.answerImages = answerImages
            self.answerImages = self.answerImages?.filter { $0 != "" }
        }
        mentor = SLMentor(byJSON: json)
        if json["TIMESTAMP"].exists() {
            createdAt = json["TIMESTAMP"].stringValue.toDate()
        } else if json["timeStamp"].exists() {
            createdAt = json["timeStamp"].stringValue.toDate()
        }
        
        if json["updateTime"].exists() {
            updatedAt = json["updateTime"].stringValue.toDate()
        } else if json["timeStamp"].exists() {
            updatedAt = json["timeStamp"].stringValue.toDate()
        }
    }
    
}
