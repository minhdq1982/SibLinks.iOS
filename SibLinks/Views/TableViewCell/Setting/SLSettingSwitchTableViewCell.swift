//
//  SLSettingSwitchTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 9/22/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLSettingSwitchTableViewCell: SLBaseTableViewCell {
    
    @IBOutlet weak var settingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}

extension SLSettingSwitchTableViewCell {
    
    // MARK: - Reuse identifer
    
    override class func cellIdentifier() -> String {
        return "SLSettingSwitchTableViewCell"
    }
    
    // MARK: - Config data
    
    override func configCellWithData(data: AnyObject?) {
        
    }
    
}
