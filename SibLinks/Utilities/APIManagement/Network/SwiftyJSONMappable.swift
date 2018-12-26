//
//  SwiftyJSONMappable.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/11/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol SwiftyJSONMappable {
    init?(byJSON json: JSON)
}

extension Array where Element: SwiftyJSONMappable {
    init(byJSON json: JSON) {
        self.init()
        
        if json.type == .Null { return }
        
        for item in json.arrayValue {
            if let object = Element.init(byJSON: item) {
                self.append(object)
            }
        }
    }
}
