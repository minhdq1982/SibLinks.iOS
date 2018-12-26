//
//  UITextField+fixCaretPosition.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/25/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

extension UITextField {
    /// Moves the caret to the correct position by removing the trailing whitespace
    func fixCaretPosition() {
        // Moving the caret to the correct position by removing the trailing whitespace
        // http://stackoverflow.com/questions/14220187/uitextfield-has-trailing-whitespace-after-securetextentry-toggle
        
        let beginning = self.beginningOfDocument
        self.selectedTextRange = self.textRangeFromPosition(beginning, toPosition: beginning)
        let end = self.endOfDocument
        self.selectedTextRange = self.textRangeFromPosition(end, toPosition: end)
    }
}
