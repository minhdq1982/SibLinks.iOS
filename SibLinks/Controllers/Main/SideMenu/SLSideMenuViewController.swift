//
//  SLSideMenuViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/26/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import RevealingSplashView

class SLSideMenuViewController: SideMenuController {
    
    var showProfile = false
    
    override func awakeFromNib() {
        self.contentViewController = Constants.appDelegate().setupTabBar()
        self.leftMenuViewController = SLLeftMenuViewController.instantiateFromStoryboard(Constants.SLIDE_MENU_STORYBOARD)
        self.rightMenuViewController = UIViewController()
        
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.menuPreferredStatusBarStyle = .Default
        self.delegate = self
        self.contentViewShadowColor = UIColor.blackColor()
        self.contentViewShadowOffset = CGSize(width: 0, height: 0)
        self.contentViewShadowOpacity = 0.6
        self.contentViewShadowRadius = 12
        self.contentViewShadowEnabled = true
        
        if !Constants.appDelegate().appLauched {
            addSplashScreen()
            Constants.appDelegate().appLauched = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if showProfile {
            showProfile = false
            showUserProfile()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showUserProfile() {
        if let leftMenuViewController = self.leftMenuViewController as? SLLeftMenuViewController {
            leftMenuViewController.changeViewController(LeftMenu.Profile)
        }
    }
}

extension SLSideMenuViewController: SideMenuControllerDelegate {
    func sideMenu(sideMenu: SideMenuController, didShowMenuViewController menuViewController: UIViewController) {
        if let leftMenuViewController = self.leftMenuViewController as? SLLeftMenuViewController {
            leftMenuViewController.tableView.reloadData()
        }
    }
}
