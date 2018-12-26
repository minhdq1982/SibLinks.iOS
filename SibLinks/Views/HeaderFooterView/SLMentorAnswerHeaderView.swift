//
//  SLMentorAnswerHeaderView.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/8/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

protocol SLMentorAnswerHeaderViewDelegate {
    func mentorAnswerShowMore()
}

class SLMentorAnswerHeaderView: SLBaseTableViewHeaderFooterView {
    
    @IBOutlet weak var moreButton: UIButton!
}

extension SLMentorAnswerHeaderView {
    
    override class func cellIdentifier() -> String {
        return "SLMentorAnswerHeaderViewID"
    }
    
}

extension SLMentorAnswerHeaderView {
    
    // MARK: - Actions
    
    @IBAction func moreAction(sender: AnyObject) {
        guard let delegate = self.delegate as? SLMentorAnswerHeaderViewDelegate else {
            return
        }
        
        delegate.mentorAnswerShowMore()
    }
    
}
