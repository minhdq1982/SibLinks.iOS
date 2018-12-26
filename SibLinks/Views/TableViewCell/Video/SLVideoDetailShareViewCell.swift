//
//  SLVideoDetailShareViewCell.swift
//  SibLinks
//
//  Created by Anh Nguyen on 10/7/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

protocol SLVideoDetailShareViewCellDelegate {
    func favouriteVideo(sender: LoadingButton, cell: UITableViewCell)
    func rateVideo(sender: LoadingButton, cell: UITableViewCell)
    func shareVideo(sender: AnyObject, cell: UITableViewCell)
}

class SLVideoDetailShareViewCell: SLBaseTableViewCell {
    
    @IBOutlet weak var favouriteButton: LoadingButton! {
        didSet {
            favouriteButton.imageView?.contentMode = .ScaleAspectFit
            favouriteButton.tintColor = UIColor(hexString: Constants.SIBLINKS_NAV_COLOR)
            favouriteButton.addTarget(self, action: #selector(self.favouriteVideo(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var rateButton: LoadingButton! {
        didSet {
            rateButton.imageView?.contentMode = .ScaleAspectFit
            rateButton.tintColor = UIColor(hexString: Constants.SIBLINKS_NAV_COLOR)
            rateButton.addTarget(self, action: #selector(self.rateVideo(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var shareButton: UIButton! {
        didSet {
            shareButton.imageView?.contentMode = .ScaleAspectFit
            shareButton.tintColor = UIColor(hexString: Constants.SIBLINKS_NAV_COLOR)
            shareButton.addTarget(self, action: #selector(self.shareVideo(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var favouriteLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
}

extension SLVideoDetailShareViewCell {
    
    override func awakeFromNib() {
        self.favouriteButton.loading = true
        self.rateButton.loading = true
    }
    
}

extension SLVideoDetailShareViewCell {
    
    override static func cellIdentifier() -> String {
        return "SLVideoDetailShareViewCellID"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let video = data as? SLVideo {
            if video.isFavourited == true {
                self.favouriteButton.tintColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
            } else {
                self.favouriteButton.tintColor = UIColor(hexString: Constants.SIBLINKS_NAV_COLOR)
            }
            
            if video.isRated == true {
                self.rateButton.tintColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
            } else {
                self.rateButton.tintColor = UIColor(hexString: Constants.SIBLINKS_NAV_COLOR)
            }
            
            if let numberOfFavourite = video.numberOfFavourite {
                self.favouriteLabel.text = "\(numberOfFavourite)"
            } else {
                self.favouriteLabel.text = "0"
            }
            
            if let numberOfRating = video.numberOfRatings {
                self.ratingLabel.text = "\(numberOfRating)"
            } else {
                self.ratingLabel.text = "0"
            }
            
            self.favouriteButton.loading = false
            self.rateButton.loading = false
            
            self.favouriteButton.setImage(UIImage(named: "FavouriteIcon")!, state: .Normal)
            self.rateButton.setImage(UIImage(named: "StarIcon")!, state: .Normal)
            
        } else {
            self.favouriteLabel.text = "0"
            self.favouriteButton.tintColor = UIColor(hexString: Constants.SIBLINKS_NAV_COLOR)
            self.ratingLabel.text = "0"
            self.rateButton.tintColor = UIColor(hexString: Constants.SIBLINKS_NAV_COLOR)
            
            self.favouriteButton.loading = false
            self.rateButton.loading = false
        }
    }
}

extension SLVideoDetailShareViewCell {
    
    // MARK: - Actions
    func favouriteVideo(sender: LoadingButton) {
        guard let delegate = self.delegate as? SLVideoDetailShareViewCellDelegate else {
            return
        }
        
        delegate.favouriteVideo(sender, cell: self)
    }
    
    func rateVideo(sender: LoadingButton) {
        guard let delegate = self.delegate as? SLVideoDetailShareViewCellDelegate else {
            return
        }
        
        delegate.rateVideo(sender, cell: self)
    }
    
    func shareVideo(sender: AnyObject) {
        guard let delegate = self.delegate as? SLVideoDetailShareViewCellDelegate else {
            return
        }
        
        delegate.shareVideo(sender, cell: self)
    }
    
}
