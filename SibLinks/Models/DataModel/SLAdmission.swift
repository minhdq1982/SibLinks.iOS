//
//  SLAdmission.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/14/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import SwiftyJSON

class SLAdmission: DataModel {
    
    var name: String?
    
    override func mapping(json: JSON) {
        super.mapping(json)
        if json["SUBJECT"].exists() {
            name = json["SUBJECT"].stringValue
        } else if json["subject"].exists() {
            name = json["subject"].stringValue
        }
        
        if json["SUBJECTID"].exists() {
            objectId = json["SUBJECTID"].intValue
        } else if json["subjectId"].exists() {
            objectId = json["subjectId"].intValue
        }
    }
}
