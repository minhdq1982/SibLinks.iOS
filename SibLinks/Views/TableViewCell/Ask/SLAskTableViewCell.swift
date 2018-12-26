//
//  SLAskTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 9/9/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import Kingfisher
import MGSwipeTableCell

class SLAskTableViewCell: MGSwipeTableCell {
    
    weak var controller: AnyObject?
    var indexPath: NSIndexPath?
    
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var answerImageView: UIImageView!
    @IBOutlet weak var resendButton: LoadingButton!
    
    @IBAction func resendQuestion(sender: AnyObject) {
        if let viewController = controller as? SLAskViewController {
            if let indexPath = indexPath {
                viewController.repostQuestion(indexPath, sender: resendButton)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        resendButton.setActivityIndicatorStyle(.Gray, state: .Normal)
        resendButton.setActivityIndicatorStyle(.Gray, state: .Selected)
        resendButton.setActivityIndicatorStyle(.Gray, state: .Highlighted)
    }
}

extension SLAskTableViewCell: BaseViewDatasource {
    
    static func cellIdentifier() -> String {
        return "SLAskTableViewCellID"
    }
    
    func configCellWithData(data: AnyObject?) {
        if let question = data as? SLQuestion {
            if let title = question.title {
                self.questionLabel.text = title
            } else {
                self.questionLabel.text = ""
            }
            
            if let category = question.category {
                self.categoryLabel.text = category.subject
            } else {
                self.categoryLabel.text = ""
            }
            
            if question.localId > 0 {
                self.resendButton.loading = false
                self.resendButton.hidden = false
            } else {
                self.resendButton.hidden = true
            }
            
            if (Constants.dateToTime(question.updatedAt).isEmpty) {
                self.timeLabel.text = "just now"
            } else {
                self.timeLabel.text = Constants.dateToTime(question.updatedAt)
            }
            answerImageView.image = UIImage(named: question.hasAnswer() ? "AnswerIcon" : "AskIcon")
        } else if let essay = data as? SLEssay {
            self.resendButton.hidden = true
            if let title = essay.title {
                self.questionLabel.text = title
            } else {
                self.questionLabel.text = ""
            }
            
            timeLabel.text = Constants.dateToTime(essay.updatedAt)
            
            if let type = essay.status {
                switch type {
                case EssayStatus.Reviewed.rawValue:
                    var mentorName = ""
                    if let mentor = essay.mentor {
                        mentorName = mentor.name()
                    }
                    self.answerImageView.image = UIImage(named: "AnswerIcon")
                    self.categoryLabel.text = "Answered by \(mentorName)"
                    let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: self.categoryLabel.text!);
                    attributedString.component("\(mentorName)", font: Constants.boldFontOfSize(12), color: self.categoryLabel.textColor)
                    self.categoryLabel.attributedText = attributedString;
                    
                case EssayStatus.Progress.rawValue:
                    var mentorName = ""
                    if let mentor = essay.mentor {
                        mentorName = mentor.name()
                    }
                    self.answerImageView.image = UIImage(named: "ReviewIcon")
                    self.categoryLabel.text = "Reviewing by \(mentorName)"
                    let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: self.categoryLabel.text!);
                    attributedString.component("\(mentorName)", font: Constants.boldFontOfSize(12), color: self.categoryLabel.textColor)
                    self.categoryLabel.attributedText = attributedString;
                case EssayStatus.Wait.rawValue:
                    self.answerImageView.image = UIImage(named: "WaitingIcon")
                    self.categoryLabel.text = "Waiting for review"
                default:
                    self.answerImageView.image = UIImage(named: "AskIcon")
                }
            }
        } else {
            self.questionLabel.text = ""
            self.categoryLabel.text = ""
            self.timeLabel.text = ""
            answerImageView.image = UIImage(named: "AskIcon")
            self.resendButton.hidden = true
        }
    }
}
