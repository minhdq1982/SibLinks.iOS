//
//  SLMentorProfileDetailTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 9/16/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import Cosmos

class SLMentorProfileDetailTableViewCell: SLBaseTableViewCell {
    
    @IBOutlet weak var subscriberButton: LoadingButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var numberSubscriber: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var ratingCountLabel: UILabel!
    @IBOutlet weak var favouriteSubjectLabel: UILabel!
    @IBOutlet weak var subscriberView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func changeSubscriber(sender: LoadingButton) {
        if let delegate = delegate as? SLMentorProfileViewController {
            delegate.changeSubscriber(sender)
        }
    }
}

extension SLMentorProfileDetailTableViewCell {
    
    override static func cellIdentifier() -> String {
        return "SLMentorProfileDetailTableViewCellID"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let mentor = data as? SLMentor {
            nameLabel.text = mentor.name()
            
            if let school = mentor.school {
                schoolLabel.text = school
            } else {
                schoolLabel.text = ""
            }
            
            if let subscribers = mentor.subscribers {
                numberSubscriber.text = "\(subscribers)"
            } else {
                numberSubscriber.text = ""
            }
            
            if let rate = mentor.averageRate {
                ratingView.rating = Double(rate)
            } else {
                ratingView.rating = 0
            }
            
            if let rateNumber = mentor.numberRate {
                ratingCountLabel.text = "(\(rateNumber))"
            } else {
                ratingCountLabel.text = "(0)"
            }
            
            subscriberButton.tintColor = UIColor.whiteColor()
            subscriberButton.setTitle((mentor.isSubscriber == true ? " Subscribed".localized : "  Subscribe".localized), forState: .Normal)
            subscriberButton.setImage((mentor.isSubscriber == true ? UIImage(named: "UnsubscriberIcon")! : UIImage(named: "SubscriberIcon")!), state: .Normal)
            subscriberView.backgroundColor = (mentor.isSubscriber == true) ? UIColor(hexString: Constants.SIBLINKS_UNSUBSCRIBER_COLOR) : UIColor(hexString: Constants.SIBLINKS_SUBSCRIBER_COLOR)
            
            if let categories = mentor.categories {
                var categoriesString = [String]()
                for category in categories {
                    if let categoryName = category.subject {
                        categoriesString.append(categoryName)
                    }
                }
                
                let categoryName = categoriesString.joinWithSeparator(", ")
                favouriteSubjectLabel.text = categoryName
            } else {
                favouriteSubjectLabel.text = ""
            }
        } else {
            nameLabel.text = ""
            schoolLabel.text = ""
            numberSubscriber.text = ""
            ratingView.rating = 0
            subscriberButton.setTitle("  Subscribe".localized, forState: .Normal)
            subscriberButton.setImage(UIImage(named: "SubscriberIcon")!, state: .Normal)
            subscriberView.backgroundColor = UIColor(hexString: Constants.SIBLINKS_SUBSCRIBER_COLOR)
        }
    }
}
