//
//  SLAskAlbumCollectionViewCell.swift
//  SibLinks
//
//  Created by Jana on 9/27/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftHEXColors
import IBAnimatable

class SLAskAlbumCollectionViewCell: SLBaseCollectionViewCell {
    
    @IBOutlet weak var questionImageView: UIImageView! {
        didSet {
            questionImageView.layer.masksToBounds = true
            questionImageView.layer.cornerRadius = 5
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.questionImageView.kf_indicatorType = .Activity
    }
    
}

extension SLAskAlbumCollectionViewCell {
    
    override static func cellIdentifier() -> String {
        return "SLAskAlbumCollectionViewCellID"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let imagePath = data as? String {
            self.questionImageView.kf_setImageWithURL(NSURL(string: imagePath))
        } else if let image = data as? UIImage {
            self.questionImageView.image = image
        }
    }
    
}
