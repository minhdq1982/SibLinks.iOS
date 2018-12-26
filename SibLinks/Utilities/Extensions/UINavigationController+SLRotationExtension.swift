//
//  UINavigationController+SLRotationExtension.swift
//  SibLinks
//
//  Created by sanghv on 8/29/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

/** SLRotationExtension Extends UINavigationController

 */
extension UINavigationController {

    // MARK: - Rotation

    override public func shouldAutorotate() -> Bool {
        return self.visibleViewController?.shouldAutorotate() ?? true
    }

    override public func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return self.visibleViewController?.supportedInterfaceOrientations() ?? .All
    }

    override public func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return self.visibleViewController?.preferredInterfaceOrientationForPresentation() ?? .Unknown
    }
}
