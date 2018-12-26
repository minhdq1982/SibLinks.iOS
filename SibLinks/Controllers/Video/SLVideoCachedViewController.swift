//
//  SLVideoCachedViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/16/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class SLVideoCachedViewController: SLQueryTableViewController {

    var enableSwipeTableCell: Bool = false
    
    override func viewDidLoad() {
        self.tableView.separatorStyle = .None
        super.viewDidLoad()

        self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left)])
        
        // Do any additional setup after loading the view.
        self.tableView.registerNib(SLVideoSuggestedViewCell.nib(), forCellReuseIdentifier: SLVideoSuggestedViewCell.cellIdentifier())
        (self.emptyView as? SLEmptyView)?.errorTitleLabel.text = "Video not found."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func queryForTable() -> BaseRouter? {
        return VideoRouter(endpoint: VideoEndpoint.GetVideos(subjectId: -1))
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: DataModel) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLVideoSuggestedViewCell.cellIdentifier()) as! SLVideoSuggestedViewCell
        cell.delegate = self
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
        let detailViewController = SLVideoDetailViewController.instantiateFromStoryboard(Constants.VIDEO_STORYBOARD)
        if let video = objectAtIndexPath(indexPath) as? SLVideo {
            detailViewController.video = video
            self.presentViewController(detailViewController, animated: true, completion: nil)
        }
    }
}

extension SLVideoCachedViewController: MGSwipeTableCellDelegate {
    
    // MARK: - MGSwipeTableCellDelegate
    
    func swipeTableCell(cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        return enableSwipeTableCell
    }
    
    func swipeTableCell(cell: MGSwipeTableCell, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        swipeSettings.transition = MGSwipeTransition.Border
        
        if (direction == MGSwipeDirection.RightToLeft) {
            let deleteButton = MGSwipeButton(title: "DELETE".localized, backgroundColor: UIColor(hexString: Constants.SIBLINKS_DELETE_BUTTON_COLOR), callback: { (sender) -> Bool in
                if let indexPath = self.tableView.indexPathForCell(sender) {
                    self.removeObjectAtIndexPath(indexPath)
                }
                
                return true
            })
            
            deleteButton.titleLabel?.font = Constants.regularFontOfSize(14)
            return [deleteButton]
        }
        
        return nil
    }
    
}
