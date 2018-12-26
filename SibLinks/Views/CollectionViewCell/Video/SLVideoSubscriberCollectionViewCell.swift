//
//  SLVideoSubscriberCollectionViewCell.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/17/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import IBAnimatable

class SLVideoSubscriberCollectionViewCell: SLBaseCollectionViewCell {

    @IBOutlet weak var avatarImageView: AnimatableImageView!
    @IBOutlet weak var mentorNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.kf_indicatorType = .Activity
    }
}

extension SLVideoSubscriberCollectionViewCell {
    override class func cellIdentifier() -> String {
        return "SLVideoSubscriberCollectionViewCellID"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let mentor = data as? SLMentor {
            if let profileImageName = mentor.profileImageName {
                avatarImageView.kf_setImageWithURL(NSURL(string: profileImageName), placeholderImage: Constants.noAvatarImage)
            } else {
                avatarImageView.image = nil
            }
            
            mentorNameLabel.text = mentor.name()
        } else {
            avatarImageView.image = nil
            mentorNameLabel.text = ""
        }
    }
}
