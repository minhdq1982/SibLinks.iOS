//
//  SLShareVideoTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 10/11/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLShareVideoTableViewCell: SLBaseTableViewCell {
    
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var shareTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

extension SLShareVideoTableViewCell {
    
    // MARK: - Reuse identifer
    
    override class func cellIdentifier() -> String {
        return "SLShareVideoTableViewCell"
    }
    
    // MARK: - Config data
    
    override func configCellWithData(data: AnyObject?) {
        
    }
}
