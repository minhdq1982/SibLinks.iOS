//
//  SLBaseTableViewCell.swift
//  SibLinks
//
//  Created by sanghv on 8/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

protocol BaseViewDatasource {
    static func cellIdentifier() -> String
    func configCellWithData(data: AnyObject?)
}

class SLBaseTableViewCell: UITableViewCell{

    weak var delegate: AnyObject?
    var indexPath: NSIndexPath?
    
    deinit {

    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configView() {

    }

    func setIndexPath(indexPath: NSIndexPath?, sender: AnyObject?) {
        self.indexPath = indexPath
        self.delegate = sender
    }
}

extension SLBaseTableViewCell: BaseViewDatasource {
    
    // MARK: - Reuse identifer
    
    class func cellIdentifier() -> String {
        return "CellIdentifier"
    }
    
    // MARK: - Config data
    
    func configCellWithData(data: AnyObject?) {
        
    }
}
