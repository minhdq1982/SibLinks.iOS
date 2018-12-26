//
//  NotificationNavigationView.swift
//  SibLinks
//
//  Created by Jana on 12/1/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import IBAnimatable

class NotificationNavigationView: UIView {

    @IBOutlet weak var valueView: AnimatableView!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setValue(value: NSInteger) {
        if value >= 1 {
            valueView.hidden = false
            valueLabel.text = "\(value)"
        } else {
            valueView.hidden = true
            valueLabel.text = "0"
        }
    }

}
