//
//  UIView+SLImageConverter.swift
//  SibLinks
//
//  Created by sanghv on 8/29/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

/** SLImageConverter Extends UIView

 */
extension UIView {

    func imageBySize(size: CGSize) -> UIImage {
        let scale: CGFloat = UIScreen.mainScreen().scale
        let selector = Selector("setShouldRasterize:")

        let respond = self.layer.respondsToSelector(selector)
        if respond {
            UIGraphicsBeginImageContextWithOptions(size, false, self.contentScaleFactor * scale)
        } else {
            UIGraphicsBeginImageContext(size)
        }

        self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }
}
