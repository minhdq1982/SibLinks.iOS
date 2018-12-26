//
//  SLVideoFavouriteViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/16/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLVideoFavouriteViewController: SLVideoCachedViewController {
    
    var favouriteQuery: VideoRouter?
    
    override func viewDidLoad() {
        paginationEnabled = false
        super.viewDidLoad()
        
        self.enableSwipeTableCell = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left)])
    }
    
    override func queryForTable() -> BaseRouter? {
        return favouriteQuery
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        
        VideoRouter(endpoint: VideoEndpoint.CheckCountFavourite(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!)).request { (result) in
            switch result {
            case .Success(let count):
                if let value = count as? Int {
                    if value > 1 {
                        self.title = "\(count) Favorite Videos"
                    } else {
                        self.title = "\(count) Favorite Video"
                    }
                }
                
            default:
                print("Error")
            }
        }
    }
    
    override func objectsDidDelete() {
        super.objectsDidDelete()
        
        VideoRouter(endpoint: VideoEndpoint.CheckCountFavourite(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!)).request { (result) in
            switch result {
            case .Success(let count):
                if let value = count as? Int {
                    if value > 1 {
                        self.title = "\(count) Favorite Videos"
                    } else {
                        self.title = "\(count) Favorite Video"
                    }
                }
                
            default:
                print("Error")
            }
        }
    }
    
    override func queryForDelete(object: DataModel) -> BaseRouter? {
        if let video = object as? SLVideo {
            return VideoRouter(endpoint: VideoEndpoint.FavouriteRemoved(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, videoId: video.objectId!))
        }
        
        return nil
    }
    
}
