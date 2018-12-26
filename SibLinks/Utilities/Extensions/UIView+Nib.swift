//
//  UIView+Nib.swift
//  SibLinks
//
//  Created by Anh Nguyen on 3/30/16.
//  Copyright © 2016 SibLinks. All rights reserved.
//

import UIKit

extension UIView {
    static func nibName() -> String {
        let nameSpaceClassName = NSStringFromClass(self)
        let className = nameSpaceClassName.componentsSeparatedByString(".").last! as String
        
        return className
    }
    
    static func nib() -> UINib {
        return UINib(nibName: self.nibName(), bundle: nil)
    }
}
