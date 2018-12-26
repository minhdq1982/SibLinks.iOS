//
//  PickSubjectCell.swift
//  SibLinks
//
//  Created by Thuan on 9/17/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class PickSubjectCell: SLBaseTableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

extension PickSubjectCell {
    
    // MARK: - Reuse identifer
    
    override class func cellIdentifier() -> String {
        return "PickSubjectCell"
    }
    
    // MARK: - Config data
    
    override func configCellWithData(data: AnyObject?) {
        
    }
}
