//
//  SLEdgeInsetsLable.swift
//  SibLinks
//
//  Created by sanghv on 8/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLEdgeInsetsLable: UILabel {

    var textInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)

    override func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = textInsets.apply(bounds)
        rect = super.textRectForBounds(rect, limitedToNumberOfLines: numberOfLines)

        return textInsets.inverse.apply(rect)
    }

    override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(textInsets.apply(rect))
    }

    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */

}

extension UIEdgeInsets {
    var inverse: UIEdgeInsets {
        return UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right)
    }

    func apply(rect: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(rect, self)
    }
}
