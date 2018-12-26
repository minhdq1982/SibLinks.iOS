//
//  Response+mapSwiftyJSON.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/11/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import Moya

extension Response {
    func mapSwiftyJSON() -> JSON {
        return JSON(data: data)
    }
}
