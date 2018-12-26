//
//  ErrorHandlingController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 11/3/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import Moya
import SDCAlertView

class ErrorHandlingController {
    // MARK: - Filter error to handle
    static func handleAPIError(error: APIError?) {
        guard let error = error else {
            return
        }
        
        switch error.type {
        default:
            self.handleCommonError(error.message)
            break
        }
    }
    
    static func handleNetworkError(error: Moya.Error?) {
        guard let error = error else {
            return
        }
        
        switch error {
        case .Underlying(let error):
            self.handleCommonError(error.localizedDescription)
            break
        default:
            break
        }
    }
    
    // MARK: - Handle Error
    private static func handleCommonError(errorMessage: String) {
        Constants.showAlert("SibLinks", message: errorMessage, actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
    }
}
