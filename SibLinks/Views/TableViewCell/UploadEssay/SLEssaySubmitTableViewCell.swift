//
//  SLEssaySubmitTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 10/18/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import IBAnimatable

protocol SLEssaySubmitTableViewCellDelegate {
    func submitAction(button: AnyObject)
}

class SLEssaySubmitTableViewCell: SLBaseTableViewCell {

    @IBOutlet weak var submitButton: LoadingButton! {
        didSet {
            submitButton.hideTextWhenLoading = false
            submitButton.activityIndicatorAlignment = .Left
            submitButton.activityIndicatorEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            submitButton.addTarget(self, action: #selector(self.submitAction(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

extension SLEssaySubmitTableViewCell {
    
    // MARK: - Reuse identifer
    
    override class func cellIdentifier() -> String {
        return "SLEssaySubmitTableViewCell"
    }
    
    // MARK: - Config data
    
    override func configCellWithData(data: AnyObject?) {
        
    }
}

extension SLEssaySubmitTableViewCell {
    
    // MARK: - Actions
    
    func submitAction(sender: AnyObject) {
        guard let delegate = self.delegate as? SLEssaySubmitTableViewCellDelegate else {
            return
        }
        
        delegate.submitAction(sender)
    }
}
