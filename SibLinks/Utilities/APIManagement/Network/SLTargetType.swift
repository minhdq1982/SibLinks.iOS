//
//  SLTargetType.swift
//  SibLinks
//
//  Created by sanghv on 8/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON

/** SLTargetType protocol

*/
protocol SLTargetType: TargetType {
    var parameterEncoding: Moya.ParameterEncoding { get }
    func parseResponse(json: JSON) -> AnyObject?
    func request(provider: Provider, attempts: Int, completion: (APIResult<AnyObject>) -> ()) -> Cancellable?
}
