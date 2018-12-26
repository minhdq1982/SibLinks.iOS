//
//  UIImage+SLResize.swift
//  SibLinks
//
//  Created by sanghv on 8/29/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

/** SLResize Extends UIImage

 */
extension UIImage {

    func cropImageWithRect(rect: CGRect) -> UIImage {
        let scale: CGFloat = UIScreen.mainScreen().scale

        // constrain crop rect to legitimate bounds
        var outputImage = self
        var newRect = rect

        if (newRect.origin.x >= self.size.width || newRect.origin.y >= self.size.height) {
            return outputImage
        }

        if (newRect.origin.x + newRect.size.width >= self.size.width) {
            newRect.size.width = self.size.width - newRect.origin.x
        }

        if (newRect.origin.y + newRect.size.height >= self.size.height) {
            newRect.size.height = self.size.height - newRect.origin.y
        }

        newRect.origin.y = newRect.origin.y * scale
        newRect.size.width = newRect.size.width * scale
        newRect.size.height = newRect.size.height * scale

        // Crop
        let imageRef = CGImageCreateWithImageInRect(self.CGImage!, newRect)
        if let imageRef = imageRef {
            outputImage = UIImage(CGImage:imageRef)
        }

        return outputImage
    }
}
