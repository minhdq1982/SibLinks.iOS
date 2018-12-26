//
//  UIViewLoading.swift
//  SibLinks
//
//  Created by Anh Nguyen on 8/6/16.
//  Copyright © 2016 SibLinks. All rights reserved.
//

import UIKit

protocol UIViewLoading {}
extension UIView : UIViewLoading {}

extension UIViewLoading where Self : UIView {
    
    // note that this method returns an instance of type `Self`, rather than UIView
    static func loadFromNib() -> Self {
        let className = "\(self)".componentsSeparatedByString(".")
        let nibName = className.last!
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiateWithOwner(self, options: nil).first as! Self
    }
}
