//
//  Provider.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/11/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import Moya
import Alamofire

class Provider {
    var timeOut: NSTimeInterval = 15
    
    private var provider: MoyaProvider<BaseRouter>
    
    init() {
        provider = MoyaProvider<BaseRouter>(endpointClosure: { (target: BaseRouter) -> Endpoint<BaseRouter> in
            return target.requestEndpoint
            }, manager: alamofireManager(self.timeOut), plugins: [NetworkLogger()])
    }
    
    func request(target: BaseRouter, completion: Moya.Completion) -> Cancellable? {
        return provider.request(target, completion: completion)
    }
}

func alamofireManager(timeOut: NSTimeInterval = 15) -> Manager {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    configuration.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
    configuration.timeoutIntervalForRequest = timeOut
    configuration.timeoutIntervalForResource = timeOut
    
    let manager = Manager(configuration: configuration)
    return manager
}
