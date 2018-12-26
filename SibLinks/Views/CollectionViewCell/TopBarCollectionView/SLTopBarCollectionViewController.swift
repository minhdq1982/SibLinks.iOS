//
//  SLTopBarCollectionViewController.swift
//  SibLinks
//
//  Created by ANHTH on 9/6/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

public protocol SLTopBarCollectionViewDelegate : NSObjectProtocol {
    
    func numberOfItems() -> Int
    func titleForItemAtIndex(index: Int) -> String
    func didSelectItemAtIndex(index: Int)
    func sizeForItemAtIndex(index: Int) -> CGSize
}

class SLTopBarCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        }
    }
    
    weak var delegate: SLTopBarCollectionViewDelegate?
    var selected = 0
    var showsHorizontalScrollIndicator = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.registerNib(SLTopBarCollectionViewCell.nib(), forCellWithReuseIdentifier: TopBarCollectionViewCellIdentifier)
        
        self.collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Collection view datasource & delegate
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.delegate != nil) {
            return (self.delegate?.numberOfItems())!
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TopBarCollectionViewCellIdentifier, forIndexPath: indexPath) as! SLTopBarCollectionViewCell
        if (self.delegate != nil) {
            cell.textLbl.text = self.delegate?.titleForItemAtIndex(indexPath.row)
            if (selected == indexPath.row) {
                cell.textLbl.backgroundColor = UIColor.blueColor()
                cell.textLbl.textColor = UIColor.whiteColor()
            } else {
                cell.textLbl.backgroundColor = UIColor.whiteColor()
                cell.textLbl.textColor = UIColor.blueColor()
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selected = indexPath.row
        if (self.delegate != nil) {
            self.delegate?.didSelectItemAtIndex(indexPath.row)
        }
        collectionView.reloadData()
    }
    
    // Mark: Collection view flow layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if (self.delegate != nil) {
            return (self.delegate?.sizeForItemAtIndex(indexPath.row))!
        }
        
        return CGSizeZero
    }

}
