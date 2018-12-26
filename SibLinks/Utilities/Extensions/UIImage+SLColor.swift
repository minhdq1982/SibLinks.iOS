//
//  UIImage+SLColor.swift
//  SibLinks
//
//  Created by sanghv on 8/29/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

/** SLColor Extends UIImage

 */
extension UIImage {
    
    convenience init(color: UIColor?, size: CGSize = CGSizeMake(1, 1)) {
        let guardColor = color ?? UIColor.clearColor()
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        guardColor.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.init(CGImage: image.CGImage!)
    }
}
