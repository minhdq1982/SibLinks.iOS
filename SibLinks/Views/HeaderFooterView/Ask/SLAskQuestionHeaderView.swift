//
//  SLAskQuestionHeaderView.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import GSKStretchyHeaderView
import IBAnimatable

class SLAskQuestionHeaderView: GSKStretchyHeaderView {
    
    @IBOutlet weak var timeLabelButton: UIButton!
    @IBOutlet weak var answerTextLabel: UILabel!
    @IBOutlet weak var answerValueLabel: UILabel!
    @IBOutlet weak var viewTextLabel: UILabel!
    @IBOutlet weak var viewValueLabel: UILabel!
    @IBOutlet weak var avatarImageView: AnimatableImageView!
    @IBOutlet weak var avatarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.kf_indicatorType = .Activity
    }
    
    override func didChangeStretchFactor(stretchFactor: CGFloat) {
        var alpha: CGFloat = 1
        if stretchFactor > 1 {
            alpha = CGFloatTranslateRange(stretchFactor, 1, 1.12, 1, 1)
        } else {
            alpha = CGFloatTranslateRange(stretchFactor, 0.2, 0.8, 0, 1)
        }
        
        topView.alpha = alpha
        
        let limitedStretchFactor = min(1, stretchFactor);
        avatarWidthConstraint.constant = CGSizeInterpolate(limitedStretchFactor, CGSizeMake(50, 50), CGSizeMake(75, 75)).width
    }
    
    func updateDataFrom(data: AnyObject?) {
        if let question = data as? SLQuestion {
            if (Constants.dateToTime(question.updatedAt).isEmpty) {
                self.timeLabelButton.setTitle("Pending", forState: .Normal)
            } else {
                self.timeLabelButton.setTitle(Constants.dateToTime(question.updatedAt), forState: .Normal)
            }
            
            if let numberOfReplies = question.numberOfReplies {
                if numberOfReplies > 1 {
                    answerTextLabel.text = "answers"
                } else {
                    answerTextLabel.text = "answer"
                }
                answerValueLabel.text = "\(numberOfReplies)"
            } else {
                answerValueLabel.text = "0"
                answerTextLabel.text = "answer"
            }
            
            if let numberOfViews = question.numberOfViews {
                if numberOfViews > 1 {
                    viewTextLabel.text = "views"
                } else {
                    viewTextLabel.text = "view"
                }
                viewValueLabel.text = "\(numberOfViews)"
            } else {
                viewValueLabel.text = "0"
                viewTextLabel.text = "view"
            }
            
            if let imagePath = question.student?.imageUrl {
                avatarImageView.kf_setImageWithURL(NSURL(string: imagePath), placeholderImage: Constants.noAvatarImage)
            } else {
                avatarImageView.image = Constants.noAvatarImage
            }
        } else {
            timeLabelButton.setTitle("", forState: .Normal)
            viewValueLabel.text = "0"
            answerValueLabel.text = "0"
            avatarImageView.image = Constants.noAvatarImage
        }
    }
}
