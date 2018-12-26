//
//  APIResult.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/11/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import Moya

enum APIResult<T> {
    case Ok
    case Success(T)
    case Failure(APIError)
    case NetworkError(Moya.Error)
}
