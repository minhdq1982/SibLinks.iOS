//
//  SLStudentSubscribedMentorsTableViewCell.swift
//  SibLinks
//
//  Created by Jana on 9/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

protocol SLStudentSubscribedMentorsTableViewCellDelegate {
    func studentSubscribedMentorsShowMore()
}

class SLStudentSubscribedMentorsTableViewCell: SLBaseTableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.backgroundColor = UIColor.clearColor()
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    @IBOutlet weak var moreButton: UIButton!
    
    var mentors: [SLMentor]?
    private let emptyView = SLMentorOfUserEmptyView.loadFromNib()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Add tap gesture on view
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openTopMentor as Void -> Void))
        emptyView.addGestureRecognizer(tapGestureRecognizer)
        // Register
        self.collectionView.registerNib(SLSubscribedMentorsCollectionViewCell.nib(), forCellWithReuseIdentifier: SLSubscribedMentorsCollectionViewCell.cellIdentifier())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateEmptyView()
    }
    
    func updateEmptyView() {
        emptyView.frame = collectionView.bounds
    }
    
    func addEmptyView() {
        if mentors?.count == 0 {
            // Show mentor empty view
            self.collectionView.addSubview(emptyView)
        } else {
            // Remove view
            emptyView.removeFromSuperview()
        }
    }
    
    func openTopMentor() {
        if let viewController = delegate as? SLStudentProfileViewController {
            viewController.openTopMentor()
        }
    }
    
}

extension SLStudentSubscribedMentorsTableViewCell: UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewFlowLayout
}

extension SLStudentSubscribedMentorsTableViewCell: UICollectionViewDataSource {
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let mentors = mentors {
            return mentors.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SLSubscribedMentorsCollectionViewCell.cellIdentifier(), forIndexPath: indexPath)
        
        if let mentorCell = cell as? SLSubscribedMentorsCollectionViewCell {
            if let mentors = self.mentors {
                if indexPath.row < mentors.count {
                    let mentor = mentors[indexPath.row]
                    mentorCell.configCellWithData(mentor)
                }
            }
            
            return mentorCell
        }
        
        return UICollectionViewCell()
    }
    
}

extension SLStudentSubscribedMentorsTableViewCell: UICollectionViewDelegate {
    
    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < mentors?.count {
            if let mentor = mentors?[indexPath.row], let viewController = delegate as? SLStudentProfileViewController {
                viewController.showMentorProfile(mentor)
            }
        }
    }
}

extension SLStudentSubscribedMentorsTableViewCell {
    
    // MARK: - Configure
    
    override static func cellIdentifier() -> String {
        return "SLStudentSubscribedMentorsTableViewCell"
    }
    
    override func configCellWithData(data: AnyObject?) {
        
    }
    
}

extension SLStudentSubscribedMentorsTableViewCell {
    
    // MARK: - Actions
    
    @IBAction func moreAction(sender: AnyObject) {
        guard let delegate = self.delegate as? SLStudentSubscribedMentorsTableViewCellDelegate else {
            return
        }
        
        delegate.studentSubscribedMentorsShowMore()
    }
    
}
