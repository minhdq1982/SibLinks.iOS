//
//  SLBaseCollectionViewCell.swift
//  SibLinks
//
//  Created by sanghv on 8/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLBaseCollectionViewCell: UICollectionViewCell {

    weak var delegate: AnyObject?
    var indexPath: NSIndexPath?

    deinit {

    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.configView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.configView()
    }

    func configView() {

    }

    func setIndexPath(indexPath: NSIndexPath?, sender: AnyObject?) {
        self.indexPath = indexPath
        self.delegate = sender
    }
}

extension SLBaseCollectionViewCell: BaseViewDatasource {
    class func cellIdentifier() -> String {
        return "CollectionViewCellIdentifier"
    }
    
    func configCellWithData(data: AnyObject?) {
        
    }
}