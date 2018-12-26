//
//  UIButton+Extensions.swift
//  SibLinks
//
//  Created by Jana on 9/19/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func setUnderlineText(text: String = "", font: UIFont = .systemFontOfSize(15), color: UIColor = .blackColor()) {
        var newText = text
        if newText.isEmpty {
            newText = self.titleLabel?.text ?? ""
        }
        
        let textString = NSMutableAttributedString(string: newText)
        textString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: NSMakeRange(0, newText.characters.count))
        textString.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, newText.characters.count))
        textString.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, newText.characters.count))
        self.setAttributedTitle(textString, forState: .Normal)
    }
    
}