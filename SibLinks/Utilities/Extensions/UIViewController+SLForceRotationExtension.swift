//
//  UIViewController+SLForceRotationExtension.swift
//  SibLinks
//
//  Created by sanghv on 8/29/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

/** SLForceRotationExtension Extends UIViewController

 */
extension UIViewController {

    // MARK: - Force view controller rotate to specific orientation

    func forceRotateTo(orientation orientation: UIInterfaceOrientation) {
        let value = orientation.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
}
