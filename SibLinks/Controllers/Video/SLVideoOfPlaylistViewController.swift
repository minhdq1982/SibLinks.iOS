//
//  SLVideoOfPlaylistViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/6/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLVideoOfPlaylistViewController: SLQueryTableViewController {

    var playlist: SLPlaylist?
    weak var delegate: SLVideoDetailViewController?
    
    override func viewDidLoad() {
        self.tableView.separatorStyle = .None
        self.paginationEnabled = false
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.whiteColor()
        // Do any additional setup after loading the view.
        self.tableView.registerNib(SLVideoSuggestedViewCell.nib(), forCellReuseIdentifier: SLVideoSuggestedViewCell.cellIdentifier())
        self.tableView.registerNib(SLVideoPlaylistDetailHeaderView.nib(), forHeaderFooterViewReuseIdentifier: SLVideoPlaylistDetailHeaderView.cellIdentifier())
        if let name = playlist?.name {
            self.navigationItem.title = name
        } else {
            self.navigationItem.title = "Playlist".localized
        }
        self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left)])
        (self.emptyView as? SLEmptyView)?.errorTitleLabel.text = "Found no video."
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action
    func startPlaylist() {
        if objects().count > 0 {
            let detailViewController = SLVideoDetailViewController.instantiateFromStoryboard(Constants.VIDEO_STORYBOARD)
            if let video = objects()[0] as? SLVideo {
                detailViewController.video = video
                detailViewController.playlist = playlist
                self.presentViewController(detailViewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Query
    override func queryForTable() -> BaseRouter? {
        if let playlistId = playlist?.objectId {
            return VideoRouter(endpoint: VideoEndpoint.GetVideoOfPlaylist(playlistId: playlistId))
        }
        
        return nil
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        if let detailViewController = delegate {
            if let videos = objects() as? [SLVideo] {
                detailViewController.updateVideoPlaylist(videos)
            }
        }
    }
    
    // MARK: - UITableView
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: DataModel) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLVideoSuggestedViewCell.cellIdentifier()) as! SLVideoSuggestedViewCell
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
        if let detailViewController = delegate {
            // Return video to play
            if let video = objectAtIndexPath(indexPath) as? SLVideo {
                detailViewController.changeVideo(video, addedPlaylist: true)
            }
        } else {
            let detailViewController = SLVideoDetailViewController.instantiateFromStoryboard(Constants.VIDEO_STORYBOARD)
            if let video = objectAtIndexPath(indexPath) as? SLVideo {
                detailViewController.video = video
                detailViewController.playlist = playlist
                self.presentViewController(detailViewController, animated: true, completion: nil)
            }
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if delegate != nil {
            return nil
        }
        
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(SLVideoPlaylistDetailHeaderView.cellIdentifier())
        if let playlistHeader = headerView as? SLVideoPlaylistDetailHeaderView {
            playlistHeader.delegate = self
            playlistHeader.configCellWithData(self.playlist)
            return playlistHeader
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if delegate != nil {
            return 0
        }
        
        return 100
    }
}
