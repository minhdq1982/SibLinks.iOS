//
//  SLNotificationsViewController.swift
//  SibLinks
//
//  Created by Jana on 9/6/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLNotificationsViewController: SLQueryViewController {
    
    static let notificationsViewController = "SLNotificationsViewController"
    
    static var controller: SLNotificationsViewController! {
        let controller = UIStoryboard(name: Constants.NOTIFICATION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(SLNotificationsViewController.notificationsViewController) as! SLNotificationsViewController
        return controller
    }
    
    lazy var notificationNavigationView: NotificationNavigationView = {
        let notificationNavigationView = NotificationNavigationView.loadFromNib()
        notificationNavigationView.setValue(0)
        return notificationNavigationView
    }()
    
    var dayNotification = NSMutableArray()
    var sectionNotification = NSMutableArray()
    var cacheNotification = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = notificationNavigationView
        self.navigationBarButtonItems([(ItemType.Menu, ItemPosition.Left)])
        
        // Config tableView
        self.tableView.registerNib(SLNotificationsHeaderView.nib(), forHeaderFooterViewReuseIdentifier: SLNotificationsHeaderView.cellIdentifier())
        self.tableView.registerNib(SLNotificationsTableViewCell.nib(), forCellReuseIdentifier: SLNotificationsTableViewCell.cellIdentifier())
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didReceiveNotification(_:)), name: Constants.PUSH_NOTIFICATION, object: nil)
        
        NotificationRouter(endpoint: NotificationEndpoint.GetNotificationNotReaded(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!)).request { (result) in
            switch result {
            case .Success(let objects):
                if let value = objects as? Int {
                    self.notificationNavigationView.setValue(value)
                } else {
                    self.notificationNavigationView.setValue(0)
                }
                
            default:
                print("Error")
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove notifications
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.PUSH_NOTIFICATION, object: nil)
    }
    
    // MARK: - Notification
    func didReceiveNotification(notification: NSNotification) {
        self.loadObjects()
    }
    
    override func queryForTable() -> BaseRouter? {
        return NotificationRouter(endpoint: NotificationEndpoint.GetAllNotification(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, pageNo: currentPage, limit: objectsPerPage))
    }
    
    // MARK: - Parse notification
    func parseNotification() {
        guard var notifications = objects() as? [SLNotification] else {
            return
        }
        
        notifications = notifications.sort { $0.createdAt!.compare($1.createdAt!) == .OrderedDescending }
        
        dayNotification.removeAllObjects()
        sectionNotification.removeAllObjects()
        cacheNotification.removeAllObjects()
        
        for index in 0 ..< notifications.count {
            if index == 0 {
                let notification = notifications[index]
                
                sectionNotification.addObject(notification.createdAt!)
                cacheNotification.addObject(notification)
            } else {
                let currentNotification = notifications[index]
                let beforeNotification = notifications[index-1]
                
                if !isSame(beforeNotification.createdAt!, secondDate: currentNotification.createdAt!) {
                    dayNotification.addObject(cacheNotification.copy())
                    cacheNotification.removeAllObjects()
                    
                    sectionNotification.addObject(currentNotification.createdAt!)
                    cacheNotification.addObject(currentNotification)
                } else {
                    cacheNotification.addObject(currentNotification)
                }
            }
        }
        
        if cacheNotification.count > 0 {
            dayNotification.addObject(cacheNotification.copy())
            cacheNotification.removeAllObjects()
        }
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        parseNotification()
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionNotification.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayNotification.objectAtIndex(section).count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLNotificationsTableViewCell.cellIdentifier())
        
        if let notificationCell = cell as? SLNotificationsTableViewCell {
            notificationCell.delegate = self
            notificationCell.indexPath = indexPath
            notificationCell.configCellWithData(dayNotification[indexPath.section][indexPath.row])
            
            if indexPath.row == 0 {
                notificationCell.topLineView.hidden = true
            } else {
                notificationCell.topLineView.hidden = false
            }
            
            if indexPath.row == dayNotification[indexPath.section].count - 1 {
                notificationCell.bottomLineView.hidden = true
            } else {
                notificationCell.bottomLineView.hidden = false
            }
            return notificationCell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(SLNotificationsHeaderView.cellIdentifier())
        
        if let notificationHeader = header as? SLNotificationsHeaderView {
            if let time = sectionNotification[section] as? NSDate {
                notificationHeader.configCellWithData(time)
            }
            return header
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let object = self.dayNotification[indexPath.section] as? [SLNotification] {
            let notification = object[indexPath.row]
            
            if let notificationId = notification.subjectId {
                notification.status = true
                NotificationRouter(endpoint: NotificationEndpoint.UpdateStatusNotification(notificationId: notificationId, status: true)).request(completion: { (result) in
                    switch result {
                    case .Ok:
                        print("Seen")
                    default:
                        print("Error")
                    }
                })
            }
            
            switch notification.type {
            case .Answer:
                if let linkQuestion = notification.linkToId {
                    let detailViewController = SLAskDetailViewController()
                    detailViewController.allowEdited = false
                    let question = SLQuestion()
                    question.objectId = linkQuestion
                    detailViewController.question = question
                    self.navigationController?.pushViewController(detailViewController, animated: true)
                }
                
            case .Essay:
                if let linkEssay = notification.linkToId {
                    let essayDetailsViewController = SLEssayDetailsViewController.controller
                    let essay = SLEssay()
                    essay.objectId = linkEssay
                    essayDetailsViewController.essay = essay
                    self.presentViewController(essayDetailsViewController, animated: true, completion: nil)
                }
                
            default:
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SLNotificationsViewController {
    
    // MARK: - Compare
    
    func isSame(firstDate: NSDate, secondDate: NSDate) -> Bool {
        let firstDateString = NSDateFormatter.localizedStringFromDate(firstDate, dateStyle: .MediumStyle, timeStyle: .NoStyle)
        let secondDateString = NSDateFormatter.localizedStringFromDate(secondDate, dateStyle: .MediumStyle, timeStyle: .NoStyle)
        return (firstDateString == secondDateString)
    }
}

extension SLNotificationsViewController {
    
    // MARK: - Actions
    
}
