//
//  ExpandableTableViewCell.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/15/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit

class ExpandableTableViewCell: SLBaseTableViewCell {
    
    private lazy var headerLabel : UILabel = self.createHeaderLabel()
    private func createHeaderLabel() -> UILabel {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 3
        lbl.textColor = UIColor.blackColor()
        lbl.font = Constants.boldFontOfSize(15)
        return lbl
    }
    private lazy var descriptionLabel : UILabel = self.createDescriptionLabel()
    private func createDescriptionLabel() -> UILabel {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        lbl.textColor = UIColor.darkGrayColor()
        lbl.font = Constants.regularFontOfSize(13)
        return lbl
    }
    
    private lazy var topSpacerView : UIView = self.createTopSpacerView()
    private func createTopSpacerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private lazy var spacerView : UIView = self.createSpacerView()
    private func createSpacerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private lazy var bottomSpacerView : UIView = self.createBottomSpacerView()
    private func createBottomSpacerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    lazy var disclosureView : DisclosureIndicator = self.createDisclosureView()
    private func createDisclosureView() -> DisclosureIndicator {
        let view = DisclosureIndicator(direction: ArrowDirection.Bottom)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        self.contentView.addSubview(self.topSpacerView)
        self.contentView.addSubview(self.headerLabel)
        self.contentView.addSubview(self.disclosureView)
        self.contentView.addSubview(self.spacerView)
        self.contentView.addSubview(self.descriptionLabel)
        self.contentView.addSubview(self.bottomSpacerView)
        self.setLayoutConstraints()
    }
    
    private func setLayoutConstraints() {
        let views = ["qn":self.headerLabel,"ans":self.descriptionLabel,"view":self.spacerView,"top":self.topSpacerView,"btm":self.bottomSpacerView,"btn":self.disclosureView]
        let metrics = ["padding": 8]
        let paddingMetrics = ["padding": 5]
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(padding)-[qn]-(padding)-[btn(==32)]-(padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(padding)-[ans]-(padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[top]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[btm]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[top(==padding)][qn][view(==padding)][ans][btm(==padding)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: paddingMetrics, views: views))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.disclosureView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 32))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.disclosureView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.headerLabel, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
    }
    
    func setCellContent(item : AnyObject?, isExpanded : Bool) {
        if let video = item as? SLVideo {
            self.headerLabel.text = video.title
            self.descriptionLabel.text = isExpanded ? video.descriptionVideo : ""
            self.disclosureView.direction = isExpanded ? ArrowDirection.Top : ArrowDirection.Bottom
            if (video.descriptionVideo == nil || (video.descriptionVideo?.isEmpty)!) {
                self.disclosureView.hidden = true
            } else {
                self.disclosureView.hidden = false
            }
            self.disclosureView.setNeedsDisplay()
        } else {
            self.headerLabel.text = ""
            self.descriptionLabel.text = ""
            self.disclosureView.direction = ArrowDirection.Bottom
            self.disclosureView.setNeedsDisplay()
        }
    }
    
    func cellContentHeight() -> CGFloat {
        return self.headerLabel.intrinsicContentSize().height + self.descriptionLabel.intrinsicContentSize().height + 35.0
    }
}

extension ExpandableTableViewCell {
    override static func cellIdentifier() -> String {
        return "ExpandableTableViewCellID"
    }
}
