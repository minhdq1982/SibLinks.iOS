//
//  SLVideoInfoViewCell.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import Cosmos

class SLVideoInfoViewCell: SLBaseTableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
}

extension SLVideoInfoViewCell {
    
    override static func cellIdentifier() -> String {
        return "SLVideoInfoViewCellID"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let video = data as? SLVideo {
            let time = Constants.dateToTime(video.updatedAt)
            if time.characters.count > 0 {
                if let numberViews = video.numberOfViews {
                    infoLabel.text = "\(time) - \(numberViews) views"
                } else {
                    infoLabel.text = time
                }
            } else {
                if let numberViews = video.numberOfViews {
                    infoLabel.text = "\(numberViews) views"
                } else {
                    infoLabel.text = ""
                }
            }
            
            if let rating = video.rating {
                ratingView.rating = Double(rating)
            } else {
                ratingView.rating = 0
            }
        } else {
            infoLabel.text = ""
            ratingView.rating = 0
        }
    }
}
