//
//  SLQueryCollectionViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/13/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import SDCAlertView

private let reuseIdentifier = "Cell"
private let nextPageReusableViewIdentifier = "nextPageView"

@IBDesignable class SLQueryCollectionViewController: SLBaseCollectionViewController, UICollectionViewDelegateFlowLayout {
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
    var loading = false
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
    private var lastLoadCount = -1
    private var refreshControl = UIRefreshControl()
    private var currentNextPageView: SLActivityIndicatorCollectionReusableView?
    
    override func loadView() {
        super.loadView()
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.registerNib(SLActivityIndicatorCollectionReusableView.nib(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: nextPageReusableViewIdentifier)
        if pullToRefreshEnabled {
            refreshControl.addTarget(self, action: #selector(SLQueryCollectionViewController.refreshControlValueChanged(_:)), forControlEvents: .ValueChanged)
            self.collectionView?.addSubview(refreshControl)
            self.collectionView?.alwaysBounceVertical = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadObjects()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Responding to Events
    func objectsWillLoad() {
        refreshLoadingView(nil)
    }
    
    func objectsDidLoad(error: NSError?) {
        if firstLoad && hasContent() {
            firstLoad = false
        }
        
        refreshLoadingView(error)
    }
    
    // MARK: - Removing Objects
    func removeObjectAtIndexPath(indexPath: NSIndexPath) {
        removeObjectAtIndexPath(indexPath)
    }
    
    func removeObjectsAtIndexPaths(indexPaths: [NSIndexPath]) {
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
    }
    
    // MARK: - Loading data
    func loadObjects() {
        loadObjects(0, clear: true)
    }
    
    func loadObjects(page: Int, clear: Bool) {
        loading = true
        objectsWillLoad()
        
        // Call APIManager here
        if let query = queryForCollection() {
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
                    self.collectionView?.reloadData()
                    self.refreshControl.endRefreshing()
                default:
                    self.loading = false
                    self.lastLoadCount = -1
                    self.objectsDidLoad(nil)
                    self.refreshControl.endRefreshing()
                }
            })
            
            query.request(completion: { (result) in
                switch result {
                case .Success(let objects):
                    self.loading = false
                    self.currentPage = page
                    
                    if let objects = objects as? [DataModel] {
                        self.lastLoadCount = objects.count
                        if clear {
                            self.mutableObjects.removeAll()
                        }
                        
                        self.mutableObjects.appendContentsOf(objects)
                    }
                    
                    self.objectsDidLoad(nil)
                    self.collectionView?.reloadData()
                    self.refreshControl.endRefreshing()
                default:
                    self.loading = false
                    self.lastLoadCount = -1
                    self.objectsDidLoad(nil)
                    self.refreshControl.endRefreshing()
                }
            })
            
            query.request(completion: { (result) in
                switch result {
                case .Success(let objects):
                    self.loading = false
                    self.currentPage = page
                    
                    if let objects = objects as? [DataModel] {
                        self.lastLoadCount = objects.count
                        if clear {
                            self.mutableObjects.removeAll()
                        }
                        
                        self.mutableObjects.appendContentsOf(objects)
                    }
                    
                    self.objectsDidLoad(nil)
                    self.collectionView?.reloadData()
                    self.refreshControl.endRefreshing()
                default:
                    self.loading = false
                    self.lastLoadCount = -1
                    self.objectsDidLoad(nil)
                    self.refreshControl.endRefreshing()
                }
            })
        }
    }
    
    func loadNextPage() {
        if !loading {
            loadObjects(currentPage + 1, clear: false)
        }
    }
    
    func clear() {
        mutableObjects.removeAll()
        self.collectionView?.reloadData()
        currentPage = 0
    }
    
    // MARK: - Querying
    func queryForCollection() -> BaseRouter? {
        // Subclass override method to query database
        return nil
    }
    
    func queryForDelete() -> BaseRouter? {
        // Subclass override method to delete object
        return nil
    }
    
    // Alters a query to add functionality like pagination
    private func alterQuery(query: BaseRouter, forLoadingPage page: Int) {
        if paginationEnabled && self.objectsPerPage > 0 {
            query.limit = objectsPerPage
            query.skip = page * objectsPerPage
        }
    }
    
    // MARK: - Data Source Methods
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: DataModel) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        return cell
    }
    
    func collectionViewReusableViewForNextPageAction(collectionView: UICollectionView) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: nextPageReusableViewIdentifier, forIndexPath: indexPathForPaginationCell())
        if let nextPageCell = cell as? SLActivityIndicatorCollectionReusableView {
            currentNextPageView = nextPageCell
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mutableObjects.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return self.collectionView(collectionView, cellForItemAtIndexPath: indexPath, object: objectAtIndexPath(indexPath))
    }

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return collectionViewReusableViewForNextPageAction(collectionView)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if shouldShowPaginationCell() {
            return CGSizeMake(CGRectGetWidth(collectionView.bounds), 50.0)
        }
        return CGSizeZero
    }
    // MARK: - Pagination
    private func shouldShowPaginationCell() -> Bool {
        return paginationEnabled && mutableObjects.count != 0 && (lastLoadCount >= objectsPerPage)
    }
    
    private func indexPathForPaginationCell() -> NSIndexPath {
        return NSIndexPath(forRow: 0, inSection: numberOfSectionsInCollectionView(collectionView!)-1)
    }
    
    // MARK: - Error handling
    private func handleDeletionError(error: NSError?) {
        //Fully reload on error.
        loadObjects()
        // Show alert error
        let message = "Error occurred during deletion: \"\(error?.localizedDescription)\""
        Constants.showAlert("Delete Error", message: message, actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
    }
    
    // MARK: - Accessors
    func objects() -> [DataModel] {
        return self.mutableObjects
    }
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> DataModel {
        return self.mutableObjects[indexPath.row]
    }
    
    // MARK: - Actions
    @objc private func refreshControlValueChanged(refreshControl: UIRefreshControl) {
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
                endLoading(false, error: error, completion: nil)
            }
        }
    }
}

extension SLQueryCollectionViewController {
    
    override func loadObject() {
        loadObjects()
    }
    
    override func hasContent() -> Bool {
        return mutableObjects.count > 0
    }
}
