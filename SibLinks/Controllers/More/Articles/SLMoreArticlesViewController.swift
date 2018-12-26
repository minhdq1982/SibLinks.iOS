//
//  SLMoreArticlesViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/20/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLMoreArticlesViewController: SLQueryTableViewController {
    var query: BaseRouter?
    var navigationTitle: String?
    
    override func viewDidLoad() {
        self.tableView.separatorStyle = .None
        super.viewDidLoad()
        
        self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left)])
        
        // Do any additional setup after loading the view.
        self.tableView.registerNib(SLVideoSuggestedViewCell.nib(), forCellReuseIdentifier: SLVideoSuggestedViewCell.cellIdentifier())
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: DataModel) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLVideoSuggestedViewCell.cellIdentifier()) as! SLVideoSuggestedViewCell
        cell.configCellWithData(object)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let article = objectAtIndexPath(indexPath) as? SLArticle {
            let viewController = SLArticlesViewController.controller
            viewController.article = article
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
}
