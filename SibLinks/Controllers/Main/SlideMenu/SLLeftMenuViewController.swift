//
//  SLLeftMenuViewController.swift
//  SibLinks
//
//  Created by Jana on 9/5/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

enum LeftMenu: Int {
    case Notification = 0
    case Profile
    case Setting
    case AboutUs
}

protocol LeftMenuProtocol : class {
    func changeViewController(menu: LeftMenu)
}

class SLLeftMenuViewController: SLBaseViewController, LeftMenuProtocol, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let titleMenu = ["Notification".localized, "Profile".localized/*, "Setting".localized*/]
    let imageMenu = ["Notification", "Profile"/*, "Settings"*/]
    
    let userViewModel = SLUserViewModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundView = nil
        self.tableView.bounces = false

        // Register
        self.tableView.registerNib(SLLeftMenuHeaderView.nib(), forHeaderFooterViewReuseIdentifier: SLLeftMenuHeaderView.cellIdentifier())
        self.tableView.registerNib(SLLeftMenuTableViewCell.nib(), forCellReuseIdentifier: SLLeftMenuTableViewCell.cellIdentifier())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titleMenu.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLLeftMenuTableViewCell.cellIdentifier(), forIndexPath: indexPath)
        
        if let leftCell = cell as? SLLeftMenuTableViewCell {
            leftCell.titleLabel.text = self.titleMenu[indexPath.row]
            leftCell.iconImageView.image = UIImage(named: self.imageMenu[indexPath.row])
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 180
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(SLLeftMenuHeaderView.cellIdentifier())
        headerView?.contentView.backgroundColor = UIColor.clearColor()
        
        if let leftHeaderView = headerView as? SLLeftMenuHeaderView {
            if let user = self.userViewModel.currentUser {
                let username = "\(user.firstname ?? "") \(user.lastname ?? "")"
                if username.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).characters.count > 1 {
                    leftHeaderView.nameLabel.text = username
                } else {
                    if let email = user.email {
                        let emails = email.componentsSeparatedByString("@")
                        if emails.count > 0 {
                            leftHeaderView.nameLabel.text = emails[0]
                        } else {
                            leftHeaderView.nameLabel.text = email
                        }
                    } else {
                        leftHeaderView.nameLabel.text = ""
                    }
                }
                
                leftHeaderView.profileImage.kf_indicatorType = .Activity
                if let imagePath = user.imageUrl {
                    leftHeaderView.profileImage.kf_setImageWithURL(NSURL(string: imagePath), placeholderImage: Constants.noAvatarImage)
                } else {
                    leftHeaderView.profileImage.image = nil
                }
                
                if let schoolIdString = user.school {
                    var schoolName = ""
                    for school in Constants.appDelegate().university {
                        if school.objectId == schoolIdString.toInt() {
                            if let schoolNameValue = school.name {
                                schoolName = schoolNameValue
                            }
                        }
                    }
                    leftHeaderView.descriptionLabel.text = schoolName
                } else {
                    leftHeaderView.descriptionLabel.text = ""
                }
            }
        }
        
        return headerView
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let menu = LeftMenu(rawValue: indexPath.row) {
            self.changeViewController(menu)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func aboutUs(sender: AnyObject) {
        changeViewController(LeftMenu.AboutUs)
    }
    
    @IBAction func logOutAction(sender: AnyObject) {
        // Clear access token if needed
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(Constants.kUser)
        self.sideMenuViewController?.performSegueWithIdentifier(Constants.LOG_OUT_SEGUE, sender: nil)
        self.userViewModel.signOut({ 
            
            }, failure: { (error) in
                
            }) { (error) in
                
        }
        
        GIDSignIn.sharedInstance().signOut()
    }
    
    // MARK: - Left Menu
    
    func changeViewController(menu: LeftMenu) {
        self.sideMenuViewController?.hideMenuViewController()
        var navigationController: UINavigationController?

        switch menu {
        case .Notification:
            navigationController = SLRootNavigationController(rootViewController: SLNotificationsViewController.controller)
        case .Profile:
            navigationController = SLRootNavigationController(rootViewController: SLStudentProfileViewController.controller)
        case .Setting:
            navigationController = SLRootNavigationController(rootViewController: SLSettingsViewController.controller)
        case .AboutUs:
            navigationController = SLRootNavigationController(rootViewController: AboutUsViewController())
        }
        
        guard let existController = navigationController else {
            return
        }
        
        if let tabBarController = self.sideMenuViewController?.contentViewController as? SLTabBarViewController {
            var viewControllers = tabBarController.viewControllers
            viewControllers?[2] = existController
            tabBarController.viewControllers = viewControllers
            tabBarController.selectedIndex = Constants.TAB_BAR_CENTER_NUMBER
            tabBarController.selectedButtonAt(2)
        }
    }
}
