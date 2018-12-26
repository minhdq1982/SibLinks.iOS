//
//  NSMutableAttributedString+Extensions.swift
//  SibLinks
//
//  Created by Jana on 11/8/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    
    func component(string: String, font: UIFont, color: UIColor) {
        let range = self.mutableString.rangeOfString(string, options:NSStringCompareOptions.CaseInsensitiveSearch);
        if range.location != NSNotFound {
            self.addAttributes([NSFontAttributeName: font, NSForegroundColorAttributeName: color], range: range)
        }
    }
}
