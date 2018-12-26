//
//  SLVideoListViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/12/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLVideoListViewController: SLQueryTableViewController {
    
    var category: SLCategory?
    
    override func viewDidLoad() {
        tableView.separatorStyle = .None
        super.viewDidLoad()
        tableView.registerNib(SLVideoListViewCell.nib(), forCellReuseIdentifier: SLVideoListViewCell.cellIdentifier())
        
        (self.emptyView as? SLEmptyView)?.errorTitleLabel.text = "Found no video."
    }
        
    // MARK: - Table view datasource
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: DataModel) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLVideoListViewCell.cellIdentifier(), forIndexPath: indexPath)
        if let videoCell = cell as? SLVideoListViewCell {
            videoCell.configCellWithData(object)
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if shouldShowPaginationCell() && indexPath == indexPathForPaginationCell() {
            return 30
        }
        return (Constants.screenSize.width*9)/16+65
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let video = objectAtIndexPath(indexPath) as? SLVideo {
            presentVideoDetail(video)
        }
    }
    
    func presentVideoDetail(video: SLVideo) {
        let detailViewController = SLVideoDetailViewController.instantiateFromStoryboard(Constants.VIDEO_STORYBOARD)
        detailViewController.video = video
        
        presentViewController(detailViewController, animated: true, completion: nil)
    }
}
