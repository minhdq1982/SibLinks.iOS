//
//  SLBeforeApplyViewController.swift
//  SibLinks
//
//  Created by Jana on 9/30/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLBeforeApplyViewController: SLApplyViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = colorFromHex(Constants.SIBLINKS_TABBAR_BACKGROUND_COLOR)
    }
    
    override var admissionId: Int {
        return 1
    }
    
    static let beforeApplyViewControllerID = "SLBeforeApplyViewControllerID"
    
    static var controller: SLBeforeApplyViewController! {
        let controller = UIStoryboard(name: Constants.ADMISSION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(SLBeforeApplyViewController.beforeApplyViewControllerID) as! SLBeforeApplyViewController
        return controller
    }
}
