//
//  SLEssayEmptyView.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/14/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLEssayEmptyView: SLEmptyView {
    
    @IBOutlet weak var createLabel: UILabel! {
        didSet {
            let myString = "Upload your first essay right now !"
            let attributedString = NSMutableAttributedString(string: myString, attributes: [NSFontAttributeName:Constants.boldFontOfSize(16)])
            
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: Constants.SIBLINKS_NAV_COLOR), range: NSRange(location:0, length:myString.characters.count))
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR), range: NSRange(location:12, length:11))
            createLabel.attributedText = attributedString
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
