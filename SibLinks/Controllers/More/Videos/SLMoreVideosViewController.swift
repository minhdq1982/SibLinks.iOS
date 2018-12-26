//
//  SLMoreVideosViewController.swift
//  SibLinks
//
//  Created by Jana on 10/20/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLMoreVideosViewController: SLVideoCachedViewController {
    
    var query: BaseRouter?
    var navigationTitle: String?
    var recentUploadedVideo = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(SLRecentUploadedTableViewCell.nib(), forCellReuseIdentifier: SLRecentUploadedTableViewCell.cellIdentifier())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = navigationTitle
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = nil
    }
    
    override func queryForTable() -> BaseRouter? {
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: DataModel) -> UITableViewCell {
        if recentUploadedVideo {
            let cell = tableView.dequeueReusableCellWithIdentifier(SLRecentUploadedTableViewCell.cellIdentifier()) as! SLRecentUploadedTableViewCell
            cell.delegate = self
            cell.configCellWithData(object)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(SLVideoSuggestedViewCell.cellIdentifier()) as! SLVideoSuggestedViewCell
            cell.delegate = self
            cell.configCellWithData(object)
            
            return cell
        }
    }
}
