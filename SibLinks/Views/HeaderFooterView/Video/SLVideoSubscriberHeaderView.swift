//
//  SLVideoSubscriberViewCell.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/17/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLVideoSubscriberHeaderView: SLBaseTableViewHeaderFooterView {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.backgroundColor = UIColor.whiteColor()
        }
    }
    @IBOutlet weak var moreButton: UIButton!
    
    var subscribers = [SLMentor]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.registerNib(SLVideoSubscriberCollectionViewCell.nib(), forCellWithReuseIdentifier: SLVideoSubscriberCollectionViewCell.cellIdentifier())
        moreButton.hidden = true
    }
    
    @IBAction func showMoreMentor(sender: AnyObject) {
        if let delegate = delegate as? SLVideoSubscriptionsViewController {
            delegate.showMoreMentor()
        }
    }
}

extension SLVideoSubscriberHeaderView {
    override static func cellIdentifier() -> String {
        return "SLVideoSubscriberHeaderViewID"
    }
    
    override func configCellWithData(data: AnyObject?) {
        if let mentors = data as? [SLMentor] {
            subscribers = mentors
            collectionView.reloadData()
            
            if mentors.count >= Constants.LIMIT_DEFAULT_NUMBER {
                moreButton.hidden = false
            } else {
               moreButton.hidden = true
            }
        } else {
            moreButton.hidden = true
        }
    }
    
}

extension SLVideoSubscriberHeaderView: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subscribers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SLVideoSubscriberCollectionViewCell.cellIdentifier(), forIndexPath: indexPath) as! SLVideoSubscriberCollectionViewCell
        if indexPath.row < subscribers.count {
            cell.configCellWithData(subscribers[indexPath.row])
        }
        
        return cell
    }
}

extension SLVideoSubscriberHeaderView: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let delegate = delegate as? SLVideoSubscriptionsViewController {
            if indexPath.row < subscribers.count {
                delegate.showSubscriber(subscribers[indexPath.row])
            }
        }
    }
}

extension SLVideoSubscriberHeaderView: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(60, 60)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 0, moreButton.hidden ? 10 : 50)
    }
}
