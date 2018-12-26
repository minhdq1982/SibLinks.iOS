//
//  SLTopMentorsTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 9/8/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import Cosmos
import IBAnimatable

class SLTopMentorsTableViewCell: SLBaseTableViewCell {
    
    @IBOutlet weak var avatarImageView: AnimatableImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var ratingTotalLabel: UILabel!
    @IBOutlet weak var subscriberButton: LoadingButton!
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    
    weak var mentor: SLMentor?

    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.kf_indicatorType = .Activity
        subscriberButton.setActivityIndicatorStyle(.Gray, state: .Normal)
    }
}

extension SLTopMentorsTableViewCell {
    
    override static func cellIdentifier() -> String {
        return "SLTopMentorsTableViewCellID"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let mentor = data as? SLMentor {
            self.mentor = mentor
            if let profileImageName = mentor.profileImageName {
                avatarImageView.kf_setImageWithURL(NSURL(string: profileImageName), placeholderImage: Constants.noAvatarImage)
            } else {
                avatarImageView.image = nil
            }
            
            nameLabel.text = mentor.name()
            
            if let school = mentor.school {
                schoolLabel.text = school
            } else {
                schoolLabel.text = ""
            }
            
            if let categories = mentor.categories {
                var categoriesString = [String]()
                for category in categories {
                    if let categoryName = category.subject {
                        categoriesString.append(categoryName)
                    }
                }
                
                let categoryName = categoriesString.joinWithSeparator(", ")
                categoriesLabel.text = categoryName
            } else {
                categoriesLabel.text = ""
            }
            
            if let numberRate = mentor.numberRate {
                ratingTotalLabel.text = "(\(numberRate))"
            } else {
                ratingTotalLabel.text = ""
            }
            
            if let rate = mentor.averageRate {
                ratingView.rating = Double(rate)
            } else {
                ratingView.rating = 0
            }
            
            if mentor.isSubscriber == true {
                self.subscriberButton.tintColor = colorFromHex(Constants.SIBLINKS_UNSUBSCRIBER_COLOR)
                self.subscriberButton.setImage(UIImage(named: "status-subscribe")!, state: .Normal)
            } else {
                self.subscriberButton.tintColor = colorFromHex(Constants.SIBLINKS_SUBSCRIBER_COLOR)
                self.subscriberButton.setImage(UIImage(named: "status-unsubscribe")!, state: .Normal)
            }
        } else {
            avatarImageView.image = nil
            nameLabel.text = ""
            schoolLabel.text = ""
            categoriesLabel.text = ""
            ratingView.rating = 0
        }
    }
    
}

extension SLTopMentorsTableViewCell {
    
    // MARK: - Actions
    
    @IBAction func subscriberAction(sender: AnyObject) {
        if let mentor = self.mentor {
            if let mentorId = mentor.objectId {
                self.subscriberButton.loading = true
                SLUserViewModel.sharedInstance.changeSubscriber(mentorId, success: {
                    self.subscriberButton.loading = false
                    if let isSubscriber = mentor.isSubscriber {
                        mentor.isSubscriber = !isSubscriber
                    }
                    
                    if mentor.isSubscriber == true {
                        self.subscriberButton.tintColor = colorFromHex(Constants.SIBLINKS_UNSUBSCRIBER_COLOR)
                        self.subscriberButton.setImage(UIImage(named: "status-subscribe")!, state: .Normal)
                    } else {
                        self.subscriberButton.tintColor = colorFromHex(Constants.SIBLINKS_SUBSCRIBER_COLOR)
                        self.subscriberButton.setImage(UIImage(named: "status-unsubscribe")!, state: .Normal)
                    }
                    
                    }, failure: { (error) in
                        self.subscriberButton.loading = false
                        if mentor.isSubscriber == true {
                            self.subscriberButton.tintColor = colorFromHex(Constants.SIBLINKS_UNSUBSCRIBER_COLOR)
                            self.subscriberButton.setImage(UIImage(named: "status-subscribe")!, state: .Normal)
                        } else {
                            self.subscriberButton.tintColor = colorFromHex(Constants.SIBLINKS_SUBSCRIBER_COLOR)
                            self.subscriberButton.setImage(UIImage(named: "status-unsubscribe")!, state: .Normal)
                        }
                    }, networkFailure: { (error) in
                        self.subscriberButton.loading = false
                        if mentor.isSubscriber == true {
                            self.subscriberButton.tintColor = colorFromHex(Constants.SIBLINKS_SUBSCRIBER_COLOR)
                            self.subscriberButton.setImage(UIImage(named: "status-subscribe")!, state: .Normal)
                        } else {
                            self.subscriberButton.tintColor = colorFromHex(Constants.SIBLINKS_UNSUBSCRIBER_COLOR)
                            self.subscriberButton.setImage(UIImage(named: "status-unsubscribe")!, state: .Normal)
                        }
                })
            }
        }
    }
    
}
