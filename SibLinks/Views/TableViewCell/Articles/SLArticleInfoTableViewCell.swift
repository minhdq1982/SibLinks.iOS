//
//  SLArticleInfoTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 10/10/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import Cosmos

class SLArticleInfoTableViewCell: SLBaseTableViewCell {

    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

extension SLArticleInfoTableViewCell {
    
    // MARK: - Reuse identifer
    override class func cellIdentifier() -> String {
        return "SLArticleInfoTableViewCell"
    }
    
    // MARK: - Config data
    override func configCellWithData(data: AnyObject?) {
        if let article = data as? SLArticle {
            articleTitleLabel.text = article.title ?? ""
            let authorName = article.mentor?.name()
            if authorName?.characters.count > 0 {
                authorLabel.text = "from \(authorName!)"
            } else {
                authorLabel.text = ""
            }
            
            if let createAt = article.createdAt {
                if authorLabel.text?.characters.count == 0 {
                    authorLabel.text = "\(Constants.dateToTime(createAt))"
                } else {
                    authorLabel.text = authorLabel.text! + " - \(Constants.dateToTime(createAt))"
                }
            }
            
            if let existAuthorName = authorName {
                let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: self.authorLabel.text!);
                attributedString.component("\(existAuthorName)", font: Constants.boldFontOfSize(12), color: self.authorLabel.textColor)
                self.authorLabel.attributedText = attributedString;
            }
            
            if let numberViews = article.numViews {
                if numberViews > 1 {
                    viewsLabel.text = "\(numberViews) views"
                } else {
                    viewsLabel.text = "\(numberViews) view"
                }
            }
            
        } else {
            articleTitleLabel.text = ""
        }
    }
}
