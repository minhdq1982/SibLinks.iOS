//
//  SLEssayAddFileTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 10/6/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

protocol SLEssayAddFileTableViewCellDelegate {
    func addAttachFileAction()
}

class SLEssayAddFileTableViewCell: SLBaseTableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

extension SLEssayAddFileTableViewCell {
    
    // MARK: - Reuse identifer
    
    override class func cellIdentifier() -> String {
        return "SLEssayAddFileTableViewCell"
    }
    
    // MARK: - Config data
    
    override func configCellWithData(data: AnyObject?) {
        
    }
}

extension SLEssayAddFileTableViewCell {
    
    // MARK: - Actions
    
    @IBAction func addAttachFileAction(sender: AnyObject) {
        guard let delegate = self.delegate as? SLEssayAddFileTableViewCellDelegate else {
            return
        }
        
        delegate.addAttachFileAction()
    }
    
}
