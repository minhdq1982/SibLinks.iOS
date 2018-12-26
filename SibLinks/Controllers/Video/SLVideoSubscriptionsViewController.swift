//
//  SLVideoSubscriptionsViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/12/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLVideoSubscriptionsViewController: SLVideoListViewController {
    
    // List subscriber of user
    private var subscribers = [SLMentor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Show mentor empty view
        emptyView = SLMentorEmptyView.loadFromNib()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openTopMentor as Void -> Void))
        emptyView?.addGestureRecognizer(tapGestureRecognizer)
        // Table view register cell
        self.tableView.registerNib(SLVideoSubscriberHeaderView.nib(), forHeaderFooterViewReuseIdentifier: SLVideoSubscriberHeaderView.cellIdentifier())
        // Get subscriber list
        getSubscribers()
        // Observer when subscriber changed
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshControlValueChanged(_:)), name: Constants.SUBSCRIBER_CHANGE, object: nil)
    }
    
    override func queryForTable() -> VideoRouter {
        return VideoRouter(endpoint: .GetSubscriptionsVideo(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, subjectId: (category?.objectId ?? -1)))
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(SLVideoSubscriberHeaderView.cellIdentifier()) as! SLVideoSubscriberHeaderView
        headerView.delegate = self
        headerView.configCellWithData(subscribers)
        
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65
    }
    
    private func getSubscribers() {
        // Get subscribers list of student
        VideoRouter(endpoint: VideoEndpoint.GetSubscribers(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!)).request { (result) in
            switch result {
            case .Success(let objects):
                if let objects = objects as? [SLMentor] {
                    self.subscribers = objects
                    if let headerView = self.tableView.headerViewForSection(0) as? SLVideoSubscriberHeaderView {
                        headerView.configCellWithData(objects)
                    }
                }
            default:
                print("error")
            }
        }
    }
    
    func showSubscriber(mentor: SLMentor) {
        let subscriberViewController = SLVideoSubscriberViewController.instantiateFromStoryboard(Constants.VIDEO_STORYBOARD)
        subscriberViewController.subscriber = mentor
        
        self.navigationController?.pushViewController(subscriberViewController, animated: true)
    }
    
    override func refreshControlValueChanged(refreshControl: UIRefreshControl) {
        if !loading {
            getSubscribers()
        }
        super.refreshControlValueChanged(refreshControl)
    }
    
    func openTopMentor() {
        if let sideMenuViewController = self.sideMenuViewController {
            if let tabBarController = sideMenuViewController.contentViewController as? SLTabBarViewController {
                tabBarController.selectedButtonAt(Constants.TAB_BAR_MENTOR_NUMBER)
            }
        }
    }
    
    func showMoreMentor() {
        let moreMentors = SLMoreSubscribersViewController()
        moreMentors.navigationTitle = "Subcriptions".localized
        moreMentors.query = UserRouter(endpoint: UserEndpoint.GetSubscribers(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!))
        self.navigationController?.pushViewController(moreMentors, animated: true)
    }
}

extension SLVideoSubscriptionsViewController {
    
    override func hasContent() -> Bool {
        return objects().count > 0 || subscribers.count > 0
    }
    
    override func loadObject() {
        loadObjects()
        getSubscribers()
    }
    
}
