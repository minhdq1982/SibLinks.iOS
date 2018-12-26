//
//  SLVideoSubscriberListViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/17/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import PagingMenuController

class SLVideoSubscriberListViewController: SLQueryTableViewController {

    var isSubscriptions: Bool = false
    var menuItemView: MenuItemView?
    var mentor: SLMentor?
    override func viewDidLoad() {
        self.tableView.separatorStyle = .None
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tableView.registerNib(SLVideoSuggestedViewCell.nib(), forCellReuseIdentifier: SLVideoSuggestedViewCell.cellIdentifier())
        self.tableView.registerNib(SLRecentUploadedTableViewCell.nib(), forCellReuseIdentifier: SLRecentUploadedTableViewCell.cellIdentifier())
        (self.emptyView as? SLEmptyView)?.errorTitleLabel.text = "Found no video."
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func queryForTable() -> BaseRouter? {
        if let mentor = mentor {
            VideoRouter(endpoint: VideoEndpoint.GetCountVideoOfMentor(mentorId: mentor.objectId!)).request(completion: { (result) in
                switch result {
                case .Success(let objects):
                    if let count = objects as? Int {
                        if count > 1 {
                            self.menuItemView?.titleLabel.text = "\(count) VIDEOS"
                        } else {
                            self.menuItemView?.titleLabel.text = "\(count) VIDEO"
                        }
                    }
                default:
                    print("Error")
                }
            })
            
            return VideoRouter(endpoint: VideoEndpoint.GetVideoOfMentor(mentorId: mentor.objectId!))
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: DataModel) -> UITableViewCell {
        if isSubscriptions {
            let cell = tableView.dequeueReusableCellWithIdentifier(SLRecentUploadedTableViewCell.cellIdentifier()) as! SLRecentUploadedTableViewCell
            cell.configCellWithData(object)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(SLVideoSuggestedViewCell.cellIdentifier()) as! SLVideoSuggestedViewCell
            cell.configCellWithData(object)
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if shouldShowPaginationCell() && indexPath == indexPathForPaginationCell() {
            return 30
        }
        
        return 90
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailViewController = SLVideoDetailViewController.instantiateFromStoryboard(Constants.VIDEO_STORYBOARD)
        if let video = objectAtIndexPath(indexPath) as? SLVideo {
            if let mentor = mentor {
                video.mentor = mentor
            }
            
            detailViewController.video = video
            self.presentViewController(detailViewController, animated: true, completion: nil)
        }
    }
}
