//
//  SLLoadingView.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/5/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import IBAnimatable

class SLLoadingView: UIView {
    @IBOutlet weak var activityIndicator: AnimatableActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.color = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
        activityIndicator.startAnimating()
    }
}
