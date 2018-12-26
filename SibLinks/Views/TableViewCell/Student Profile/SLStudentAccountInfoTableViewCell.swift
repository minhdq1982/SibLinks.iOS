//
//  SLStudentAccountInfoTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 9/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLStudentAccountInfoTableViewCell: SLBaseTableViewCell {
    
    @IBOutlet weak var questionsNumberLabel: UILabel!
    @IBOutlet weak var essayNumberLabel: UILabel!
    @IBOutlet weak var subscribedNumberLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

extension SLStudentAccountInfoTableViewCell {
    
    // MARK: - Configure
    
    override static func cellIdentifier() -> String {
        return "SLStudentAccountInfoTableViewCell"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let user = data as? SLUser {
            if let numberOfQuestions = user.numberOfQuestion {
                questionsNumberLabel.text = "\(numberOfQuestions)"
            } else {
                questionsNumberLabel.text = "0"
            }
            
            if let numberOfEssay = user.numberOfEssay {
                essayNumberLabel.text = "\(numberOfEssay)"
            } else {
                essayNumberLabel.text = "0"
            }
            
            if let numberOfSubscriber = user.numberOfSubscriber {
                subscribedNumberLabel.text = "\(numberOfSubscriber)"
            } else {
                subscribedNumberLabel.text = "0"
            }
        } else {
            questionsNumberLabel.text = "0"
            essayNumberLabel.text = "0"
            subscribedNumberLabel.text = "0"
        }
    }
    
}
