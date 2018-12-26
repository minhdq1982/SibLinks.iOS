//
//  SLMentorProfileInfoTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 9/29/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLMentorProfileInfoTableViewCell: SLBaseTableViewCell {

    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var videosLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension SLMentorProfileInfoTableViewCell {
    
    override static func cellIdentifier() -> String {
        return "SLMentorProfileInfoTableViewCellID"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let mentor = data as? SLMentor {
            if let numberLike = mentor.numberLike {
                likesLabel.text = "\(numberLike)"
            } else {
                likesLabel.text = "0"
            }
            
            if let numberAnswer = mentor.numberAnswer {
                answersLabel.text = "\(numberAnswer)"
            } else {
                answersLabel.text = "0"
            }
            
            if let numberVideo = mentor.numberVideo {
                videosLabel.text = "\(numberVideo)"
            } else {
                videosLabel.text = "0"
            }
        } else {
            likesLabel.text = "0"
            answersLabel.text = "0"
            videosLabel.text = "0"
        }
    }
    
}
