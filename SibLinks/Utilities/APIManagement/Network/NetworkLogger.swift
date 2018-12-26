//
//  NetworkLogger.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/11/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import Moya
import Result

/// Network activity change notification type.
enum NetworkActivityChangeType {
    case began, ended
}

final class NetworkActivityPlugin: PluginType {
    
    typealias NetworkActivityClosure = (change: NetworkActivityChangeType) -> ()
    let networkActivityClosure: NetworkActivityClosure
    
    init(networkActivityClosure: NetworkActivityClosure) {
        self.networkActivityClosure = networkActivityClosure
    }
    
    // MARK: Plugin
    
    /// Called by the provider as soon as the request is about to start
    func willSendRequest(request: RequestType, target: TargetType) {
        networkActivityClosure(change: .began)
    }
    
    /// Called by the provider as soon as a response arrives
    func didReceiveResponse(result: Result<Response, Error>, target: TargetType) {
        networkActivityClosure(change: .ended)
    }
}

/// Logs network activity (outgoing requests and incoming responses).
class NetworkLogger: PluginType {
    
    func willSendRequest(request: RequestType, target: TargetType) {
        logger.info("Sending request: \(request.request?.URL?.absoluteString)")
    }
    
    func didReceiveResponse(result: Result<Response, Error>, target: TargetType) {
        switch result {
        case let .Success(response):
            logger.info("Received response(\(response.statusCode ?? 0)) from \(response.response!.URL?.absoluteString ?? String()).")
        case .Failure(_):
            logger.error("Got error")
        }
    }
}
