//
//  UIViewControllerLoading.swift
//  SibLinks
//
//  Created by Anh Nguyen on 8/7/16.
//  Copyright © 2016 SibLinks. All rights reserved.
//

import UIKit

protocol UIViewControllerLoading {}

extension UIViewController : UIViewControllerLoading {}
//extension SLBaseViewController : UIViewControllerLoading {}
extension SLBaseTableViewController : UIViewControllerLoading {}
//extension SLBaseCollectionViewController : UIViewControllerLoading {}

extension UIViewControllerLoading where Self : UIViewController {
    
    // Note that this method returns an instance of type `Self`, rather than UIViewController
    static func instantiateFromStoryboard(name: String) -> Self {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let className = "\(self)".componentsSeparatedByString(".")
        let nibName = className.last!
        let viewController = storyboard.instantiateViewControllerWithIdentifier(nibName) as! Self
        
        return viewController
    }
}
