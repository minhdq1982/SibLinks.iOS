//
//  SLMentorsViewController.swift
//  SibLinks
//
//  Created by ANHTH on 9/6/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import PagingMenuController

class SLMentorsViewController: SLBaseViewController {
    
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
            pagingMenuController.setup(MentorMenuOptions())
        }
        
        self.title = "Mentors".localized
        self.navigationBarButtonItems([(ItemType.Menu, ItemPosition.Left), (ItemType.Filter, ItemPosition.Right), (ItemType.Search, ItemPosition.Right)])
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

}

extension SLMentorsViewController {
    
    // MARK: - Configure
    
    override func configView() {
        super.configView()
    }
    
}

extension SLMentorsViewController {
    
    // MARK: - Actions
    override func filter(sender: UIBarButtonItem) {
        self.filterActionSheet = JLActionSheet(delegate: self, dataSource: self)
        self.filterActionSheet?.tableView.registerNib(SLMultipleSelectionTableViewCell.nib(), forCellReuseIdentifier: SLMultipleSelectionTableViewCell.cellIdentifier())
        self.filterActionSheet?.show()
    }
    
}

extension SLMentorsViewController {
    
    // MARK: - Search
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
                
                let mentorViewController = SLSearchMentorViewController.controller
                mentorViewController.searchText = searchText
                mentorViewController.category = categories[selectedRow]
                self.navigationController?.pushViewController(mentorViewController, animated: true)
            }
        }
    }
    
    override func search(sender: UIBarButtonItem) {
        self.navigationBarButtonItems(nil)
        super.search(sender)
    }
    
    override func searchDidEndEditing() {
        self.navigationBarButtonItems([(ItemType.Menu, ItemPosition.Left), (ItemType.Filter, ItemPosition.Right), (ItemType.Search, ItemPosition.Right)])
    }
}

extension SLMentorsViewController: JLActionSheetDataSource {
    
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

extension SLMentorsViewController: JLActionSheetDelegate {
    
    // MARK: - JLActionSheetDelegate
    
    func JLActionSheetDelegateTableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedRow = indexPath.row
        self.filterActionSheet?.tableView.reloadData()
        self.filterActionSheet?.dismiss()
        
        self.filterSubject(categories[indexPath.row])
    }
    
    func filterSubject(category: SLCategory) {
        if let pagingMenuController = self.childViewControllers.first as? PagingMenuController {
            if let viewControllers = pagingMenuController.pagingViewController?.controllers {
                for viewController in viewControllers {
                    if let mentorViewController = viewController as? SLTopMentorsViewController {
                        switch self.selectedRow {
                        case 0:
                            self.title = "Mentors"
                        default:
                            self.title = category.subject
                        }
                        
                        mentorViewController.category = category
                        mentorViewController.loadObjects()
                    }
                }
            }
        }
    }
}

extension SLMentorsViewController: PagingMenuControllerDelegate {
    
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
