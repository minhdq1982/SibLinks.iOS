//
//  SLEssayStatusTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 10/6/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import IBAnimatable
import Kingfisher

enum ColorStatus {
    case Waiting
    case Reviewing
    case Answerred
    
    var color: UIColor {
        switch self {
        case .Waiting:
            return colorFromHex("#FF5959")
        case .Reviewing:
            return colorFromHex("#3E97D1")
        case .Answerred:
//            return colorFromHex("#F3C303")
            return colorFromHex("#22589b")
        }
    }
}

class SLEssayStatusTableViewCell: SLBaseTableViewCell {

    @IBOutlet weak var statusBackground: UIView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var avatarImageView: AnimatableImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

extension SLEssayStatusTableViewCell {
    
    // MARK: - Reuse identifer
    
    override class func cellIdentifier() -> String {
        return "SLEssayStatusTableViewCell"
    }
    
    // MARK: - Config data
    
    override func configCellWithData(data: AnyObject?) {
        if let essay = data as? SLEssay {
            if let status = essay.status {
                switch status {
                case EssayStatus.Wait.rawValue:
                    self.statusBackground.backgroundColor = ColorStatus.Waiting.color
                    self.statusImageView.image = UIImage(named: "status-waiting")
                    self.statusLabel.text = "Waiting"
                    avatarImageView.hidden = true
                case EssayStatus.Progress.rawValue:
                    self.statusBackground.backgroundColor = ColorStatus.Reviewing.color
                    self.statusImageView.image = UIImage(named: "status-reviewing")
                    var statusString = "Reviewing"
                    if let mentor = essay.mentor {
                        statusString = "Reviewing by \(mentor.name())"
                        avatarImageView.hidden = false
                        avatarImageView.kf_setImageWithURL(NSURL(string: mentor.profileImageName ?? ""), placeholderImage: Constants.noAvatarImage)
                    }
                    self.statusLabel.text = statusString
                case EssayStatus.Reviewed.rawValue:
                    self.statusBackground.backgroundColor = ColorStatus.Answerred.color
                    self.statusImageView.image = UIImage(named: "status-answerred")
                    var statusString = "Answered"
                    if let mentor = essay.mentor {
                        statusString = "Answered by \(mentor.name())"
                    }
                    self.statusLabel.text = statusString
                    avatarImageView.hidden = true
                default:
                    break
                }
            }
        }
    }
    
}
