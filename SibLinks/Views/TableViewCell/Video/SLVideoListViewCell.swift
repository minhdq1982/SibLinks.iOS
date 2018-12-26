//
//  SLVideoListViewCell.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/12/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import IBAnimatable
import Kingfisher

class SLVideoListViewCell: SLBaseTableViewCell {

    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var avatarImageView: AnimatableImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var durationLabel: AnimatableLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.kf_indicatorType = .Activity
        videoImageView.kf_indicatorType = .Activity
    }
}

extension SLVideoListViewCell {
    
    override class func cellIdentifier() -> String {
        return "SLVideoListCellId"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let video = data as? SLVideo {
            if let thumbnailImageName = video.thumbnailImageName {
                videoImageView.kf_setImageWithURL(NSURL(string: thumbnailImageName))
            } else {
                videoImageView.image = nil
            }
            
            if let title = video.title {
                videoTitleLabel.text = title
            } else {
                videoTitleLabel.text = ""
            }
            
            if let duration = video.duration {
                durationLabel.text = duration/*Constants.secondsToHoursMinutesSeconds(duration)*/
            } else {
                durationLabel.text = "0:00"
            }
            
            if let mentor = video.mentor {
                if let profileImageName = mentor.profileImageName {
                    avatarImageView.kf_setImageWithURL(NSURL(string: profileImageName), placeholderImage: Constants.noAvatarImage)
                } else {
                    avatarImageView.image = Constants.noAvatarImage
                }
                
                var videoDescription = mentor.name()
                
                if let createAt = video.createdAt {
                    videoDescription += " - " + createAt.monthFormatterString()
                }
                
                if let numberOfViews = video.numberOfViews {
                    let views = Constants.viewsCount.stringFromNumber(numberOfViews as NSNumber)!
                    if videoDescription.characters.count > 0 {
                        if numberOfViews > 1 {
                            videoDescription += " - " + views + " views"
                        } else {
                            videoDescription += " - " + views + " view"
                        }
                    } else {
                        videoDescription = views
                    }
                }
                // Pin: • 
                accountLabel.text = videoDescription
            } else {
                avatarImageView.image = nil
                accountLabel.text = ""
            }
        } else {
            videoImageView.image = nil
            videoTitleLabel.text = ""
            durationLabel.text = ""
            avatarImageView.image = Constants.noAvatarImage
            accountLabel.text = ""
        }
    }
}
