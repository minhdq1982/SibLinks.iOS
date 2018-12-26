//
//  UIApplication+Extensions.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

extension UIApplication {
    class func topViewController(base: UIViewController? = (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController) -> UIViewController? {
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        return base
    }
}
