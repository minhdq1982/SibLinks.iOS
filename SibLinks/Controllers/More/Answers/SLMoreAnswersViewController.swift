//
//  SLMoreAnswersViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/20/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLMoreAnswersViewController: SLQueryTableViewController {
    
    var query: BaseRouter?
    var navigationTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell
        self.tableView.registerNib(SLAnswerViewCell.nib(), forCellReuseIdentifier: SLAnswerViewCell.cellIdentifier())
        
        // Config tableview
        self.tableView.separatorStyle = .None
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = navigationTitle
        
        self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left)])
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = nil
    }
    
    // MARK: - Query
    override func queryForTable() -> BaseRouter? {
        return query
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: DataModel) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLAnswerViewCell.cellIdentifier(), forIndexPath: indexPath)
        
        if let answerCell = cell as? SLAnswerViewCell {
            answerCell.configCellWithData(object)
            
            if indexPath.row == 0 {
                answerCell.topLineView.hidden = true
            } else {
                answerCell.topLineView.hidden = false
            }
            
            if indexPath.row == objects().count - 1 {
                answerCell.bottomLineView.hidden = true
            } else {
                answerCell.bottomLineView.hidden = false
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 107
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let answer = objectAtIndexPath(indexPath) as? SLAnswer {
            if let questionId = answer.questionId {
                let detailViewController = SLAskDetailViewController()
                detailViewController.allowEdited = false
                let question = SLQuestion()
                question.objectId = questionId
                detailViewController.question = question
                self.navigationController?.pushViewController(detailViewController, animated: true)
            }
        }
    }
    
}
