//
//  SLVideoCommentViewCell.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/30/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import IBAnimatable

class SLVideoCommentViewCell: SLBaseTableViewCell {
    
    @IBOutlet weak var avatarImageView: AnimatableImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.kf_indicatorType = .Activity
    }
}

extension SLVideoCommentViewCell {
    override static func cellIdentifier() -> String {
        return "SLVideoCommentViewCellID"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let comment = data as? SLComment {
            if let content = comment.content {
                contentLabel.text = content
            } else {
                contentLabel.text = ""
            }
            
            if let time = comment.updatedAt {
                timeLabel.text = Constants.dateToTime(time)
                if Constants.dateToTime(time).isEmpty {
                    timeLabel.text = "just now"
                }
            } else {
                timeLabel.text = "Not available"
            }
            
            if let user = comment.user {
                if let imagePath = user.imageUrl {
                    avatarImageView.kf_setImageWithURL(NSURL(string: imagePath), placeholderImage: Constants.noAvatarImage)
                } else {
                    avatarImageView.image = Constants.noAvatarImage
                }
                
                nameLabel.text = user.name()
            }
        } else {
            contentLabel.text = ""
            avatarImageView.image = nil
        }
    }
}
