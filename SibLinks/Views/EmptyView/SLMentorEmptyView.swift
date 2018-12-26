//
//  SLMentorEmptyView.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/6/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLMentorEmptyView: SLEmptyView {
    @IBOutlet weak var mentorLabel: UILabel! {
        didSet {
            let myString = "Find your mentor right now!"
            let attributedString = NSMutableAttributedString(string: myString, attributes: [NSFontAttributeName:Constants.boldFontOfSize(16)])
            
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR), range: NSRange(location:0, length:myString.characters.count))
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR), range: NSRange(location:10, length:6))
            mentorLabel.attributedText = attributedString
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
