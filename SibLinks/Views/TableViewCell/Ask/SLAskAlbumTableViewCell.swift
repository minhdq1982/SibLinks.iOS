//
//  SLAskAlbumTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 9/27/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLAskAlbumTableViewCell: SLBaseTableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.backgroundColor = UIColor.clearColor()
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    var images: [AnyObject]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Register
        self.collectionView.registerNib(SLAskAlbumCollectionViewCell.nib(), forCellWithReuseIdentifier: SLAskAlbumCollectionViewCell.cellIdentifier())
    }
}

extension SLAskAlbumTableViewCell {
    
    override static func cellIdentifier() -> String {
        return "SLAskAlbumTableViewCellID"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let question = data as? SLQuestion {
            if question.localId > 0 {
                images = SLLocalDataManager.sharedInstance.getQuestionPhotos(question)
                self.collectionView.reloadData()
            } else {
                if let questionImages = question.questionImages {
                    images = questionImages
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

extension SLAskAlbumTableViewCell: UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(160, 92)
    }
    
}

extension SLAskAlbumTableViewCell: UICollectionViewDataSource {
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images == nil ? 0 : images!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SLAskAlbumCollectionViewCell.cellIdentifier(), forIndexPath: indexPath) as! SLAskAlbumCollectionViewCell
        if let images = images {
            if indexPath.row < images.count {
                cell.configCellWithData(images[indexPath.row])
            }
        }
        
        return cell
    }
    
}

extension SLAskAlbumTableViewCell: UICollectionViewDelegate {
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let viewController = delegate as? SLAskDetailViewController {
            viewController.presentPhotoBrowser(indexPath.row, answer: nil)
        }
    }
    
}
