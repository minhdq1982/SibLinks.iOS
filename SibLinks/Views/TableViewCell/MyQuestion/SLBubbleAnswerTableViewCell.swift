//
//  SLBubbleAnswerTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 9/27/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import IBAnimatable
import SKPhotoBrowser

class SLBubbleAnswerTableViewCell: SLBaseTableViewCell {

    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var avatarImageView: AnimatableImageView!
    @IBOutlet weak var likeButton: LoadingButton! {
        didSet {
            likeButton.imageView?.contentMode = .ScaleAspectFit
            likeButton.tintColor = UIColor(hexString: Constants.SIBLINKS_UNLIKE_COLOR)
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.backgroundColor = UIColor.clearColor()
        }
    }
    
    @IBOutlet weak var bottomCollectionViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightCollectionViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthCollectionViewConstraint: NSLayoutConstraint!
    
    var bottomCollectionViewOriginalConstraint: CGFloat = 0
    var heightCollectionViewOriginalConstraint: CGFloat = 0
    var widthCollectionViewOriginalConstraint: CGFloat = 0
    
    var images: [String]?
    var answer: SLAnswer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Register
        self.collectionView.registerNib(SLAskAlbumCollectionViewCell.nib(), forCellWithReuseIdentifier: SLAskAlbumCollectionViewCell.cellIdentifier())
        
        self.bottomCollectionViewOriginalConstraint = self.bottomCollectionViewConstraint.constant
        self.heightCollectionViewOriginalConstraint = self.heightCollectionViewConstraint.constant
        self.widthCollectionViewOriginalConstraint = self.widthCollectionViewConstraint.constant
        avatarImageView.kf_indicatorType = .Activity
        
        likeButton.setActivityIndicatorStyle(.Gray, state: .Normal)
        likeButton.setActivityIndicatorStyle(.Gray, state: .Selected)
        likeButton.setActivityIndicatorStyle(.Gray, state: .Highlighted)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Actions
    @IBAction func likeAnswer(sender: AnyObject) {
        if likeButton.loading {
            return
        }
        
        if let viewController = delegate as? SLAskDetailViewController, let indexPath = indexPath {
            viewController.likeAnswer(likeButton, atIndexPath: indexPath)
        }
    }
    
    @IBAction func showMentorProfile(sender: AnyObject) {
        if let viewController = delegate as? SLAskDetailViewController, let indexPath = indexPath {
            viewController.showMentorProfile(indexPath)
        }
    }
}

extension SLBubbleAnswerTableViewCell {
    
    // MARK: - Configure
    
    override static func cellIdentifier() -> String {
        return "SLBubbleAnswerTableViewCellID"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let answer = data as? SLAnswer {
            self.answer = answer
            
            if let text = answer.answer {
                self.answerLabel.text = text
            } else {
                self.answerLabel.text = ""
            }
            
            if let images = answer.answerImages where images.count > 0 {
                self.images = images
                
                self.bottomCollectionViewConstraint.constant = self.bottomCollectionViewOriginalConstraint
                self.heightCollectionViewConstraint.constant = self.heightCollectionViewOriginalConstraint
                self.widthCollectionViewConstraint.constant = 20 + 160 * CGFloat(images.count) + 10 * CGFloat(images.count - 1)
                
                self.collectionView.reloadData()
            } else {
                self.images = nil
                
                self.bottomCollectionViewConstraint.constant = 0
                self.heightCollectionViewConstraint.constant = 0
                self.widthCollectionViewConstraint.constant = 0
            }
            
            if let mentor = answer.mentor {
                if let profileImageName = mentor.profileImageName {
                    self.avatarImageView.kf_setImageWithURL(NSURL(string: profileImageName), placeholderImage: Constants.noAvatarImage)
                } else {
                    self.avatarImageView.image = nil
                }
                
                let mentorName = mentor.name()
                let updatedAt = Constants.dateToTime(answer.updatedAt)
                if mentorName.characters.count > 0 {
                    if updatedAt.characters.count > 0 {
                        self.footerLabel.text = "\(mentorName) - \(updatedAt)"
                    } else {
                        self.footerLabel.text = "\(mentorName)"
                    }
                } else {
                    self.footerLabel.text = ""
                }
            } else {
                self.avatarImageView.image = nil
                self.footerLabel.text = ""
            }
            
            likeButton.tintColor = answer.like ? UIColor(hexString: Constants.SIBLINKS_LIKE_COLOR) : UIColor(hexString: Constants.SIBLINKS_UNLIKE_COLOR)
        } else if let essay = data as? SLEssay {
            likeButton.hidden = true
            self.images = nil
            
            self.bottomCollectionViewConstraint.constant = 0
            self.heightCollectionViewConstraint.constant = 0
            self.widthCollectionViewConstraint.constant = 0
            
            if let text = essay.comment {
                self.answerLabel.text = text
            } else {
                self.answerLabel.text = ""
            }
            
            if let mentor = essay.mentor {
                if let profileImageName = mentor.profileImageName {
                    self.avatarImageView.kf_setImageWithURL(NSURL(string: profileImageName), placeholderImage: Constants.noAvatarImage)
                } else {
                    self.avatarImageView.image = nil
                }
                
                let mentorName = mentor.name()
                let updatedAt = Constants.dateToTime(essay.reviewedAt)
                if mentorName.characters.count > 0 {
                    if updatedAt.characters.count > 0 {
                        self.footerLabel.text = "\(mentorName) - \(updatedAt)"
                    } else {
                        self.footerLabel.text = "\(mentorName)"
                    }
                } else {
                    self.footerLabel.text = ""
                }
            } else {
                self.avatarImageView.image = nil
                self.footerLabel.text = ""
            }
        } else {
            self.images = nil
            self.avatarImageView.image = nil
            self.answerLabel.text = ""
            self.footerLabel.text = ""
            likeButton.tintColor = UIColor(hexString: Constants.SIBLINKS_UNLIKE_COLOR)
        }
    }
    
}

extension SLBubbleAnswerTableViewCell: UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(160, 92)
    }
    
}

extension SLBubbleAnswerTableViewCell: UICollectionViewDataSource {
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images == nil ? 0 : images!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SLAskAlbumCollectionViewCell.cellIdentifier(), forIndexPath: indexPath) as! SLAskAlbumCollectionViewCell
        
        if let images = images {
            cell.configCellWithData(images[indexPath.row])
        }
        
        return cell
    }
    
}

extension SLBubbleAnswerTableViewCell: UICollectionViewDelegate {
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let viewController = delegate as? SLAskDetailViewController, let answer = answer {
            viewController.presentPhotoBrowser(indexPath.row, answer: answer)
        }
    }
}
