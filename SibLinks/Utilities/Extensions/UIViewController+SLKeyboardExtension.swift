//
//  UIViewController+SLKeyboardExtension.swift
//  SibLinks
//
//  Created by sanghv on 8/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

/** SLKeyboardExtension Extends UIViewController

 */
extension UIViewController {
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    func destroyForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)

        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    func keyboardRectFromNotification(notification: NSNotification) -> CGRect {
        let keyboardRect = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey])!.CGRectValue()

        return keyboardRect
    }

    func keyboardWillShow(notification: NSNotification) {

    }

    func keyboardWillHide(notification: NSNotification) {
        
    }
}
