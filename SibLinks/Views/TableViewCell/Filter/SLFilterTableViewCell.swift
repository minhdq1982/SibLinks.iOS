//
//  SLFilterTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 10/3/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLFilterTableViewCell: SLBaseTableViewCell {

    @IBOutlet weak var filterTitleLabel: UILabel!
    @IBOutlet weak var checkmarkIcon: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

extension SLFilterTableViewCell {
    
    // MARK: - Reuse identifer
    
    override class func cellIdentifier() -> String {
        return "SLFilterTableViewCellID"
    }
    
    // MARK: - Config data
    
    override func configCellWithData(data: AnyObject?) {
        
    }
}
