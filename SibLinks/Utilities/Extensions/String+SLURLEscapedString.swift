//
//  String+SLURLEscapedString.swift
//  SibLinks
//
//  Created by sanghv on 8/29/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation

/** SLURLEscapedString Extends String

 */
extension String {
    
    var URLEscapedString: String {
        return self.stringByReplacingOccurrencesOfString(" ", withString: "%20")
    }
}
