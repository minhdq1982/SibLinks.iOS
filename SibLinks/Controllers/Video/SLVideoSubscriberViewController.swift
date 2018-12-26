//
//  SLVideoSubscriberViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/17/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import PagingMenuController
import IBAnimatable
import Kingfisher

class SLVideoSubscriberViewController: SLBaseViewController {

    var subscriber: SLMentor?
    
    @IBOutlet weak var avatarImageView: AnimatableImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var subscriberButton: LoadingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        subscriberButton.setActivityIndicatorAlignment(ActivityIndicatorAlignment.Center)
        subscriberButton.setActivityIndicatorStyle(.Gray, state: .Normal)
        // Do any additional setup after loading the view.
        // Set up paging menu controller
        if let pagingMenuController = self.childViewControllers.first as? PagingMenuController {
            pagingMenuController.delegate = self
            pagingMenuController.setup(VideoSubscriberMenuOptions())
            
            if let videoController = pagingMenuController.pagingViewController?.controllers[0] as? SLVideoSubscriberListViewController {
                for menuItemView in (pagingMenuController.menuView?.subviews[0].subviews)! {
                    if menuItemView is MenuItemView {
                        videoController.menuItemView = menuItemView as? MenuItemView
                        break
                    }
                }
                
                videoController.mentor = subscriber
                videoController.loadObjects()
            }
            
            if let playlistController = pagingMenuController.pagingViewController?.controllers[1] as? SLVideoSubscriberPlayListViewController {
                for menuItemView in (pagingMenuController.menuView?.subviews[0].subviews)! {
                    if menuItemView is MenuItemView {
                        playlistController.menuItemView = menuItemView as? MenuItemView
                    }
                }
                
                playlistController.mentor = subscriber
                playlistController.loadObjects()
            }
        }
        
        avatarImageView.kf_indicatorType = .Activity
        if let mentor = subscriber {
            if let profileImageName = mentor.profileImageName {
                avatarImageView.kf_setImageWithURL(NSURL(string: profileImageName), placeholderImage: Constants.noAvatarImage)
            } else {
                avatarImageView.image = nil
            }
            nameLabel.text = mentor.name()
            if let school = mentor.school {
                schoolLabel.text = school
            } else {
                schoolLabel.text = ""
            }
            
            checkSubscriber()
        } else {
            avatarImageView.image = nil
            schoolLabel.text = ""
            nameLabel.text = ""
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(checkSubscriber), name: Constants.SUBSCRIBER_CHANGE, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Subscriptions".localized
        
        self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left)])
        (self.emptyView as? SLEmptyView)?.errorTitleLabel.text = "Found no video."
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = nil
    }
    
    func checkSubscriber() {
        if let mentor = subscriber {
            subscriberButton.loading = true
            SLUserViewModel.sharedInstance.checkSubscriber(mentor.objectId!, success: { (status) in
                self.subscriberButton.loading = false
                mentor.isSubscriber = status
                self.updateButton()
                }, failure: { (error) in
                    self.subscriberButton.loading = false
                    mentor.isSubscriber = false
                    self.updateButton()
                }, networkFailure: { (error) in
                    self.subscriberButton.loading = false
                    mentor.isSubscriber = false
                    self.updateButton()
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeSubscriber(sender: AnyObject) {
        if subscriberButton.loading {
            return
        }
        
        if let mentor = subscriber {
            subscriberButton.loading = true
            SLUserViewModel.sharedInstance.changeSubscriber(mentor.objectId!, success: {
                self.subscriberButton.loading = false
                if let isSubscriber = mentor.isSubscriber {
                    mentor.isSubscriber = !isSubscriber
                }
                self.updateButton()
                }, failure: { (error) in
                self.subscriberButton.loading = false
                self.updateButton()
            }, networkFailure: nil)
        }
    }
    
    private func updateButton() {
        if subscriber?.isSubscriber == true {
            subscriberButton.tintColor = colorFromHex(Constants.SIBLINKS_UNSUBSCRIBER_COLOR)
            subscriberButton.setImage(UIImage(named: "status-subscribe")!, state: .Normal)
        } else {
            subscriberButton.tintColor = colorFromHex(Constants.SIBLINKS_SUBSCRIBER_COLOR)
            subscriberButton.setImage(UIImage(named: "status-unsubscribe")!, state: .Normal)
        }
    }
}

extension SLVideoSubscriberViewController {
    
    // MARK: - Actions
    
}

extension SLVideoSubscriberViewController: PagingMenuControllerDelegate {
    
    // MARK: - PagingMenuControllerDelegate
    
    func willMoveToPageMenuController(menuController: UIViewController, previousMenuController: UIViewController) {
        
    }
    
    func didMoveToPageMenuController(menuController: UIViewController, previousMenuController: UIViewController) {
        
    }
    
    func willMoveToMenuItemView(menuItemView: MenuItemView, previousMenuItemView: MenuItemView) {
        
    }
    
    func didMoveToMenuItemView(menuItemView: MenuItemView, previousMenuItemView: MenuItemView) {
        
    }
}
