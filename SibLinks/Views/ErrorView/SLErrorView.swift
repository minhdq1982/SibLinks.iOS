//
//  SLErrorView.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/22/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLErrorView: UIView {
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addGestureRecognizer(tapGestureRecognizer)
    }
}
