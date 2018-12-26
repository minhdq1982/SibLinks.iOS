//
//  SLVideoPlaylistHeaderView.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/29/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLVideoPlaylistHeaderView: SLBaseTableViewHeaderFooterView {
    
    @IBOutlet weak var playlistLabel: UILabel!
    @IBOutlet weak var totalVideoLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBAction func toogleChangeHeader(sender: AnyObject) {
        if let viewController = delegate as? SLVideoDetailViewController {
            viewController.openPlaylistHeader()
        }
    }
}

extension SLVideoPlaylistHeaderView {
    
    override static func cellIdentifier() -> String {
        return "SLVideoPlaylistHeaderViewID"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let playlist = data as? SLPlaylist {
            if let name = playlist.name {
                playlistLabel.text = name
            }
            
            if let numberOfVideos = playlist.numberOfVideo {
                if numberOfVideos > 1 {
                    totalVideoLabel.text = "\(numberOfVideos) videos"
                } else {
                    totalVideoLabel.text = "\(numberOfVideos) video"
                }
            } else {
                if let videos = playlist.videos {
                    let numberOfVideos = videos.count
                    if numberOfVideos > 1 {
                        totalVideoLabel.text = "\(numberOfVideos) videos"
                    } else {
                        totalVideoLabel.text = "\(numberOfVideos) video"
                    }
                } else {
                    totalVideoLabel.text = ""
                }
            }
        } else {
            playlistLabel.text = ""
            totalVideoLabel.text = ""
        }
    }
}
