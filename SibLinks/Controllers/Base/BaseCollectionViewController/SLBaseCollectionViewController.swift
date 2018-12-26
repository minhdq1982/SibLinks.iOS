//
//  SLBaseCollectionViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/22/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import SDCAlertView

class SLBaseCollectionViewController: UICollectionViewController, StateViewController {
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configView()
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update state view equal collection view
        loadingView?.frame = (self.collectionView?.bounds)!
        emptyView?.frame = (self.collectionView?.bounds)!
        errorView?.frame = (self.collectionView?.bounds)!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SLBaseCollectionViewController {
    // MARK: - Configure view
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

extension SLBaseCollectionViewController {
    // MARK: - Empty State
    func hasContent() -> Bool {
        return true
    }
    
    func handleErrorWhenContentAvailable(error: ErrorType) {
//        Constants.showAlert(title: "Ooops", message: "Something went wrong.", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
    }
}