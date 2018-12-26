//
//  SLQuestionEmptyView.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLQuestionEmptyView: SLEmptyView {

    @IBOutlet weak var createLabel: UILabel! {
        didSet {
            let myString = "Create your first ask right now !"
            let attributedString = NSMutableAttributedString(string: myString, attributes: [NSFontAttributeName:Constants.boldFontOfSize(16)])
            
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR), range: NSRange(location:0, length:myString.characters.count))
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR), range: NSRange(location:12, length:9))
            createLabel.attributedText = attributedString
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
