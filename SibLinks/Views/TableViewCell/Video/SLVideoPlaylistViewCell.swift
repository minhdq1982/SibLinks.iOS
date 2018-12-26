//
//  SLVideoPlaylistViewCell.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/29/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import IBAnimatable

class SLVideoPlaylistViewCell: SLBaseTableViewCell {
    @IBOutlet weak var playlistImageView: UIImageView!
    @IBOutlet weak var playlistTitleLabel: UILabel!
    @IBOutlet weak var numbersLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playlistImageView.kf_indicatorType = .Activity
    }
}

extension SLVideoPlaylistViewCell {
    override static func cellIdentifier() -> String {
        return "SLVideoPlaylistViewCellID"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let playlist = data as? SLPlaylist {
            if let thumbnailImageName = playlist.thumbnailImageName {
                playlistImageView.kf_setImageWithURL(NSURL(string: thumbnailImageName))
            } else {
                playlistImageView.image = nil
            }
            
            if let name = playlist.name {
                playlistTitleLabel.text = name
            } else {
                playlistTitleLabel.text = ""
            }
            
            if let numberVideo = playlist.numberOfVideo {
                if numberVideo > 1 {
                    numbersLabel.text = "\(numberVideo) videos"
                } else {
                    numbersLabel.text = "\(numberVideo) video"
                }
            } else {
                numbersLabel.text = ""
            }
            
            let playlistUpdatedAt = Constants.dateToTime(playlist.createdAt)
            if let viewNumbers = playlist.numberOfView {
                if playlistUpdatedAt.characters.count > 0 {
                    descriptionLabel.text = playlistUpdatedAt + " - " + Constants.viewsCount.stringFromNumber((viewNumbers as NSNumber))! + " views"
                } else {
                    descriptionLabel.text = Constants.viewsCount.stringFromNumber((viewNumbers as NSNumber))! + " views"
                }
            } else {
                descriptionLabel.text = playlistUpdatedAt
            }
        } else {
            playlistImageView.image = nil
            playlistTitleLabel.text = ""
            numbersLabel.text = ""
        }
    }
}
