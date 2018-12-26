//
//  SLPushNoAnimationSegue.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/27/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLPushNoAnimationSegue: UIStoryboardSegue {
    override func perform() {
        self.sourceViewController.navigationController?.pushViewController(self.destinationViewController, animated: false)
    }
}
