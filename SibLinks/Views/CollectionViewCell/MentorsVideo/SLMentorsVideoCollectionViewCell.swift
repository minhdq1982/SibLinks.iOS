//
//  SLMentorsVideoCollectionViewCell.swift
//  SibLinks
//
//  Created by Jana on 9/30/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import IBAnimatable

class SLMentorsVideoCollectionViewCell: SLBaseCollectionViewCell {

    @IBOutlet weak var videoImage: AnimatableImageView!
    @IBOutlet weak var videoDurationView: AnimatableView!
    @IBOutlet weak var videoDurationLabel: UILabel!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoAuthor: UILabel!
    @IBOutlet weak var videoDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        videoImage.kf_indicatorType = .Activity
    }
}

extension SLMentorsVideoCollectionViewCell {
    
    override class func cellIdentifier() -> String {
        return "SLMentorsVideoCollectionViewCell"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let video = data as? SLVideo {
            if let thumbnailImageName = video.thumbnailImageName {
                videoImage.kf_setImageWithURL(NSURL(string: thumbnailImageName))
            } else {
                videoImage.image = nil
            }
            
            if let title = video.title {
                videoTitle.text = title
            } else {
                videoTitle.text = ""
            }
            
            if let duration = video.duration {
                videoDurationView.hidden = false
                videoDurationLabel.text = duration
            } else {
                videoDurationView.hidden = true
                videoDurationLabel.text = ""
            }
            
            let videoUpdatedAt = Constants.dateToTime(video.updatedAt)
            if let viewNumbers = video.numberOfViews {
                var viewString = " view"
                if viewNumbers > 1 {
                    viewString = " views"
                }
                
                if videoUpdatedAt.characters.count > 0 {
                    videoDescription.text = videoUpdatedAt + " - " + Constants.viewsCount.stringFromNumber((viewNumbers as NSNumber))! + viewString
                } else {
                    videoDescription.text = Constants.viewsCount.stringFromNumber((viewNumbers as NSNumber))! + viewString
                }
            } else {
                videoDescription.text = videoUpdatedAt
            }
            
            if let mentor = video.mentor {
                videoAuthor.text = mentor.name()
            } else {
                videoAuthor.text = ""
            }
        } else if let article = data as? SLArticle {
            if let thumbnailImageName = article.image {
                videoImage.kf_setImageWithURL(NSURL(string: thumbnailImageName))
            } else {
                videoImage.image = nil
            }
            
            if let title = article.title {
                videoTitle.text = title
            } else {
                videoTitle.text = ""
            }
            
            let videoUpdatedAt = Constants.dateToTime(article.updatedAt)
            if let numberView = article.numViews {
                var viewString = " view"
                if numberView > 1 {
                    viewString = " views"
                }
                
                if videoUpdatedAt.characters.count > 0 {
                    videoDescription.text = videoUpdatedAt + " - " + Constants.viewsCount.stringFromNumber((numberView as NSNumber))! + viewString
                } else {
                    videoDescription.text = Constants.viewsCount.stringFromNumber((numberView as NSNumber))! + viewString
                }
            } else {
                videoDescription.text = videoUpdatedAt
            }
            
            if let mentor = article.mentor {
                videoAuthor.text = mentor.name()
            } else {
                videoAuthor.text = ""
            }
        } else {
            videoImage.image = nil
            videoTitle.text = ""
            videoDescription.text = ""
            videoAuthor.text = ""
        }
    }
}
