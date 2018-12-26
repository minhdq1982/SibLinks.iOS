//
//  SLMoreSubscribersViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 11/15/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLMoreSubscribersViewController: SLTopMentorsViewController {
    
    var query: BaseRouter?
    var navigationTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = navigationTitle
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func queryForTable() -> BaseRouter? {
        return query
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mentor = objectAtIndexPath(indexPath) as? SLMentor
        let subscriberViewController = SLVideoSubscriberViewController.instantiateFromStoryboard(Constants.VIDEO_STORYBOARD)
        subscriberViewController.subscriber = mentor
        
        self.navigationController?.pushViewController(subscriberViewController, animated: true)
    }
}
