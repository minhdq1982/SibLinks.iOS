//
//  SLVideoCommentViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/29/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import SDCAlertView
import PagingMenuController

class SLVideoCommentViewController: SLQueryTableViewController {
    
    weak var delegate: SLVideoDetailViewController?
    var menuItemView: MenuItemView?
    var video: SLVideo?
    var admission = false
    var activeTextView: UITextView?
    
    override func viewDidLoad() {
        paginationEnabled = false
        super.viewDidLoad()
        
        self.tableView.registerNib(SLVideoCommentViewCell.nib(), forCellReuseIdentifier: SLVideoCommentViewCell.cellIdentifier())
        self.tableView.registerNib(SLVideoCommentHeaderView.nib(), forHeaderFooterViewReuseIdentifier: SLVideoCommentHeaderView.cellIdentifier())
        self.tableView.backgroundColor = UIColor.whiteColor()
        emptyViewEnabled = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.tapOnBlurView), name: "comment.hide.keyboard", object: nil)
    }
    
    // MARK: - Actions
    func tapOnBlurView(notification: NSNotification) {
        if (activeTextView?.text.characters.count > 0) {
            Constants.showAlert("SibLinks", message: "Discard comment?", actions: AlertAction(title: "KEEP WRITING", style: .Preferred, handler: { (_) in
                self.activeTextView?.becomeFirstResponder()
            }),
            AlertAction(title: "DISCARD", style: .Preferred, handler: { (_) in
                NSNotificationCenter.defaultCenter().postNotificationName("comment.hide.keyboard.allow", object: nil)
            }))
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName("comment.hide.keyboard.allow", object: nil)
        }
    }
    
    func addComment(comment: String, sender: UITextView) {
        guard comment.characters.count < 1000 else {
            Constants.showAlert("SibLinks", message: "Your comment must be less than 1000 characters!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
            return
        }
        
        if let headerView = self.tableView.headerViewForSection(0) as? SLVideoCommentHeaderView {
            sender.resignFirstResponder()
            NSNotificationCenter.defaultCenter().postNotificationName("comment.hide.keyboard.allow", object: nil)
            headerView.editTextField.resignFirstResponder()
        }
        
        if let videoId = video?.objectId {
            if admission {
                if let authorId = video?.mentor?.objectId {
                    VideoRouter(endpoint: VideoEndpoint.PostCommentAdmission(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, authorId: authorId, videoId: videoId, content: comment)).request(completion: { (result) in
                        switch result {
                        case .Ok:
                            self.loadObjects()
                        default:
                            print("Error")
                        }
                    })
                }
            } else {
                if let authorId = video?.mentor?.objectId {
                    VideoRouter(endpoint: VideoEndpoint.PostComment(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, authorId: authorId, videoId: videoId, content: comment)).request(completion: { (result) in
                        switch result {
                        case .Ok:
                            self.loadObjects()
                        default:
                            print("Error")
                        }
                    })
                }
            }
        }
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        
        if let video = video {
            let query = VideoRouter(endpoint: VideoEndpoint.GetComment(videoId: video.objectId!))
            query.request(completion: { (result) in
                switch result {
                case .Success(let objects):
                    if let comments = objects as? [SLComment] {
                        let numberOfComments = comments.count
                        if numberOfComments > 1 {
                            self.menuItemView?.titleLabel.text = "\(numberOfComments) COMMENTS"
                        } else {
                            self.menuItemView?.titleLabel.text = "\(numberOfComments) COMMENT"
                        }
                    }
                    
                default:
                    print("Error")
                }
            })
        }
    }
    
    // MARK: - Query
    override func queryForTable() -> BaseRouter? {
        if let video = video {
            if admission {
                return VideoRouter(endpoint: VideoEndpoint.GetCommentAdmission(videoId: video.objectId!))
            } else {
                let query = VideoRouter(endpoint: VideoEndpoint.GetComment(videoId: video.objectId!))
                return query
            }
        }
        return nil
    }
    
    // MARK: - Table view datasource
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: DataModel) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLVideoCommentViewCell.cellIdentifier(), forIndexPath: indexPath)
        if let commentCell = cell as? SLVideoCommentViewCell {
            commentCell.configCellWithData(object)
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if shouldShowPaginationCell() && indexPath == indexPathForPaginationCell() {
            return 30
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(SLVideoCommentHeaderView.cellIdentifier()) as? SLVideoCommentHeaderView {
            headerView.delegate = self
            self.activeTextView = headerView.commentView.commentTextView
            
            return headerView
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    // MARK: - UIScrollView
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        if scrollView.contentOffset.y >= 0 {
            if let viewController = delegate {
                viewController.openRelatedAndCommentOfVideoHeader()
            }
        }
    }
}
