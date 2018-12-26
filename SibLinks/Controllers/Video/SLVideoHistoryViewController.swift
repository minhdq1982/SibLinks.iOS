//
//  SLVideoHistoryViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/16/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLVideoHistoryViewController: SLVideoCachedViewController {
    
    private var deleteAllHistory = false
    
    var historyQuery: VideoRouter?
    
    override func viewDidLoad() {
        paginationEnabled = false
        super.viewDidLoad()
        
        self.enableSwipeTableCell = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left), (ItemType.Delete, ItemPosition.Right)])
    }
    
    override func queryForTable() -> BaseRouter? {
        return historyQuery
    }
    
    override func queryForDelete(object: DataModel) -> BaseRouter? {
        if let video = object as? SLVideo {
            return VideoRouter(endpoint: VideoEndpoint.HistoryRemoved(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, videoId: video.objectId!))
        }
        
        return nil
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        
        self.historyQuery?.request(completion: { (result) in
            switch result {
            case .Success(let objects):
                if objects.count > 1 {
                    self.title = "\(objects.count) History Videos".localized
                } else {
                    self.title = "\(objects.count) History Video".localized
                }
                
            default:
                print("Error")
            }
        })
    }
    
    override func remove(sender: UIBarButtonItem) {
        sender.enabled = false
        deleteAllHistory = true
        startLoading(false, completion: nil)
        
        VideoRouter(endpoint: VideoEndpoint.HistoryRemoved(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, videoId: 0)).request { (result) in
            switch result {
            case .Success(let status):
                sender.enabled = true
                self.deleteAllHistory = false

                if let status = status as? Bool {
                    if status {
                        self.clear()
                    }
                }
                self.endLoading(false, completion: nil)
                
                self.historyQuery?.request(completion: { (result) in
                    switch result {
                    case .Success(let objects):
                        if objects.count > 1 {
                            self.title = "\(objects.count) History Videos".localized
                        } else {
                            self.title = "\(objects.count) History Video".localized
                        }
                        
                    default:
                        print("Error")
                    }
                })
                
            default:
                print("error")
                sender.enabled = true
                self.deleteAllHistory = false
                self.endLoading(false, completion: nil)
            }
        }
    }
    
    override func objectsDidDelete() {
        super.objectsDidDelete()
        
        self.historyQuery?.request(completion: { (result) in
            switch result {
            case .Success(let objects):
                if objects.count > 1 {
                    self.title = "\(objects.count) History Videos".localized
                } else {
                    self.title = "\(objects.count) History Video".localized
                }
                
            default:
                print("Error")
            }
        })
    }
    
}

extension SLVideoHistoryViewController {
    
    override func hasContent() -> Bool {
        if deleteAllHistory {
            return false
        } else {
            return objects().count > 0
        }
    }
    
}
