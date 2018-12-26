//
//  JLActionSheet.swift
//  JLActionSheet
//
//  Created by Jana on 9/8/16.
//  Copyright © 2016 Jana. All rights reserved.
//

import UIKit

@objc protocol JLActionSheetDataSource: NSObjectProtocol {
    optional func JLActionSheetDataSourceNumberOfSectionsInTableView(tableView: UITableView) -> Int
    func JLActionSheetDataSourceTableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    func JLActionSheetDataSourceTableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    func JLActionSheetDataSourceTableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    func JLActionSheetDataSourceHeightOfContentView() -> CGFloat
}

protocol JLActionSheetDelegate {
    func JLActionSheetDelegateTableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
}

class JLActionSheet: UIView {
    
    private weak var delegate: AnyObject?
    private weak var dataSource: AnyObject?
    
    lazy var tableView: UITableView = self.createTableView()
    private func createTableView() -> UITableView {
        let tableView = UITableView()
        self.contentView.addSubview(tableView)
        
        tableView.bounces = false
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView
    }
    
    private lazy var contentView: UIView = self.createContentView()
    private func createContentView() -> UIView {
        let contentView = UIView()
        self.addSubview(contentView)
        
        return contentView
    }
    
    private lazy var heightOfContentView: CGFloat = self.createHeightOfContentView()
    private func createHeightOfContentView() -> CGFloat {
        let heightOfContentView = (self.dataSource as? JLActionSheetDataSource)?.JLActionSheetDataSourceHeightOfContentView()
        return heightOfContentView ?? 0
    }
    
    private lazy var tapToHide: UITapGestureRecognizer = self.createTapToHide()
    private func createTapToHide() -> UITapGestureRecognizer {
        let tapToHide = UITapGestureRecognizer(target: self, action: #selector(JLActionSheet.dismiss))
        tapToHide.delegate = self
        return tapToHide
    }
    
    init(delegate: AnyObject?, dataSource: AnyObject?) {
        super.init(frame: UIScreen.mainScreen().bounds)
        
        self.delegate = delegate
        self.dataSource = dataSource
        
        self.addGestureRecognizer(self.tapToHide)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension JLActionSheet: UIGestureRecognizerDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        let touchPoint = touch.locationInView(self.tableView)
        return !(self.tableView.hitTest(touchPoint, withEvent: nil) != nil)
    }
}

extension JLActionSheet {
    
    // MARK: - Layout Subviews
    
    override func layoutSubviews() {
        self.frame = UIScreen.mainScreen().bounds
        
        self.contentView.frame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.size.height - self.heightOfContentView, width: UIScreen.mainScreen().bounds.size.width, height: self.heightOfContentView)
        self.tableView.frame = self.contentView.bounds
    }
}

extension JLActionSheet: UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let dataSource = self.dataSource as? JLActionSheetDataSource else {
            return 1
        }
        
        guard dataSource.respondsToSelector(#selector(dataSource.JLActionSheetDataSourceNumberOfSectionsInTableView(_:))) else {
            return 1
        }
        
        return dataSource.JLActionSheetDataSourceNumberOfSectionsInTableView!(tableView)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataSource = self.dataSource as? JLActionSheetDataSource else {
            return 0
        }
        
        return dataSource.JLActionSheetDataSourceTableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let dataSource = self.dataSource as? JLActionSheetDataSource else {
            return UITableViewCell()
        }
        
        return dataSource.JLActionSheetDataSourceTableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let dataSource = self.dataSource as? JLActionSheetDataSource else {
            return 0
        }
        
        return dataSource.JLActionSheetDataSourceTableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
}

extension JLActionSheet: UITableViewDelegate {
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let delegate = self.delegate as? JLActionSheetDelegate else {
            return
        }
        
        delegate.JLActionSheetDelegateTableView(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
}

extension JLActionSheet {
    
    // MARK: - Public methods
    
    func showInView(view: UIView) {
        view.addSubview(self)
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.backgroundColor = UIColor(white: 0, alpha: 0.5)
            self.contentView.transform = CGAffineTransformMakeTranslation(0, -self.heightOfContentView)
            }, completion: { (finished: Bool) in
                
        })
    }
    
    func show() {
        if let window = (UIApplication.sharedApplication().delegate as! AppDelegate).window {
            self.showInView(window)
        }
    }
    
    func dismiss() {
        UIView.animateWithDuration(0.3, animations: {
            self.backgroundColor = UIColor(white: 0, alpha: 0)
            self.contentView.frame = CGRect(x: 0, y: UIScreen.mainScreen().bounds.size.height, width: UIScreen.mainScreen().bounds.size.width, height: self.heightOfContentView)
        }) { (finished: Bool) in
            self.removeFromSuperview()
        }
    }
    
}
