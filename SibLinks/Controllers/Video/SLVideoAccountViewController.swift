//
//  SLVideoAccountViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/12/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

enum VideoAccount: Int {
    case Favourite = 0
    case History
}

class SLVideoAccountViewController: SLBaseTableViewController {
    
    @IBOutlet weak var favouriteLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    
    var imageMenu = ["History", "Favourite"]
    
    let historyQuery = VideoRouter(endpoint: VideoEndpoint.GetHistory(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!))
    let favouriteQuery = VideoRouter(endpoint: VideoEndpoint.GetFavourite(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!))
    var historyArray: [SLVideo]?
    var favouriteArray: [SLVideo]?
    var historyTitle: String = "History".localized
    var favouriteTitle: String = "Favorites".localized
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        historyQuery.request { (result) in
            switch result {
            case .Success(let objects):
                if let videos = objects as? [SLVideo] {
                    self.historyArray = videos
                }
                
            default:
                print("Error")
            }
        }
        
        favouriteQuery.request { (result) in
            switch result {
            case .Success(let objects):
                if let videos = objects as? [SLVideo] {
                    self.favouriteArray = videos
                }
                
            default:
                print("Error")
            }
        }
        
        historyQuery.request { (result) in
            switch result {
            case .Success(let objects):
                if objects.count > 1 {
                    self.historyTitle = "\(objects.count) History Videos".localized
                } else {
                    self.historyTitle = "\(objects.count) History Video".localized
                }
                self.historyLabel.text = self.historyTitle
                
            default:
                print("Error")
            }
        }
        
        VideoRouter(endpoint: VideoEndpoint.CheckCountFavourite(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!)).request { (result) in
            switch result {
            case .Success(let count):
                if (count as? Int) > 1 {
                    self.favouriteTitle = "\(count) Favorite Videos"
                } else {
                    self.favouriteTitle = "\(count) Favorite Video"
                }
                self.favouriteLabel.text = self.favouriteTitle
                
            default:
                print("Error")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let menu = VideoAccount(rawValue: indexPath.row) {
            switch menu {
            case .History:
                let videoHistoryViewController = SLVideoHistoryViewController(style: .Plain)
                videoHistoryViewController.title = self.historyTitle
                videoHistoryViewController.historyQuery = historyQuery
                self.navigationController?.pushViewController(videoHistoryViewController, animated: true)
            case .Favourite:
                let videoFavouriteViewController = SLVideoFavouriteViewController(style: .Plain)
                videoFavouriteViewController.title = self.favouriteTitle
                videoFavouriteViewController.favouriteQuery = favouriteQuery
                self.navigationController?.pushViewController(videoFavouriteViewController, animated: true)
            }
        }
    }
}
