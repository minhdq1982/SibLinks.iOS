//
//  SLTabBarViewController.swift
//  SibLinks
//
//  Created by Jana on 10/7/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLTabBarViewController: SLBaseTabBarViewController {

    lazy var tabbarParentView: UIView = self.createTabBar()
    private func createTabBar() -> UIView {
        let heightTabBar = (64 * self.view.frame.size.width) / 320
        
        let tabbarParentView = UIView()
        tabbarParentView.frame = CGRect(x: 0, y: self.view.frame.size.height - heightTabBar, width: self.view.frame.size.width, height: heightTabBar)
        let tabBarView = SLTabBarView.instanceFromNib()
        tabBarView.frame = tabbarParentView.bounds
        tabBarView.delegate = self
        self.tabBarView = tabBarView
        tabbarParentView.addSubview(tabBarView)
        
        return tabbarParentView
    }
    
    var tabBarView: SLTabBarView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewControllers()
        
        for view in self.view.subviews {
            if view.isKindOfClass(UITabBar) {
                view.hidden = true
                break
            }
        }
        
        self.view.addSubview(tabbarParentView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didReceiveAnswerred(_:)), name: Constants.PUSH_ANSWERRED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didReceiveEssay(_:)), name: Constants.PUSH_ESSAY, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didPostAsk(_:)), name: Constants.PUSH_POST_ASK_SUCCESS, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupViewControllers() {
        // Set up video screen
        let videoStoryBoard = UIStoryboard(name: Constants.VIDEO_STORYBOARD, bundle: nil)
        let videoScreen = videoStoryBoard.instantiateInitialViewController()!
        
        // Set up ask question
        let askStoryBoard = UIStoryboard(name: Constants.ASK_STORYBOARD, bundle: nil)
        let askScreen = askStoryBoard.instantiateInitialViewController()!
        
        // Set up admission
        let admissionStoryBoard = UIStoryboard(name: Constants.ADMISSION_STORYBOARD, bundle: nil)
        let admissionScreen = admissionStoryBoard.instantiateInitialViewController()!
        
        // Set up mentor
        let mentorStoryBoard = UIStoryboard(name: Constants.MENTOR_STORYBOARD, bundle: nil)
        let mentorScreen = mentorStoryBoard.instantiateInitialViewController()!
        
        // View controllers
        self.viewControllers = [askScreen, videoScreen, admissionScreen, mentorScreen]
        self.tabBar.translucent = false
        
        self.selectedViewController(self.viewControllers![0])
    }
    
    func selectedViewController(selectedViewController: UIViewController) {
        if (self.selectedViewController == selectedViewController) {
            (self.selectedViewController as? UINavigationController)?.popToRootViewControllerAnimated(true)
        }
        super.selectedViewController = selectedViewController
    }
    
    override func viewWillLayoutSubviews() {
        let heightTabBar = (64 * self.view.frame.size.width) / 320
        let tabBarPercent = heightTabBar*(109/150)
        
        var tabFrame = self.tabBar.frame;
        tabFrame.size.height = tabBarPercent;
        tabFrame.origin.y = self.view.frame.size.height - tabBarPercent;
        self.tabBar.frame = tabFrame;
    }

}

extension SLTabBarViewController {
    
    // MARK: - Actions
    
    func didReceiveAnswerred(notification: NSNotification) {
        if let objectId = notification.object as? Int {
            // Dissmiss all presented view controller
            Constants.appDelegate().window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
            
            if let viewControllers = viewControllers {
                self.selectedButtonAt(0)
                
                // Question
                let question = SLQuestion()
                question.objectId = objectId
                
                // Question detail
                if let navigationController = viewControllers[0] as? UINavigationController {
                    if let askViewController = navigationController.viewControllers.last as? SLAskViewController {
                        askViewController.loadObjects()
                        askViewController.performSegueWithIdentifier(Constants.QUESTION_DETAIL_SEGUE, sender: question)
                    } else if let askDetailViewController = navigationController.viewControllers.last as? SLAskDetailViewController {
                        askDetailViewController.question = question
                        askDetailViewController.loadQuestion(0, clear: true)
                    }
                }
            }
        }
    }
    
    func didReceiveEssay(notification: NSNotification) {
        if let objectId = notification.object as? Int {
            let essay = SLEssay()
            essay.objectId = objectId
            
            // Dissmiss all presented view controller
            if let viewController = UIApplication.topViewController() as? SLEssayDetailsViewController {
                viewController.essay = essay
                viewController.getEssayDetail()
            } else {
                Constants.appDelegate().window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
                self.selectedButtonAt(3)
                
                let essayDetailsViewController = SLEssayDetailsViewController.controller
                essayDetailsViewController.essay = essay
                essayDetailsViewController.presentViewController(essayDetailsViewController, animated: true, completion: nil)
            }
        }
    }
    
    func didPostAsk(notification: NSNotification) {
        self.selectedButtonAt(0)
    }
    
}

extension SLTabBarViewController: SLTabBarViewDelegate {
    
    // MARK: - SLTabBarViewDelegate
    
    func selectedButtonAt(index: NSInteger) {
//        self.selectedViewController(self.viewControllers![index])
        self.selectedIndex = Int(index)
        
        switch index {
        case 0:
            self.tabBarView?.currentSelected = .Ask
        case 1:
            self.tabBarView?.currentSelected = .Video
        case 2:
            self.tabBarView?.currentSelected = .None
        case 3:
            self.tabBarView?.currentSelected = .Admission
        case 4:
            self.tabBarView?.currentSelected = .Mentors
        default:
            return
        }
        self.tabBarView?.reset()
    }
    
}
