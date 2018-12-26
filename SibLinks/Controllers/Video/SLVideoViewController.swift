//
//  SLVideoViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/12/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import PagingMenuController

class SLVideoViewController: SLBaseViewController {
    
    lazy var categories: [SLCategory] = self.createCategories()
    private func createCategories() -> [SLCategory] {
        var categories = [SLCategory]()
        categories = Constants.appDelegate().categories
        
        let all = SLCategory()
        all.objectId = -1
        all.subject = "All"
        categories.insert(all, atIndex: 0)
        
        return categories
    }
    
    var filterActionSheet: JLActionSheet?
    var selectedRow: NSInteger = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up paging menu controller
        if let pagingMenuController = self.childViewControllers.first as? PagingMenuController {
            pagingMenuController.delegate = self
            pagingMenuController.setup(VideoMenuOptions())
        }
        
        self.title = "Videos".localized
        self.navigationBarButtonItems([(ItemType.Menu, ItemPosition.Left), (ItemType.Filter, ItemPosition.Right), (ItemType.Search, ItemPosition.Right)])
        
        VideoRouter(endpoint: VideoEndpoint.GetVideoSubjects()).request { (result) in
            switch result {
            case .Success(let objects):
                if let subjects = objects as? [SLCategory] {
                    self.categories = subjects
                    
                    let all = SLCategory()
                    all.objectId = -1
                    all.subject = "All"
                    self.categories.insert(all, atIndex: 0)
                }
                break
            default:
                break
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let searchBar = self.navigationItem.titleView as? UISearchBar {
            searchBar.resignFirstResponder()
            self.searchBarCancelButtonClicked(searchBar)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action
    override func searchObject(clear: Bool) {
        if !clear {
            if let searchBar = self.navigationItem.titleView as? UISearchBar {
                var searchText = ""
                if let searchBarText = searchBar.text {
                    searchText = searchBarText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    if searchText.characters.count == 0 {
                        return
                    } else {
                        super.searchObject(clear)
                        searchBar.resignFirstResponder()
                        enableCancleButton(searchBar)
                    }
                }
                
                let searchViewController = SLSearchViewController.controller
                searchViewController.searchText = searchText
                searchViewController.category = self.categories[selectedRow]
                self.navigationController?.pushViewController(searchViewController, animated: true)
            }
        }
    }
    
    // MARK: - Actions
    override func filter(sender: UIBarButtonItem) {
        self.filterActionSheet = JLActionSheet(delegate: self, dataSource: self)
        self.filterActionSheet?.tableView.registerNib(SLMultipleSelectionTableViewCell.nib(), forCellReuseIdentifier: SLMultipleSelectionTableViewCell.cellIdentifier())
        self.filterActionSheet?.show()
    }
}

extension SLVideoViewController {
    
    // MARK: - Search
    
    override func search(sender: UIBarButtonItem) {
        self.navigationBarButtonItems(nil)
        super.search(sender)
    }
    
    override func searchDidEndEditing() {
        self.navigationBarButtonItems([(ItemType.Menu, ItemPosition.Left), (ItemType.Filter, ItemPosition.Right), (ItemType.Search, ItemPosition.Right)])
    }
    
}

extension SLVideoViewController: JLActionSheetDataSource {
    
    // MARK: - JLActionSheetDataSource
    
    func JLActionSheetDataSourceTableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count ?? 0
    }
    
    func JLActionSheetDataSourceTableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLMultipleSelectionTableViewCell.cellIdentifier())
        
        if let filterCell = cell as? SLMultipleSelectionTableViewCell {
            filterCell.multipleSelectionTitleLabel.text = self.categories[indexPath.row].subject
            
            if indexPath.row == self.selectedRow {
                filterCell.multipleSelectionMarkImageView.hidden = false
            } else {
                filterCell.multipleSelectionMarkImageView.hidden = true
            }
            
            return filterCell
        }
        
        return UITableViewCell()
    }
    
    func JLActionSheetDataSourceTableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func JLActionSheetDataSourceHeightOfContentView() -> CGFloat {
        if self.categories.count < 4 {
            return (50 * CGFloat(self.categories.count ?? 0))
        }
        
        return 200
    }
    
}

extension SLVideoViewController: JLActionSheetDelegate {
    
    // MARK: - JLActionSheetDelegate
    
    func JLActionSheetDelegateTableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedRow = indexPath.row
        self.filterActionSheet?.tableView.reloadData()
        self.filterActionSheet?.dismiss()
        
        self.filterVideo(categories[self.selectedRow])
    }
    
    func filterVideo(category: SLCategory) {
        if let pagingMenuController = self.childViewControllers.first as? PagingMenuController {
            if let viewControllers = pagingMenuController.pagingViewController?.controllers {
                switch self.selectedRow {
                case 0:
                    self.title = "Videos"
                default:
                    self.title = category.subject
                }
                
                for viewController in viewControllers {
                    if let videoViewController = viewController as? SLVideoListViewController {
                        videoViewController.category = category
                        videoViewController.loadObjects()
                    }
                }
            }
        }
    }
    
}

extension SLVideoViewController: PagingMenuControllerDelegate {
    
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
