//
//  SLSessionDelegate.swift
//  SibLinks
//
//  Created by sanghv on 8/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Alamofire

typealias SessionCompletionHandlerClosure = (() -> Void)

class SLSessionDelegate: Manager.SessionDelegate {

    private var completionHandlerDictionary = [String: SessionCompletionHandlerClosure]()
}

extension SLSessionDelegate {

    override func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        guard let identifier = session.configuration.identifier else {
            return
        }

        self.callCompletionHandlerForSession(identifier)
    }
}

extension SLSessionDelegate {

    func addCompletionHandler(handler: SessionCompletionHandlerClosure, identifier: String) {
        self.completionHandlerDictionary[identifier] = handler
    }

    private func callCompletionHandlerForSession(identifier: String) {
        guard let handler = self.completionHandlerDictionary[identifier] else {
            return
        }

        handler()
    }
}
