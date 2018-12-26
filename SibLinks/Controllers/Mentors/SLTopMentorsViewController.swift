//
//  SLTopMentorsViewController.swift
//  SibLinks
//
//  Created by Jana on 9/8/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

enum TopMentor: Int {
    case Subscriber = 0
    case Rate
    case Like
}

class SLTopMentorsViewController: SLQueryTableViewController {
    lazy var categories: [SLCategory] = self.createCategories()
    private func createCategories() -> [SLCategory] {
        var categories = [SLCategory]()
        categories = Constants.appDelegate().categories
        
        let all = SLCategory()
        all.objectId = -1
        all.subject = "All"
        categories.insert(all, atIndex: 0)
        
        return categories
    }
    
    var category: SLCategory?
    
    override func viewDidLoad() {
        self.tableView.separatorStyle = .None
        super.viewDidLoad()
        
        self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left)])
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loadObject), name: Constants.SUBSCRIBER_CHANGE, object: nil)
        // Register
        self.tableView.registerNib(SLTopMentorsTableViewCell.nib(), forCellReuseIdentifier: SLTopMentorsTableViewCell.cellIdentifier())
    }
    
    override func queryForTable() -> BaseRouter? {
        // Subclass override method to query database
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: DataModel) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLTopMentorsTableViewCell.cellIdentifier(), forIndexPath: indexPath)
        
        if let topMentorsCell = cell as? SLTopMentorsTableViewCell {
            if let mentor = object as? SLMentor {
                if let categoriesId = mentor.categoriesId {
                    let categoriesId = categoriesId.componentsSeparatedByString(",")
                    var categoriesOfMentor = [SLCategory]()
                    for categoryId in categoriesId {
                        for category in categories {
                            if category.objectId == Int(categoryId) {
                                categoriesOfMentor.append(category)
                            }
                        }
                    }
                    mentor.categories = categoriesOfMentor
                }
                
                topMentorsCell.configCellWithData(mentor)
            } else {
                topMentorsCell.configCellWithData(object)
            }
            
            if indexPath.row == 0 {
                topMentorsCell.topLineView.hidden = true
            } else {
                topMentorsCell.topLineView.hidden = false
            }
            
            if indexPath.row == self.objects().count - 1 {
                topMentorsCell.bottomLineView.hidden = true
            } else {
                topMentorsCell.bottomLineView.hidden = false
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mentorDetailController = SLMentorProfileViewController.controller
        let mentor = objectAtIndexPath(indexPath) as? SLMentor
        mentorDetailController.mentor = mentor
        self.navigationController?.pushViewController(mentorDetailController, animated: true)
    }
}
