//
//  APIError.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/11/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

struct APIError: CustomDebugStringConvertible, ErrorType {
    let message: String
    let type: ErrorCodeType
    
    init(statusCode: Int, message: String) {
        self.type = ErrorCodeType(byStatusCode: statusCode)
        self.message = message
    }
}

extension APIError {
    enum ErrorCodeType: Int {
        case InternalServer = 1
        case ConnectionFailed = 100
        case ObjectNotFound = 101
        case InvalidQuery = 102
        case InvalidClassName = 103
        case MissingObjectId = 104
        case InvalidKeyName = 105
        case InvalidPointer = 106
        case InvalidJSON = 107
        case CommandUnavailable = 108
        case IncorrectType = 111
        case InvalidChannelName = 112
        case InvalidDeviceToken = 114
        case PushMisconfigured = 115
        case ObjectTooLarge = 116
        case OperationForbidden = 119
        case CacheMiss = 120
        case InvalidNestedKey = 121
        case InvalidFileName = 122
        case InvalidACL = 123
        case Timeout = 124
        case InvalidEmailAddress = 125
        case DuplicateValue = 137
        case InvalidRoleName = 139
        case ExceededQuota = 140
        case ScriptError = 141
        case ValidationError = 142
        case ReceiptMissing = 143
        case InvalidPurchaseReceipt = 144
        case PaymentDisabled = 145
        case InvalidProductIdentifier = 146
        case ProductNotFoundInAppStore = 147
        case InvalidServerResponse = 148
        case ProductDownloadFileSystemFailure = 149
        case InvalidImageData = 150
        case ErrorUnsavedFile = 151
        case FileDeleteFailure = 153
        case RequestLimitExceeded = 155
        case InvalidEventName = 160
        case UsernameMissing = 199
        case UserPasswordMissing = 201
        case UsernameTaken = 202
        case UserEmailTaken = 203
        case UserEmailMissing = 204
        case UserWithEmailNotFound = 205
        case UserCannotBeAlteredWithoutSession = 206
        case UserCanOnlyBeCreatedThroughSignUp = 207
        case FacebookAccountAlreadyLinked = 208
        case AccountAlreadyLinked = 209
        case InvalidSessionToken = 210
        case UserIdMismatch = 211
        case FacebookIdMissing = 250
        case LinkedIdMissing = 251
        case FacebookInvalidSession = 252
        case InvalidLinkedSession = 253
        case BadRequest = 400
        case UnAuthorized = 401
        case Forbidden = 403
        case NotFound = 404
        case Unknown = 999
        
        init(byStatusCode statusCode: Int) {
            if let knownError = self.dynamicType.init(rawValue: statusCode) {
                self = knownError
            } else {
                self = .Unknown
            }
        }
    }
}
