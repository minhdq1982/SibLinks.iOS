//
//  SLMyEssayViewController.swift
//  SibLinks
//
//  Created by Jana on 9/30/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import SDCAlertView

class SLMyEssayViewController: SLQueryTableViewController {
    
    static let myEssayViewControllerID = "SLMyEssayViewControllerID"
    
    static var controller: SLMyEssayViewController! {
        let controller = UIStoryboard(name: Constants.ADMISSION_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(SLMyEssayViewController.myEssayViewControllerID) as! SLMyEssayViewController
        return controller
    }
    
    var questionsArray = [SLQuestion]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyView = SLEssayEmptyView.loadFromNib()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(observerUploadEssay(_:)),
                                                         name: Constants.UPLOAD_ESSAY, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapOnEmptyView))
        tapGesture.cancelsTouchesInView = false
        emptyView?.addGestureRecognizer(tapGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func queryForTable() -> BaseRouter? {
        return EssayRouter(endpoint: EssayEndpoint.GetEssays(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!))
    }
    
    override func queryForDelete(object: DataModel) -> BaseRouter? {
        if let essayId = object.objectId {
            return EssayRouter(endpoint: EssayEndpoint.RemoveEssay(essayId: essayId))
        }
        
        return nil
    }
    
    func observerUploadEssay(notification: NSNotification) {
        loadObjects()
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: DataModel) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLAskTableViewCell.cellIdentifier(), forIndexPath: indexPath)
        
        if let myEssayCell = cell as? SLAskTableViewCell {
            myEssayCell.delegate = self
            myEssayCell.controller = self
            myEssayCell.indexPath = indexPath
            myEssayCell.configCellWithData(object)
            
            if indexPath.row == 0 {
                myEssayCell.topLineView.hidden = true
            } else {
                myEssayCell.topLineView.hidden = false
            }
            
            if indexPath.row == self.questionsArray.count - 1 {
                myEssayCell.bottomLineView.hidden = true
            } else {
                myEssayCell.bottomLineView.hidden = false
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 107
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let essay = objectAtIndexPath(indexPath) as? SLEssay {
            let essayDetailsViewController = SLEssayDetailsViewController.controller
            essayDetailsViewController.essay = essay
            self.presentViewController(essayDetailsViewController, animated: true, completion: nil)
        }
    }
}

extension SLMyEssayViewController {

    // MARK: - Configure
    override func configView() {
        super.configView()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.registerNib(SLAskTableViewCell.nib(), forCellReuseIdentifier: SLAskTableViewCell.cellIdentifier())
    }
    
    func tapOnEmptyView() {
        let uploadEssayViewController = SLUploadEssayViewController.controller
        self.navigationController?.pushViewController(uploadEssayViewController, animated: true)
    }
}

extension SLMyEssayViewController: MGSwipeTableCellDelegate {
    
    // MARK: - MGSwipeTableCellDelegate
    
    func swipeTableCell(cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }
    
    func swipeTableCell(cell: MGSwipeTableCell, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        swipeSettings.transition = MGSwipeTransition.Border
        if (direction == MGSwipeDirection.RightToLeft) {
            if let indexPath = self.tableView.indexPathForCell(cell) {
                if let essay = self.objectAtIndexPath(indexPath) as? SLEssay {
                    if let status = essay.status {
                        if status == EssayStatus.Reviewed.rawValue {
                            let deleteButton = MGSwipeButton(title: "DELETE".localized, backgroundColor: UIColor(hexString: Constants.SIBLINKS_DELETE_BUTTON_COLOR), callback: { (sender) -> Bool in
                                if let indexPath = self.tableView.indexPathForCell(sender) {
                                    Constants.showAlert(message: "Are you sure you want to delete?", actions:
                                        AlertAction(title: Constants.CANCEL_ALERT_BUTTON, style: .Default),
                                        AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred, handler: { (_) in
                                            self.removeObjectAtIndexPath(indexPath, animated: false)
                                        }))
                                }
                                return true
                            })
                            
                            deleteButton.titleLabel?.font = Constants.regularFontOfSize(14)
                            return [deleteButton]
                        } else {
                            let deleteButton = MGSwipeButton(title: "DELETE".localized, backgroundColor: UIColor(hexString: Constants.SIBLINKS_DELETE_BUTTON_COLOR), callback: { (sender) -> Bool in
                                if let indexPath = self.tableView.indexPathForCell(sender) {
                                    Constants.showAlert(message: "Are you sure you want to delete?", actions:
                                        AlertAction(title: Constants.CANCEL_ALERT_BUTTON, style: .Default),
                                        AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred, handler: { (_) in
                                            self.removeObjectAtIndexPath(indexPath, animated: false)
                                        }))
                                }
                                return true
                            })
                            
                            let editButton = MGSwipeButton(title: "EDIT".localized, backgroundColor: UIColor(hexString: Constants.SIBLINKS_EDIT_BUTTON_COLOR), callback: { (sender) -> Bool in
                                let uploadEssayViewController = SLUploadEssayViewController.controller
                                uploadEssayViewController.essay = essay
                                
                                self.navigationController?.pushViewController(uploadEssayViewController, animated: true)
                                
                                return true
                            })
                            
                            deleteButton.titleLabel?.font = Constants.regularFontOfSize(14)
                            editButton.titleLabel?.font = Constants.regularFontOfSize(14)
                            return [editButton, deleteButton]
                        }
                    }
                }
            }
            return nil
        }
        
        return nil
    }
}
