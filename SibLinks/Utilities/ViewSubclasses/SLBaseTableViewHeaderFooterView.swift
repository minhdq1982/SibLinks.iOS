//
//  SLBaseTableViewHeaderFooterView.swift
//  SibLinks
//
//  Created by sanghv on 8/28/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class SLBaseTableViewHeaderFooterView: UITableViewHeaderFooterView {

    weak var delegate: AnyObject?
    var section: Int?

    deinit {

    }

    // MARK: - Override init func

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

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

    func setSection(section: Int?, sender: AnyObject?) {
        self.section = section
        self.delegate = sender
    }
}

extension SLBaseTableViewHeaderFooterView: BaseViewDatasource {
    class func cellIdentifier() -> String {
        return "HeaderFooterIdentifier"
    }
    
    func configCellWithData(data: AnyObject?) {
        
    }
}