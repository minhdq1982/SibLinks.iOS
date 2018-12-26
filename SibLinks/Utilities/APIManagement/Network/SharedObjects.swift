//
//  SharedObjects.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/11/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import XCGLogger

extension Provider {
    class func defaultInstance() -> Provider {
        struct statics {
            static let instance: Provider = Provider()
        }
        
        return statics.instance
    }
}

let logger = XCGLogger.defaultInstance()
let provider = Provider.defaultInstance()
