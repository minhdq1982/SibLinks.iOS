//
//  SLVideoCommentHeaderView.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/3/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLVideoCommentHeaderView: SLBaseTableViewHeaderFooterView {
    
    @IBOutlet weak var editTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    let commentView = SLCommentView.loadFromNib()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commentView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 60)
        editTextField.inputAccessoryView = commentView
    }
    
    @IBAction func addcomment(sender: AnyObject) {
        if !commentView.commentTextView.isFirstResponder() {
            commentView.commentTextView.text = ""
            commentView.commentTextView.placeholder = "Add your comment..."
            commentView.delegate = delegate
            editTextField.becomeFirstResponder()
            commentView.commentTextView.becomeFirstResponder()
            
            NSNotificationCenter.defaultCenter().postNotificationName("did.comment", object: nil)
        }
    }
}

extension SLVideoCommentHeaderView {
    override static func cellIdentifier() -> String {
        return "SLVideoCommentHeaderViewID"
    }
}
