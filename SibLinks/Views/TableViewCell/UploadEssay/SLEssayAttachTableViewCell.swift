//
//  SLEssayAttachTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 10/6/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

protocol SLEssayAttachTableViewCellDelegate {
    func removeAttachFile(cell: SLEssayAttachTableViewCell)
}

class SLEssayAttachTableViewCell: SLBaseTableViewCell {

    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

extension SLEssayAttachTableViewCell {
    
    // MARK: - Reuse identifer
    
    override class func cellIdentifier() -> String {
        return "SLEssayAttachTableViewCell"
    }
    
    // MARK: - Config data
    
    override func configCellWithData(data: AnyObject?) {
        
    }
    
}

extension SLEssayAttachTableViewCell {
    
    // MARK: - Actions
    
    @IBAction func removeAttachFileAction(sender: AnyObject) {
        guard let delegate = self.delegate as? SLEssayAttachTableViewCellDelegate else {
            return
        }
        
        delegate.removeAttachFile(self)
    }
    
}
