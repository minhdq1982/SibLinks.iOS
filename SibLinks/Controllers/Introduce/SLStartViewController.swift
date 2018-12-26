//
//  SLStartViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/29/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

// Start guide view controller
class SLStartViewController: SLBaseViewController {

    @IBOutlet weak var backgroundImageView: UIImageView! {
        didSet {
            // Set background image view
            if let imagePath = NSBundle.mainBundle().pathForResource("tour-image", ofType: "jpg") {
                backgroundImageView.image = UIImage(contentsOfFile: imagePath)
            }
        }
    }
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add splash screen animation
        addSplashScreen()
        // Change app lauching status
        Constants.appDelegate().appLauched = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
