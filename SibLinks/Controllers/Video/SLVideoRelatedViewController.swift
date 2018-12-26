//
//  SLVideoRelatedViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/29/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLVideoRelatedViewController: SLQueryTableViewController {
    
    weak var delegate: SLVideoDetailViewController?
    var video: SLVideo?
    var admission = false
    var admissionId = 0
    
    override func viewDidLoad() {
        self.tableView.separatorStyle = .None
        super.viewDidLoad()
        
        self.tableView.registerNib(SLVideoSuggestedViewCell.nib(), forCellReuseIdentifier: SLVideoSuggestedViewCell.cellIdentifier())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func queryForTable() -> BaseRouter? {
        if admission {
            var subjectId = -1
            if let categoryId = self.video?.category?.objectId {
                subjectId = categoryId
            }
            
            return VideoRouter(endpoint: VideoEndpoint.GetRelatedVideos(subjectId: subjectId, admissionId: admissionId))
        } else {
            var subjectId = -1
            if let categoryId = self.video?.category?.objectId {
                subjectId = categoryId
            }
            
            return VideoRouter(endpoint: VideoEndpoint.GetSuggestVideos(subjectId: subjectId))
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: DataModel) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLVideoSuggestedViewCell.cellIdentifier()) as! SLVideoSuggestedViewCell
        cell.configCellWithData(object)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if shouldShowPaginationCell() && indexPath == indexPathForPaginationCell() {
            return 30
        }
        
        return 90
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let video = objectAtIndexPath(indexPath) as? SLVideo {
            if let viewController = delegate {
                viewController.changeVideo(video, addedPlaylist: false)
            }
        }
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
