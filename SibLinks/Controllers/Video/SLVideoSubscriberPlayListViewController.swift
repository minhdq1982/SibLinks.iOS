//
//  SLVideoSubscriberPlayListViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/17/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import PagingMenuController

class SLVideoSubscriberPlayListViewController: SLQueryTableViewController {

    var menuItemView: MenuItemView?
    var mentor: SLMentor?
    override func viewDidLoad() {
        self.tableView.separatorStyle = .None
        super.viewDidLoad()

        // Register
        self.tableView.registerNib(SLVideoPlaylistViewCell.nib(), forCellReuseIdentifier: SLVideoPlaylistViewCell.cellIdentifier())
        
        (self.emptyView as? SLEmptyView)?.errorTitleLabel.text = "Found no playlist."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func queryForTable() -> BaseRouter? {
        if let mentor = mentor {
            VideoRouter(endpoint: VideoEndpoint.GetCountPlaylistOfMentor(mentorId: mentor.objectId!)).request(completion: { (result) in
                switch result {
                case .Success(let count):
                    if let count = count as? Int {
                        if count > 1 {
                            self.menuItemView?.titleLabel.text = "\(count) PLAYLISTS"
                        } else {
                            self.menuItemView?.titleLabel.text = "\(count) PLAYLIST"
                        }
                    } else {
                        self.menuItemView?.titleLabel.text = "PLAYLIST"
                    }
                default:
                    print("Error")
                }
            })
            
            return VideoRouter(endpoint: VideoEndpoint.GetPlaylistOfMentor(mentorId: mentor.objectId!))
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: DataModel) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLVideoPlaylistViewCell.cellIdentifier()) as! SLVideoPlaylistViewCell
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
        let detailViewController = SLVideoOfPlaylistViewController(style: .Grouped)
        if let playlist = objectAtIndexPath(indexPath) as? SLPlaylist {
            if let mentor = mentor {
                playlist.mentor = mentor
            }
            detailViewController.playlist = playlist
            self.navigationController?.pushViewController(detailViewController, animated: true)
        }
    }

}
