//
//  SLVideoSuggestedViewCell.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/15/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import Kingfisher
import IBAnimatable
import MGSwipeTableCell

class SLVideoSuggestedViewCell: MGSwipeTableCell {
    
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var viewNumbersLabel: UILabel!
    @IBOutlet weak var timeLabel: AnimatableLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        videoImageView.kf_indicatorType = .Activity
    }
}

extension SLVideoSuggestedViewCell: BaseViewDatasource {
    static func cellIdentifier() -> String {
        return "SLVideoSuggestedViewCellID"
    }
    
    func configCellWithData(data: AnyObject?) {
        if let video = data as? SLVideo {
            if let thumbnailImageName = video.thumbnailImageName {
                videoImageView.kf_setImageWithURL(NSURL(string: thumbnailImageName))
            } else {
                videoImageView.image = nil
            }
            
            if let title = video.title {
                videoTitleLabel.text = title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            } else {
                videoTitleLabel.text = ""
            }
            
            let videoUpdatedAt = Constants.dateToTime(video.updatedAt)
            if let viewNumbers = video.numberOfViews {
                if videoUpdatedAt.characters.count > 0 {
                    viewNumbersLabel.text = videoUpdatedAt + " - " + Constants.viewsCount.stringFromNumber((viewNumbers as NSNumber))! + " views"
                } else {
                    viewNumbersLabel.text = Constants.viewsCount.stringFromNumber((viewNumbers as NSNumber))! + " views"
                }
            } else {
                viewNumbersLabel.text = videoUpdatedAt
            }
            
            if let mentor = video.mentor {
                accountLabel.text = mentor.name()
            } else {
                accountLabel.text = ""
            }
            
            if let duration = video.duration {
                timeLabel.text = duration
            } else {
                timeLabel.text = "0:00"
            }
        } else if let article = data as? SLArticle {
            if let thumbnailImageName = article.image {
                videoImageView.kf_setImageWithURL(NSURL(string: thumbnailImageName))
            } else {
                videoImageView.image = nil
            }
            
            if let title = article.title {
                videoTitleLabel.text = title
            } else {
                videoTitleLabel.text = ""
            }
            
            let videoUpdatedAt = Constants.dateToTime(article.updatedAt)
            if let numberComment = article.numComments {
                var commentString = " comment"
                if numberComment > 1 {
                    commentString = " comments"
                }
                
                if videoUpdatedAt.characters.count > 0 {
                    viewNumbersLabel.text = videoUpdatedAt + " - " + Constants.viewsCount.stringFromNumber((numberComment as NSNumber))! + commentString
                } else {
                    viewNumbersLabel.text = Constants.viewsCount.stringFromNumber((numberComment as NSNumber))! + commentString
                }
            } else {
                viewNumbersLabel.text = videoUpdatedAt
            }
            
            if let mentor = article.mentor {
                accountLabel.text = mentor.name()
            } else {
                accountLabel.text = ""
            }
            
            timeLabel.hidden = true
        } else {
            videoImageView.image = nil
            videoTitleLabel.text = ""
            viewNumbersLabel.text = ""
            accountLabel.text = ""
            timeLabel.text = ""
        }
    }
}
