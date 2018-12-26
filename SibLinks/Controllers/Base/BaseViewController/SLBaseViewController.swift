//
//  SLBaseViewController.swift
//  SibLinks
//
//  Created by sanghv on 8/29/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import SDCAlertView
import RevealingSplashView

class SLBaseViewController: UIViewController, StateViewController {
    
    var loading = false
    // Array of UIControl (button, textfield ...) to enable/disable interactive
    var interactiveViewArray = [UIView]()
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure view
        self.configView()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update empty state frame equal super view
        loadingView?.frame = self.view.bounds
        emptyView?.frame = self.view.bounds
        errorView?.frame = self.view.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SLBaseViewController {
    // MARK: - Configure controller
    func configView() {
        // Set up placeholder views
        loadingView = SLLoadingView.loadFromNib()
        emptyView = SLEmptyView.loadFromNib()
        let failureView = SLErrorView.loadFromNib()
        failureView.tapGestureRecognizer.addTarget(self, action: #selector(loadObject as Void -> Void))
        errorView = failureView
    }
    
    func loadObject() {
        
    }
}

extension SLBaseViewController {
    // MARK: - Empty state
    func hasContent() -> Bool {
        return true
    }
    
    func handleErrorWhenContentAvailable(error: ErrorType) {
        //        Constants.showAlert(title: "Ooops", message: "Something went wrong.", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
    }
}

extension SLBaseViewController {
    
    // MARK: - Enable/Disable view
    func setEnableInteractiveView(value: Bool) {
        for view in self.interactiveViewArray {
            if value == true {
                view.userInteractionEnabled = true
            } else {
                view.userInteractionEnabled = false
            }
        }
    }
}

extension SLBaseViewController {
    
    // MARK: - Splash screen
    func addSplashScreen() {
        if let logo = UIImage(named: "Logo") {
            let revealingSplashView = RevealingSplashView(iconImage: logo, iconInitialSize: CGSize(width: logo.size.width, height: logo.size.height), backgroundColor: UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR))
            
            self.view.addSubview(revealingSplashView)
            revealingSplashView.duration = Constants.SPLASH_SCREEN_ANIMATION_DURATION
            revealingSplashView.useCustomIconColor = false
            revealingSplashView.animationType = SplashAnimationType.SwingAndZoomOut
            revealingSplashView.startAnimation(){
                print("Completed")
            }
        }
    }
}
