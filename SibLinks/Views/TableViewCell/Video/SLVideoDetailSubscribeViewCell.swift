//
//  SLVideoDetailSubscribeViewCell.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/15/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import IBAnimatable

class SLVideoDetailSubscribeViewCell: SLBaseTableViewCell {
    
    @IBOutlet weak var avatarImageView: AnimatableImageView!
    @IBOutlet weak var mentorNameLabel: UILabel!
    @IBOutlet weak var subscriberNumberLabel: UILabel!
    @IBOutlet weak var subscribeButton: LoadingButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeButton.setActivityIndicatorAlignment(ActivityIndicatorAlignment.Center)
        avatarImageView.kf_indicatorType = .Activity
        
        subscribeButton.loading = true
    }
    
    @IBAction func subscribeVideo(sender: AnyObject) {
        if let delegate = delegate as? SLVideoDetailViewController {
            delegate.changeSubscriber(subscribeButton)
        }
    }
    
    @IBAction func showMentorProfile(sender: AnyObject) {
        if let delegate = delegate as? SLVideoDetailViewController {
            delegate.showMentorProfile()
        }
    }
}

extension SLVideoDetailSubscribeViewCell {
    
    override static func cellIdentifier() -> String {
        return "SLVideoDetailSubscribeViewCellID"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let mentor = data as? SLMentor {
            if let profileImageName = mentor.profileImageName {
                avatarImageView.kf_setImageWithURL(NSURL(string: profileImageName), placeholderImage: Constants.noAvatarImage)
            } else {
                avatarImageView.image = Constants.noAvatarImage
            }
            
            self.mentorNameLabel.text = mentor.name()
            
            var description = ""
            if let totalVideo = mentor.totalVideo {
                if totalVideo > 1 {
                    description += "\(totalVideo) videos"
                } else {
                    description += "\(totalVideo) video"
                }
            }
            
            if let subscribers = mentor.subscribers {
                if description.characters.count > 0 {
                    description += " - "
                }
                description += Constants.viewsCount.stringFromNumber((subscribers as NSNumber))! + " subscribers"
            } else {
                self.subscriberNumberLabel.text = ""
            }
            self.subscriberNumberLabel.text = description
            
            if mentor.isSubscriber == true {
                subscribeButton.tintColor = colorFromHex(Constants.SIBLINKS_UNSUBSCRIBER_COLOR)
                subscribeButton.setImage(UIImage(named: "status-subscribe")!, state: .Normal)
            } else {
                subscribeButton.tintColor = colorFromHex(Constants.SIBLINKS_SUBSCRIBER_COLOR)
                subscribeButton.setImage(UIImage(named: "status-unsubscribe")!, state: .Normal)
            }
            
            subscribeButton.loading = false
        } else {
            avatarImageView.image = nil
            mentorNameLabel.text = ""
            subscriberNumberLabel.text = ""
            subscribeButton.loading = false
        }
    }
}
