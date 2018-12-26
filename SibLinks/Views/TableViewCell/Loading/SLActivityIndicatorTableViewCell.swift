//
//  SLActivityIndicatorTableViewCell.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/5/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLActivityIndicatorTableViewCell: SLBaseTableViewCell {
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
}

extension SLActivityIndicatorTableViewCell {
    override class func cellIdentifier() -> String {
        return "SLTableViewCellNextPage"
    }
    
    override func configCellWithData(data: AnyObject?) {
        
    }
}
