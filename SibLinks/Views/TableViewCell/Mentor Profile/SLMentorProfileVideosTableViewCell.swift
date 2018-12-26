//
//  SLMentorProfileVideosTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 9/29/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

@objc protocol MentorTutorialViewDelegate: NSObjectProtocol {
    optional func showVideo(video: SLVideo)
    optional func showArticle(article: SLArticle)
    optional func showMore(indexPath: NSIndexPath?)
}

class SLMentorProfileVideosTableViewCell: SLBaseTableViewCell {

    weak var mentorDelegate: MentorTutorialViewDelegate?
    private let emptyView = SLMentorOfUserEmptyView.loadFromNib()
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.backgroundColor = UIColor.clearColor()
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    @IBOutlet weak var moreButton: UIButton!
    
    var videos: [SLVideo]?
    var articles: [SLArticle]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Register
        self.collectionView.registerNib(SLMentorsVideoCollectionViewCell.nib(), forCellWithReuseIdentifier: SLMentorsVideoCollectionViewCell.cellIdentifier())
    }
    
    func updateEmptyView() {
        emptyView.frame = collectionView.bounds
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension SLMentorProfileVideosTableViewCell: UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(135, 165)
    }
    
}

extension SLMentorProfileVideosTableViewCell: UICollectionViewDataSource {
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let indexPath = indexPath {
            switch indexPath.row {
            case TutorialType.Video.rawValue:
                return videos?.count ?? 0
            case TutorialType.Article.rawValue:
                return articles?.count ?? 0
            default:
                return 0
            }
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SLMentorsVideoCollectionViewCell.cellIdentifier(), forIndexPath: indexPath)
        
        if let videoCell = cell as? SLMentorsVideoCollectionViewCell {
            if let tableViewIndexPath = self.indexPath {
                switch tableViewIndexPath.row {
                case TutorialType.Video.rawValue:
                    if let videos = self.videos {
                        if indexPath.row < videos.count {
                            let video = videos[indexPath.row]
                            videoCell.configCellWithData(video)
                        }
                    }
                case TutorialType.Article.rawValue:
                    if let articles = self.articles {
                        if indexPath.row < articles.count {
                            let article = articles[indexPath.row]
                            videoCell.configCellWithData(article)
                        }
                    }
                default:
                    break
                }
            }
            
            return videoCell
        }
        
        return UICollectionViewCell()
    }
    
}

extension SLMentorProfileVideosTableViewCell: UICollectionViewDelegate {
    
    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let tableViewIndexPath = self.indexPath {
            switch tableViewIndexPath.row {
            case TutorialType.Video.rawValue:
                if let videos = self.videos {
                    if indexPath.row < videos.count {
                        let video = videos[indexPath.row]
                        if let mentorDelegate = mentorDelegate {
                            if mentorDelegate.respondsToSelector(#selector(mentorDelegate.showVideo(_:))) {
                                mentorDelegate.showVideo!(video)
                            }
                        }
                    }
                }
            case TutorialType.Article.rawValue:
                if let articles = self.articles {
                    if indexPath.row < articles.count {
                        let article = articles[indexPath.row]
                        if let mentorDelegate = mentorDelegate {
                            if mentorDelegate.respondsToSelector(#selector(mentorDelegate.showArticle(_:))) {
                                mentorDelegate.showArticle!(article)
                            }
                        }
                    }
                }
            default:
                break
            }
        }
    }
}

extension SLMentorProfileVideosTableViewCell {
    
    override static func cellIdentifier() -> String {
        return "SLMentorProfileVideosTableViewCellID"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let videos = data as? [SLVideo] {
            self.videos = videos
            self.collectionView.reloadData()
        } else if let articles = data as? [SLArticle] {
            self.articles = articles
            self.collectionView.reloadData()
        }
    }
}

extension SLMentorProfileVideosTableViewCell {
    
    // MARK: - Actions
    
    @IBAction func moreAction(sender: AnyObject) {
        guard let delegate = self.delegate as? MentorTutorialViewDelegate else {
            return
        }
        
        delegate.showMore!(indexPath)
    }
    
}
