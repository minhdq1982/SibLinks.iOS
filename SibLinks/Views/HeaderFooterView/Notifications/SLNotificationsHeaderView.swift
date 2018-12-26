//
//  SLNotificationsHeaderView.swift
//  SibLinks
//
//  Created by Jana on 9/30/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLNotificationsHeaderView: SLBaseTableViewHeaderFooterView {

    @IBOutlet weak var timeLabel: UILabel!

}

extension SLNotificationsHeaderView {
    
    override class func cellIdentifier() -> String {
        return "SLNotificationsHeaderView"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let time = data as? NSDate {
            if isSame(NSDate(), secondDate: time) {
                timeLabel.text = "Today"
            } else {
                timeLabel.text = time.monthFormatterString()
            }
        }
    }
}

extension SLNotificationsHeaderView {
    
    // MARK: - Compare
    
    func isSame(firstDate: NSDate, secondDate: NSDate) -> Bool {
        let firstDateString = NSDateFormatter.localizedStringFromDate(firstDate, dateStyle: .MediumStyle, timeStyle: .NoStyle)
        let secondDateString = NSDateFormatter.localizedStringFromDate(secondDate, dateStyle: .MediumStyle, timeStyle: .NoStyle)
        return (firstDateString == secondDateString)
    }
}
