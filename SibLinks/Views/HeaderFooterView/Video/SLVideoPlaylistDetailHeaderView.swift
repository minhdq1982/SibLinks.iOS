//
//  SLVideoPlaylistDetailHeaderView.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/8/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLVideoPlaylistDetailHeaderView: SLBaseTableViewHeaderFooterView {
    
    @IBOutlet weak var playlistNameLabel: UILabel!
    @IBOutlet weak var mentorNameLabel: UILabel!
    @IBOutlet weak var totalVideoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension SLVideoPlaylistDetailHeaderView {
    
    override static func cellIdentifier() -> String {
        return "SLVideoPlaylistDetailHeaderViewID"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let playlist = data as? SLPlaylist {
            if let name = playlist.name {
                playlistNameLabel.text = name
            } else {
                playlistNameLabel.text = ""
            }
            
            if let name = playlist.mentor?.name() {
                mentorNameLabel.text = name
            } else {
                mentorNameLabel.text = ""
            }
            
            if let numberOfVideo = playlist.numberOfVideo {
                if numberOfVideo > 1 {
                    totalVideoLabel.text = "\(numberOfVideo) videos"
                } else {
                    totalVideoLabel.text = "\(numberOfVideo) video"
                }
            } else {
                totalVideoLabel.text = "0 video"
            }
        } else {
            playlistNameLabel.text = ""
            totalVideoLabel.text = ""
            mentorNameLabel.text = ""
        }
    }
}

extension SLVideoPlaylistDetailHeaderView {
    
    // MARK: - Actions
    @IBAction func startPlaylist(sender: AnyObject) {
        if let viewController = delegate as? SLVideoOfPlaylistViewController {
            viewController.startPlaylist()
        }
    }
    
}
