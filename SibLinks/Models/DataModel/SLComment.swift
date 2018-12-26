//
//  SLComment.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/30/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import SwiftyJSON

class SLComment: DataModel {
    
    var content: String?
    var user: SLUser?
    
    override func mapping(json: JSON) {
        super.mapping(json)
        
        if json["cid"].exists() {
            objectId = json["cid"].intValue
        }
        
        if json["content"].exists() {
            content = json["content"].stringValue
        }
        
        user = SLUser(byJSON: json)
        if json["timestamp"].exists() {
            updatedAt = json["timestamp"].stringValue.toDate()
            createdAt = json["timestamp"].stringValue.toDate()
        }
    }
}
