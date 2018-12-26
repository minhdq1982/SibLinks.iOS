//
//  SLMultipleSelectionTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 10/10/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLMultipleSelectionTableViewCell: SLBaseTableViewCell {
    
    @IBOutlet weak var multipleSelectionTitleLabel: UILabel!
    @IBOutlet weak var multipleSelectionMarkImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

extension SLMultipleSelectionTableViewCell {
    
    // MARK: - Reuse identifer
    
    override class func cellIdentifier() -> String {
        return "SLMultipleSelectionTableViewCell"
    }
    
    // MARK: - Config data
    
    override func configCellWithData(data: AnyObject?) {
        if let category = data as? SLCategory {
            if let name = category.subject {
                multipleSelectionTitleLabel.text = name
            } else {
                multipleSelectionTitleLabel.text = ""
            }
        } else {
            multipleSelectionTitleLabel.text = ""
        }
    }
}
