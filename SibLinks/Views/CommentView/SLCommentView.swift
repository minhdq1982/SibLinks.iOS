//
//  SLCommentView.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/3/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLCommentView: UIView {

    weak var delegate: AnyObject?
    @IBOutlet weak var commentTextView: SLPlaceholderTextView!
    @IBOutlet weak var sendButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commentTextView.placeholderFont = Constants.regularFontOfSize(14)
        commentTextView.delegate = self
    }
    
    @IBAction func sendComment(sender: AnyObject) {
        let commentString = commentTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if commentString.characters.count == 0 {
            Constants.showAlertWithOnlyOKAction(message: "Please enter comment!")
        } else {
            if let viewController = delegate as? SLVideoCommentViewController {
                viewController.addComment(commentString, sender: commentTextView)
            }
        }
    }
}

extension SLCommentView: UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        let text = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if text.characters.count == 0 {
            sendButton.hidden = true
        } else {
            sendButton.hidden = false
        }
    }
}
