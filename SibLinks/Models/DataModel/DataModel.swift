//
//  DataModel.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/12/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

class DataModel: NSObject, SwiftyJSONMappable {
    
    var objectId: Int?
    var updatedAt: NSDate?
    var createdAt: NSDate?
    
    override init() {
        super.init()
    }
    
    convenience required init?(byJSON json: JSON) {
        self.init()
        mapping(json)
    }
    
    func mapping(json: JSON) {
        if json.type == .Null { return }
    }
}
