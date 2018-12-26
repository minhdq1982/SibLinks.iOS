//
//  String+Localized.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/12/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
    
    func localizedWithComment(comment:String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: comment)
    }
}