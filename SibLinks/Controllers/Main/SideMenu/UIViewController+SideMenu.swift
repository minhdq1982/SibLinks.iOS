//
//  UIViewController+SideMenu.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/26/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

// MARK: - UIViewController+SideMenu

extension UIViewController {
    
    var sideMenuViewController: SideMenuController? {
        get {
            if var iter : UIViewController = self.parentViewController {
                while (iter != nibName) {
                    if (iter.isKindOfClass(SideMenuController)) {
                        return (iter as! SideMenuController)
                    } else if (iter.parentViewController != nil && iter.parentViewController != iter) {
                        iter = iter.parentViewController!
                    }
                }
            }
            
            return nil
        }
        set(newValue) {
            self.sideMenuViewController = newValue
        }
    }
    
    // MARK: - Public
    // MARK: - IB Action Helper methods
    
    @IBAction public func presentLeftMenuViewController(sender: AnyObject) {
        self.sideMenuViewController!.presentLeftMenuViewController()
    }
}
