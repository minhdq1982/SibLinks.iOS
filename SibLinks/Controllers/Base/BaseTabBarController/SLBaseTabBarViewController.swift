//
//  SLBaseTabBarViewController.swift
//  SibLinks
//
//  Created by Jana on 9/5/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLBaseTabBarViewController: UITabBarController {

    private var centerTabAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure view
        self.configureView()
        Constants.appDelegate().getCategories()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !centerTabAdded {
            // Insert empty tab item at center index. In this case we have 5 tabs.
            self.insertEmptyTabItem("", atIndex: Constants.TAB_BAR_CENTER_NUMBER)
            // Raise the center tab bar
            self.addRaisedCenterTab()
            self.addSeparatorLine()
            centerTabAdded = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func insertEmptyTabItem(title: String, atIndex: Int) {
        let vc = UIViewController()
        vc.tabBarItem = UITabBarItem(title: title, image: nil, tag: 0)
        vc.tabBarItem.enabled = false
        
        self.viewControllers?.insert(vc, atIndex: atIndex)
    }
    
    private func addRaisedCenterTab() {
        let heightTabBar = (64 * self.view.frame.size.width) / 320
        
        let askNowView = SLAskNowView.loadFromNib()
        askNowView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width/5, heightTabBar)
    
        let heightDifference = heightTabBar - self.tabBar.frame.size.height
        
        if (heightDifference < 0) {
            askNowView.center = self.tabBar.center
        } else {
            var center = self.tabBar.center
            center.y -= heightDifference / 2.0
            
            askNowView.center = center
        }
        
        askNowView.button.addTarget(self, action: #selector(SLBaseTabBarViewController.onRaisedButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(askNowView)
    }
    
    private func addSeparatorLine() {
        if let items = self.tabBar.items {
            
            //Get the height of the tab bar
            
            let height = CGRectGetHeight(self.tabBar.bounds)
            
            //Calculate the size of the items
            
            let numItems = CGFloat(items.count)
            let itemSize = CGSize(
                width: tabBar.frame.width / numItems,
                height: tabBar.frame.height)
            
            for (index, _) in items.enumerate() {
                
                //We don't want a separator on the left of the first item.
                
                if index > 0 {
                    
                    //Xposition of the item
                    
                    let xPosition = itemSize.width * CGFloat(index)
                    
                    /* Create UI view at the Xposition,
                     with a width of 0.5 and height equal
                     to the tab bar height, and give the
                     view a background color
                     */
                    let separator = UIView(frame: CGRect(
                        x: xPosition, y: 0, width: 1, height: height))
                    separator.backgroundColor = UIColor(hexString: Constants.SIBLINKS_TABBAR_SEPARATOR_COLOR)
                    tabBar.insertSubview(separator, atIndex: 1)
                }
            }
        }
    }
    
    func onRaisedButton(sender: UIButton!) {
        self.presentViewController(SLAskCameraViewController.navigationController, animated: true, completion: nil)
    }
}

extension SLBaseTabBarViewController {
    
    func configureView() {
        
    }
}
