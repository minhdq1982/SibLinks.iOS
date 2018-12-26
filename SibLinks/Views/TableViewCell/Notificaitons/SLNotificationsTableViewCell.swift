//
//  SLNotificationsTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 9/22/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import IBAnimatable

class SLNotificationsTableViewCell: SLBaseTableViewCell {
    
    @IBOutlet weak var avatarImageView: AnimatableImageView!
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var notificationTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var notificationStatusView: AnimatableView!
}

extension SLNotificationsTableViewCell {
    
    override class func cellIdentifier() -> String {
        return "SLNotificationsTableViewCell"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let notification = data as? SLNotification {
            switch notification.type {
            case .Answer:
                let fullNotification = "\(notification.name()) has answered on your question"
                notificationTitleLabel.text = fullNotification
                notificationTitleLabel.attributedText = self.addBoldText(fullNotification, boldPartOfString: notification.name(), font: Constants.regularFontOfSize(14), boldFont: Constants.boldFontOfSize(14))
                
            case .Essay:
                let fullNotification = "\(notification.name()) has commented on your essay"
                notificationTitleLabel.text = fullNotification
                notificationTitleLabel.attributedText = self.addBoldText(fullNotification, boldPartOfString: notification.name(), font: Constants.regularFontOfSize(14), boldFont: Constants.boldFontOfSize(14))
                
            case .CommentVideo:
                let fullNotification = "\(notification.name()) has commented on your video"
                notificationTitleLabel.text = fullNotification
                notificationTitleLabel.attributedText = self.addBoldText(fullNotification, boldPartOfString: notification.name(), font: Constants.regularFontOfSize(14), boldFont: Constants.boldFontOfSize(14))
                
            default:
                print("Unknown")
            }
            
            if let imageUrlString = notification.imageUrl {
                let imageUrl = NSURL(string: imageUrlString)
                avatarImageView.kf_setImageWithURL(imageUrl)
            }
            
            if let time = notification.createdAt {
                timeLabel.text = Constants.dateToTime(time)
            }
            
            if let isReaded = notification.status {
                if isReaded {
                    notificationStatusView.hidden = true
                } else {
                    notificationStatusView.hidden = false
                }
            } else {
                notificationStatusView.hidden = false
            }
        }
    }
    
    func addBoldText(fullString: NSString, boldPartOfString: NSString, font: UIFont!, boldFont: UIFont!) -> NSAttributedString {
        let nonBoldFontAttribute = [NSFontAttributeName:font!]
        let boldFontAttribute = [NSFontAttributeName:boldFont!]
        let boldString = NSMutableAttributedString(string: fullString as String, attributes:nonBoldFontAttribute)
        boldString.addAttributes(boldFontAttribute, range: fullString.rangeOfString(boldPartOfString as String))
        return boldString
    }
    
}
