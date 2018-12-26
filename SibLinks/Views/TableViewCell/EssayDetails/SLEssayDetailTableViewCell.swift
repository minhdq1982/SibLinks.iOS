//
//  SLEssayDetailTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 10/6/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import IBAnimatable
import Kingfisher

class SLEssayDetailTableViewCell: SLBaseTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var avatarImageView: AnimatableImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarImageView.kf_indicatorType = .Activity
    }
}

extension SLEssayDetailTableViewCell {
    
    // MARK: - Reuse identifer
    
    override class func cellIdentifier() -> String {
        return "SLEssayDetailTableViewCell"
    }
    
    // MARK: - Config data
    override func configCellWithData(data: AnyObject?) {
        if let essay = data as? SLEssay {
            if let title = essay.title {
                titleLabel.text = title
            }
            
            if let content = essay.desc {
                contentLabel.text = content
            }
            
            timeLabel.text = Constants.dateToTime(essay.updatedAt)
            
            if let imagePath = essay.user?.imageUrl {
                avatarImageView.kf_setImageWithURL(NSURL(string: imagePath), placeholderImage: Constants.noAvatarImage)
            } else {
                avatarImageView.image = Constants.noAvatarImage
            }
        }
    }
}
