//
//  SLSchool.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/14/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import SwiftyJSON

class SLSchool: DataModel {
    
    var name: String?
    
    override func mapping(json: JSON) {
        super.mapping(json)
        
        if json["name"].exists() {
            name = json["name"].stringValue
        }
        
        if json["id"].exists() {
            objectId = json["id"].intValue
        } else if json["schoolId"].exists() {
            objectId = json["schoolId"].intValue
        }
    }
}
