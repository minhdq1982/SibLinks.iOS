//
//  SLSampleApplyViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/14/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLSampleApplyViewController: SLApplyViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = colorFromHex(Constants.SIBLINKS_TABBAR_BACKGROUND_COLOR)
    }
    
    override var admissionId: Int {
        return 2
    }
    
    static let sampleApplyViewControllerID = "SLSampleApplyViewControllerID"
    
    static var controller: SLSampleApplyViewController! {
        let controller = UIStoryboard(name: Constants.ADMISSION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(SLSampleApplyViewController.sampleApplyViewControllerID) as! SLSampleApplyViewController
        return controller
    }
}
