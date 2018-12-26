//
//  SLQueryTableViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/5/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import SDCAlertView

private let cellIdentifier = "QueryTableViewCell"

@IBDesignable class SLQueryTableViewController: SLBaseTableViewController {
    /**
     Whether the table has error that show error view. Default - `YES`.
     */
    @IBInspectable var errorViewEnabled = true
    /**
     Whether the table has empty data that show empty view. Default - `YES`.
     */
    @IBInspectable var emptyViewEnabled = true
    /**
     Whether the table should use the default loading view. Default - `YES`.
     */
    @IBInspectable var loadingViewEnabled = true
    /**
     Whether the table should use the built-in pull-to-refresh feature. Default - `YES`.
     */
    @IBInspectable var pullToRefreshEnabled = true
    /**
     Whether the table should use the built-in pagination feature. Default - `YES`.
     */
    @IBInspectable var paginationEnabled = true
    /**
     The number of objects to show per page. Default - `10`.
     */
    @IBInspectable var objectsPerPage = Constants.LIMIT_DEFAULT_NUMBER
    /**
     Whether the table is actively loading new data from the server.
     */
//    var loading = false
    /**
     List objects
     */
    private lazy var mutableObjects = [DataModel]()
    /**
     Whether we have loaded the first set of objects
     */
    private var firstLoad = true
    /**
     The last page that was loaded
    */
    private var currentPage = 0
    /**
     The count of objects from the last load.
     Set to -1 when objects haven't loaded, or there was an error.
     */
    var lastLoadCount = -1
    
    /**
     Save table view cell separator style to paging animation
     */
    private var savedSeparatorStyle: UITableViewCellSeparatorStyle?
    
    override func loadView() {
        super.loadView()
        // Register loading cell
        tableView.registerNib(SLActivityIndicatorTableViewCell.nib(), forCellReuseIdentifier: SLActivityIndicatorTableViewCell.cellIdentifier())
        // Setup the Pull to Refresh UI if needed
        if pullToRefreshEnabled {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(SLQueryTableViewController.refreshControlValueChanged(_:)), forControlEvents: .ValueChanged)
            self.refreshControl = refreshControl
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadObjects()
    }
    
    // MARK: - Data
    func objectsWillLoad() {
        // Called when starting loading object
        if firstLoad {
            savedSeparatorStyle = self.tableView.separatorStyle
            self.tableView.separatorStyle = .None
        }
        refreshLoadingView(nil)
    }
    
    func objectsDidLoad(error: NSError?) {
        // Called when loading object completed
        if firstLoad && hasContent() {
            firstLoad = false
            if let savedSeparatorStyle = savedSeparatorStyle {
                self.tableView.separatorStyle = savedSeparatorStyle
            }
        }
        refreshLoadingView(error)
    }
    
    func queryForTable() -> BaseRouter? {
        // Subclass override method to query database
        return nil
    }
    
    func objectsWillDelete() {
        
    }
    
    func objectsDidDelete() {
        
    }
    
    func queryForDelete(object: DataModel) -> BaseRouter? {
        // Subclass override method to delete object
        return nil
    }
    
    private func alterQuery(query: BaseRouter, forLoadingPage page: Int) {
        // Alters a query to add functionality like pagination
        if paginationEnabled && self.objectsPerPage > 0 {
            query.limit = objectsPerPage
            query.skip = page * objectsPerPage
        }
    }
    
    func clear() {
        mutableObjects.removeAll()
        self.tableView.reloadData()
        currentPage = 0
    }
    
    @objc func loadObjects() {
        loadObjects(0, clear: true)
    }
    
