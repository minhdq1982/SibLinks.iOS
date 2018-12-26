//
//  SLAdmissionViewController.swift
//  SibLinks
//
//  Created by Jana on 9/30/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import PagingMenuController

class SLAdmissionViewController: SLBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let pagingMenuController = self.childViewControllers.first as? PagingMenuController {
            pagingMenuController.delegate = self
            pagingMenuController.setup(AdmissionMenuOptions())
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "College Admission".localized
        
        self.navigationBarButtonItems([(ItemType.Menu, ItemPosition.Left), (ItemType.Upload, ItemPosition.Right)])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SLAdmissionViewController {
    
    // MARK: - Actions
    
    override func uploadAction(sender: UIBarButtonItem) {
        let uploadEssayViewController = SLUploadEssayViewController.controller
        self.navigationController?.pushViewController(uploadEssayViewController, animated: true)
    }
}

extension SLAdmissionViewController: PagingMenuControllerDelegate {
    
    // MARK: - PagingMenuControllerDelegate
    
    func willMoveToPageMenuController(menuController: UIViewController, previousMenuController: UIViewController) {
        
    }
    
    func didMoveToPageMenuController(menuController: UIViewController, previousMenuController: UIViewController) {
        
    }
    
    func willMoveToMenuItemView(menuItemView: MenuItemView, previousMenuItemView: MenuItemView) {
        
    }
    
    func didMoveToMenuItemView(menuItemView: MenuItemView, previousMenuItemView: MenuItemView) {
        
    }
    
}
