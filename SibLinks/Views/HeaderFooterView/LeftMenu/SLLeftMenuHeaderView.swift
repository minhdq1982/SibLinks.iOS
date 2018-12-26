//
//  SLLeftMenuHeaderView.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/14/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import IBAnimatable

class SLLeftMenuHeaderView: SLBaseTableViewHeaderFooterView {
    
    @IBOutlet weak var profileImage : AnimatableImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
}

extension SLLeftMenuHeaderView {
    override class func cellIdentifier() -> String {
        return "SLLeftMenuHeaderViewID"
    }
}
