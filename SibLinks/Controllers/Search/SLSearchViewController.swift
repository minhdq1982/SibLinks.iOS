//
//  SLSearchViewController.swift
//  SibLinks
//
//  Created by Jana on 10/4/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import PagingMenuController

class SLSearchViewController: UIViewController {
    
    static let searchViewControllerID = "SLSearchViewController"
    
    static var controller: SLSearchViewController! {
        let controller = UIStoryboard(name: "SearchScreen", bundle: nil).instantiateViewControllerWithIdentifier(SLSearchViewController.searchViewControllerID) as! SLSearchViewController
        return controller
    }
    
    var searchText: String?
    var category: SLCategory?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let pagingMenuController = pagingMenuController() {
            pagingMenuController.delegate = self
            pagingMenuController.setup(SearchMenuOptions())
        }
        
        loadObjects()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "Search".localized
        self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left)])
        self.createSearch()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SLSearchViewController {
    
    // MARK: - Actions
    
    func createSearch() {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.searchBarStyle = .Minimal
        self.navigationItem.titleView = searchBar
        searchBar.text = self.searchText ?? ""
    }
    
    override func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchText = searchBar.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        loadObjects()
    }
}

extension SLSearchViewController: PagingMenuControllerDelegate {
    
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

extension SLSearchViewController {
    
    func pagingMenuController() -> PagingMenuController? {
        if let pagingMenuController = self.childViewControllers.first as? PagingMenuController {
            return pagingMenuController
        }
        
        return nil
    }
    
    func getAllChildControllerOfPaging() -> [UIViewController]? {
        if let pagingMenuController = pagingMenuController() {
            if let viewControllers = pagingMenuController.pagingViewController?.controllers {
                return viewControllers
            }
        }
        
        return nil
    }
    
    func loadObjects() {
        if let viewControllers = getAllChildControllerOfPaging() {
            for viewController in viewControllers {
                if let searchViewController = viewController as? SLSearchVideoViewController {
                    searchViewController.searchText = searchText
                    searchViewController.category = category
                    searchViewController.loadObjects()
                } else if let searchViewController = viewController as? SLSearchMentorViewController {
                    searchViewController.searchVideo = true
                    searchViewController.searchText = searchText
                    searchViewController.category = category
                    searchViewController.loadObjects()
                } else if let searchViewController = viewController as? SLSearchPlaylistViewController {
                    searchViewController.searchText = searchText
                    searchViewController.category = category
                    searchViewController.loadObjects()
                }
            }
        }
    }
}
