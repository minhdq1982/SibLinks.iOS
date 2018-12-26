//
//  SLMajor.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/14/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import SwiftyJSON

class SLMajor: DataModel {
    
    var name: String?
    
    override func mapping(json: JSON) {
        super.mapping(json)
        if json["majorName"].exists() {
            name = json["majorName"].stringValue
        }
        
        if json["majorId"].exists() {
            objectId = json["majorId"].intValue
        }
    }
}
