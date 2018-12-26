//
//  SLLeftMenuTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 9/6/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLLeftMenuTableViewCell: SLBaseTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
}

extension SLLeftMenuTableViewCell {
    override class func cellIdentifier() -> String {
        return "SLLeftMenuTableViewCellID"
    }
}