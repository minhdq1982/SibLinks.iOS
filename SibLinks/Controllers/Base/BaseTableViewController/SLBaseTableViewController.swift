//
//  SLBaseTableViewController.swift
//  SibLinks
//
//  Created by sanghv on 8/29/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import SDCAlertView

class SLBaseTableViewController: UITableViewController, StateViewController {
    /**
     Whether the table searching. Default - `NO`.
     */
    var searching = false
    var loading = false
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure view
        self.configView()
        self.setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update empty state frame equal table view
        loadingView?.frame = self.tableView.bounds
        emptyView?.frame = self.tableView.bounds
        errorView?.frame = self.tableView.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SLBaseTableViewController {
    // MARK: - Configure controller
    func configView() {
        // Set up placeholder views
        loadingView = SLLoadingView.loadFromNib()
        emptyView = SLEmptyView.loadFromNib()
        let failureView = SLErrorView.loadFromNib()
        failureView.tapGestureRecognizer.addTarget(self, action: #selector(loadObject as Void -> Void))
        errorView = failureView
    }
    
    func loadObject() {
        
    }
}

extension SLBaseTableViewController {
    // MARK: - Empty state
    func hasContent() -> Bool {
        return true
    }
    
    func handleErrorWhenContentAvailable(error: ErrorType) {
//        Constants.showAlert(title: "Ooops", message: "Something went wrong.", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
    }
}
