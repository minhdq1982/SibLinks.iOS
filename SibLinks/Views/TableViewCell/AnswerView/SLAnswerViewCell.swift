//
//  SLAnswerViewCell.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/8/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLAnswerViewCell: SLBaseTableViewCell {
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var numberLikeLabel: UILabel!
    @IBOutlet weak var likeAnswerButton: UIButton!
}

extension SLAnswerViewCell {
    
    override static func cellIdentifier() -> String {
        return "SLAnswerViewCellID"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let answer = data as? SLAnswer {
            if let title = answer.answer {
                self.answerLabel.text = title
            } else {
                self.answerLabel.text = ""
            }
            
            timeLabel.text = Constants.dateToTime(answer.updatedAt)
            if let numberOfLike = answer.numberOfLike {
                if numberOfLike > 0 {
                    numberLikeLabel.text = "\(numberOfLike)"
                    likeAnswerButton.tintColor = UIColor(hexString: Constants.SIBLINKS_LIKE_COLOR)
                } else {
                    numberLikeLabel.text = ""
                    likeAnswerButton.tintColor = UIColor(hexString: Constants.SIBLINKS_UNLIKE_COLOR)
                }
            } else {
                numberLikeLabel.text = ""
                likeAnswerButton.tintColor = UIColor(hexString: Constants.SIBLINKS_UNLIKE_COLOR)
            }
        } else {
            self.answerLabel.text = ""
            self.timeLabel.text = ""
            numberLikeLabel.text = ""
            likeAnswerButton.tintColor = UIColor(hexString: Constants.SIBLINKS_UNLIKE_COLOR)
        }
    }
}
