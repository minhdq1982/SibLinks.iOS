//
//  SLIntroduceViewController.swift
//  SibLinks
//
//  Created by Jana on 9/1/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

// Introduce host view controller contain pages controller
class SLIntroduceViewController: SLBaseViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var fakePageControl: UIView!
    @IBOutlet weak var pin1: UIImageView!
    @IBOutlet weak var pin2: UIImageView!
    @IBOutlet weak var pin3: UIImageView!
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        // Create dummy introduce view
        if let pagesController = self.childViewControllers.first as? SLPagesController {
            var pages = [UIViewController]()
            for i in 1 ... 3 {
                let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Introduce\(i)")
                pages.append(pageContentViewController!)
            }
            
            pagesController.setup(pages)
            pagesController.pagesDelegate = self
        }
        
        super.viewDidLoad()
        
        // Introduce background color
        self.view.backgroundColor = colorFromHex(Constants.SIBLINKS_INTRODUCE_BACKGROUND_HEX_COLOR)
        // Configure Page Control
        self.pageControl.numberOfPages = 3
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SLIntroduceViewController {
    
    // MARK: - Actions
    @IBAction func signUpAction() {
        AppDelegate.introduction = true
        self.performSegueWithIdentifier(Constants.SIGN_OUT_SEGUE, sender: nil)
    }
    
    @IBAction func loginAction() {
        AppDelegate.introduction = true
        self.performSegueWithIdentifier(Constants.SIGN_IN_SEGUE, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.SIGN_OUT_SEGUE {
            if let navigationController = segue.destinationViewController as? UINavigationController {
                if let viewController = navigationController.topViewController as? SLSignInViewController {
                    viewController.createAnAccountAction()
                }
            }
        }
    }
}

extension SLIntroduceViewController: PagesControllerDelegate {
    
    // MARK: - PagesControllerDelegate
    func pageViewController(pageViewController: UIPageViewController, setViewController viewController: UIViewController, atPage page: Int) {
        pageControl.currentPage = page
        self.selectedPinAtIndex(page)
    }
}

extension SLIntroduceViewController {
    
    // MARK: - Selected pin (fake view)
    func selectedPinAtIndex(index: Int) {
        self.pin1.image = UIImage(named: "PageControlNormal")
        self.pin2.image = UIImage(named: "PageControlNormal")
        self.pin3.image = UIImage(named: "PageControlNormal")
        
        switch index {
        case 0:
            self.pin1.image = UIImage(named: "PageControlSelected")
        case 1:
            self.pin2.image = UIImage(named: "PageControlSelected")
        case 2:
            self.pin3.image = UIImage(named: "PageControlSelected")
        default:
            return
        }
    }
}