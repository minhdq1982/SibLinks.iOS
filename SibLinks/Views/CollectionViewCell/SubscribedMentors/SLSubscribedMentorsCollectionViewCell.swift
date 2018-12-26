//
//  SLSubscribedMentorsCollectionViewCell.swift
//  SibLinks
//
//  Created by Jana on 9/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import IBAnimatable
import Cosmos

class SLSubscribedMentorsCollectionViewCell: SLBaseCollectionViewCell {
    
    @IBOutlet weak var avatarImageView: AnimatableImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.kf_indicatorType = .Activity
    }
}

extension SLSubscribedMentorsCollectionViewCell {
    
    override static func cellIdentifier() -> String {
        return "SLSubscribedMentorsCollectionViewCell"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let mentor = data as? SLMentor {
            if let profileImageName = mentor.profileImageName {
                avatarImageView.kf_setImageWithURL(NSURL(string: profileImageName), placeholderImage: Constants.noAvatarImage)
            } else {
                avatarImageView.image = Constants.noAvatarImage
            }
            
            nameLabel.text = mentor.name()
            
            if let rate = mentor.averageRate {
                ratingView.rating = Double(rate)
            } else {
                ratingView.rating = 0
            }
        } else {
            avatarImageView.image = Constants.noAvatarImage
            nameLabel.text = ""
            ratingView.rating = 0
        }
    }
}