    func loadObjects(page: Int, clear: Bool) {
        loading = true
        objectsWillLoad()
        
        // Call APIManager here
        if let query = queryForTable() {
            alterQuery(query, forLoadingPage: page)
            query.request(completion: { (result) in
                switch result {
                case .Success(let objects):
                    self.loading = false
                    self.currentPage = page
                    
                    if clear {
                        self.mutableObjects.removeAll()
                    }
                    
                    if let objects = objects as? [DataModel] {
                        self.lastLoadCount = objects.count
                        self.mutableObjects.appendContentsOf(objects)
                    }else {
                        self.lastLoadCount = -1
                    }
                    
                    self.objectsDidLoad(nil)
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                default:
                    self.loading = false
                    self.lastLoadCount = -1
                    self.objectsDidLoad(Constants.RequestError)
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            })
        }
    }
    
    func loadNextPage() {
        if !loading {
            loadObjects(currentPage + 1, clear: false)
            refreshPaginationCell()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if (self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) {
            // Load more
            if shouldShowPaginationCell() && !loading {
                if let visiblePaths = tableView.indexPathsForVisibleRows {
                    for indexPath in visiblePaths {
                        if indexPath == indexPathForPaginationCell() {
                            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? SLActivityIndicatorTableViewCell {
                                cell.indicatorView.startAnimating()
                            }
                            self.loadNextPage()
                            break
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Remove object
    func removeObjectAtIndexPath(indexPath: NSIndexPath) {
        removeObjectAtIndexPath(indexPath, animated: true)
    }
    
    func removeObjectAtIndexPath(indexPath: NSIndexPath, animated: Bool) {
        removeObjectsAtIndexPaths([indexPath], animated: animated)
    }
    
    func removeObjectsAtIndexPaths(indexPaths: [NSIndexPath]) {
        removeObjectsAtIndexPaths(indexPaths, animated: true)
    }
    
    func removeObjectsAtIndexPaths(indexPaths: [NSIndexPath], animated: Bool) {
        self.objectsWillDelete()
        if indexPaths.count == 0 {
            return
        }
        
        // We need the contents as both an index set and a list of index paths.
        let indexes = NSMutableIndexSet()
        for indexPath in indexPaths {
            if indexPath.section != 0 {
                NSException.raise(NSRangeException, format: "Index Path section %d out of range!", arguments: getVaList([indexPath.section]))
            }
            
            if indexPath.row >= self.mutableObjects.count {
                NSException.raise(NSRangeException, format: "Index Path row %d out of range!", arguments: getVaList([indexPath.row]))
            }
            
            indexes.addIndex(indexPath.row)
        }
        
        // Call API Manager delete object
        let objectsToRemove = self.objects().objectsAtIndexes(indexes.toArray())
        // Remove the contents from our local cache so we can give the user immediate feedback.
        self.mutableObjects.removeObjectsInArray(objectsToRemove)
        self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: animated ? .Automatic : .None)
        
        let deleteGroup = dispatch_group_create()
        var hasError = false
        self.refreshControl?.enabled = false
        loading = true
        for object in objectsToRemove {
            // Call api to delete object
            if let query = queryForDelete(object) {
                dispatch_group_enter(deleteGroup)
                query.request(completion: { (result) in
                    switch result {
                    case .Ok, .Success(_):
                        self.objectsDidDelete()
                        dispatch_group_leave(deleteGroup)
                    default:
                        dispatch_group_leave(deleteGroup)
                        hasError = true
                    }
                })
            }
        }
        
        dispatch_group_notify(deleteGroup, dispatch_get_main_queue()) {
            // Wait to all request completed
            self.refreshControl?.enabled = true
            self.loading = false
            if hasError {
                self.handleDeletionError(nil)
            }
            
            // Show no content if no object
            if self.objects().count == 0 {
                self.endLoading(false, error: nil, completion: nil)
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.mutableObjects.count
        if shouldShowPaginationCell() {
            return count + 1
        }
        
        return count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if shouldShowPaginationCell() && indexPath.row == indexPathForPaginationCell().row {
            // Return the pagination cell on the last cell
            cell = self.tableView(tableView, cellForNextPageAtIndexPath: indexPath)
        }else {
            cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath, object: objectAtIndexPath(indexPath))
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: DataModel) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }
        
        self.tableView(tableView, configureCell: cell!, atIndexPath: indexPath, object: object)
        
        return cell!
    }
    
    func tableView(tableView: UITableView, configureCell: UITableViewCell, atIndexPath indexPath: NSIndexPath, object: DataModel) {
        
    }
    
    func tableView(tableView: UITableView, cellForNextPageAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLActivityIndicatorTableViewCell.cellIdentifier(), forIndexPath: indexPath)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !firstLoad && paginationEnabled && indexPath == indexPathForPaginationCell() {
            loadNextPage()
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.isEqual(indexPathForPaginationCell()) {
            return .None
        }
        
        return .Delete
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.isEqual(indexPathForPaginationCell()) {
            return false
        }
        
        return true
    }
    
    // MARK: - Pagination
    func shouldShowPaginationCell() -> Bool {
        // Whether we need to show the pagination cell
        return paginationEnabled && !editing && mutableObjects.count != 0 && (lastLoadCount >= objectsPerPage)
    }
    
    private func refreshPaginationCell() {
        // Selectively refresh pagination cell
        if shouldShowPaginationCell() {
//            self.tableView.reloadRowsAtIndexPaths([indexPathForPaginationCell()], withRowAnimation: .None)
        }
    }
    
    func indexPathForPaginationCell() -> NSIndexPath {
        // The row of the pagination cell
        return NSIndexPath(forRow: mutableObjects.count, inSection: 0)
    }
    
    // MARK: - Error handling
    func handleDeletionError(error: NSError?) {
        //Fully reload on error.
        loadObjects()
        // Show alert error
        var message = "Error occurred during deletion. Please try again!".localized
        if let error = error {
            message = "Error occurred during deletion: \"\(error.localizedDescription)\""
        }
        
        Constants.showAlert("Delete Error", message: message, actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
    }
    
    // MARK: - Accessors
    func objectAtIndexPath(indexPath: NSIndexPath) -> DataModel {
        return self.mutableObjects[indexPath.row]
    }
    
    func objects() -> [DataModel] {
        // Get all immutable objects
        return self.mutableObjects
    }
    
    // MARK: - Actions
    @objc func refreshControlValueChanged(refreshControl: UIRefreshControl) {
        if !loading {
            loadObjects()
        }
    }
    
    // MARK: - Loading View
    private func refreshLoadingView(error: NSError?) {
        let showLoadingView = loadingViewEnabled && loading && firstLoad
        if let loadingView = loadingView as? SLLoadingView {
            if showLoadingView {
                startLoading(false, completion: nil)
                loadingView.activityIndicator.startAnimating()
            }else {
                loadingView.activityIndicator.startAnimating()
                // check show/hide errorView, emptyView when load objects completed
                if !errorViewEnabled {
                    errorView = nil
                }
                
                if !emptyViewEnabled {
                    emptyView = nil
                }
                
                endLoading(false, error: error, completion: nil)
            }
        }
    }
}

extension SLQueryTableViewController {
    // MARK: - Empty State
    override func loadObject() {
        // Call when has error and user tap to screen
        loadObjects()
    }
    
    override func hasContent() -> Bool {
        // Check controller has content and matching empty state
        return mutableObjects.count > 0
    }
}
