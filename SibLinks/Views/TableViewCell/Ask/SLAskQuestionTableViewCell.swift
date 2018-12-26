//
//  SLAskQuestionTableViewCell.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/16/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLAskQuestionTableViewCell: SLBaseTableViewCell {
    
    @IBOutlet weak var questionLabel: UILabel!
    
}

extension SLAskQuestionTableViewCell {
    
    override static func cellIdentifier() -> String {
        return "SLAskQuestionTableViewCellID"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let question = data as? SLQuestion {
            if let title = question.title {
                questionLabel.text = title
            } else {
                questionLabel.text = ""
            }
        } else {
            questionLabel.text = ""
        }
    }
}