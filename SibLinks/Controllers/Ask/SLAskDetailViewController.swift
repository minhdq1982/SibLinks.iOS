//
//  SLAskDetailViewController.swift
//  SibLinks
//
//  Created by Anh Nguyen on 9/16/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import SKPhotoBrowser
import SDCAlertView

enum QuestionAction: Int {
    case Edit = 0, Delete = 1, Resend = 2
}

enum AskQuestionDetail: Int {
    case Question = 0
    case QuestionImage
}

class SLAskDetailViewController: SLBaseTableViewController {
    
    var question: SLQuestion?
    var createdQuestion = false
    var allowEdited = true
    private var savedSeparatorStyle: UITableViewCellSeparatorStyle?
    private var firstLoad = true
    private var objectsPerPage = Constants.LIMIT_DEFAULT_NUMBER
    private var currentPage = 0
    private var lastLoadCount = -1
    
    var filterActionSheet: JLActionSheet?
    
    deinit {
        print("Dealloc")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let subjectName = question?.category?.subject {
            self.navigationItem.title = subjectName
        }else {
            self.navigationItem.title = ""
        }
        
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.tableView.separatorStyle = .None
        // Register
        self.tableView.registerNib(SLAskQuestionTableViewCell.nib(), forCellReuseIdentifier: SLAskQuestionTableViewCell.cellIdentifier())
        self.tableView.registerNib(SLAskAlbumTableViewCell.nib(), forCellReuseIdentifier: SLAskAlbumTableViewCell.cellIdentifier())
        self.tableView.registerNib(SLBubbleAnswerTableViewCell.nib(), forCellReuseIdentifier: SLBubbleAnswerTableViewCell.cellIdentifier())
        self.tableView.registerNib(SLActivityIndicatorTableViewCell.nib(), forCellReuseIdentifier: SLActivityIndicatorTableViewCell.cellIdentifier())
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(SLAskDetailViewController.refreshControlValueChanged(_:)), forControlEvents: .ValueChanged)
        self.refreshControl = refreshControl
        
        loadStretchyHeaderView()
        loadQuestion(0, clear: true)
        firstLoad = false
        
        if allowEdited {
            // Observer question change
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(observerQuestion(_:)),
                                                             name: Constants.POST_QUESTION_CHANGE, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(postQuestion(_:)), name: Constants.POST_QUESTION_SEND, object: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateQuestionStatus()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateQuestionStatus() {
        if allowEdited {
            // Add item for navigation bar
            if createdQuestion {
                self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left),(ItemType.Loading, ItemPosition.Right)])
            } else {
                self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left), (ItemType.Filter, ItemPosition.Right)])
            }
        }else {
            self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left)])
        }
    }
    
    func loadStretchyHeaderView() {
        let headerView = SLAskQuestionHeaderView.loadFromNib()
        headerView.maximumContentHeight = 150
        headerView.minimumContentHeight = 80
        headerView.updateDataFrom(self.question)
        headerView.tag = 100
        self.tableView.addSubview(headerView)
    }
    
    func updateHeaderView() {
        if let headerView = self.tableView.viewWithTag(100) as? SLAskQuestionHeaderView {
            headerView.updateDataFrom(self.question)
        }
    }
    
    func loadQuestion(page: Int, clear: Bool) {
        if let questionId = question?.objectId {
            // Get question detail
            savedSeparatorStyle = self.tableView.separatorStyle
            self.tableView.separatorStyle = .None
            loading = true
            refreshLoadingView(nil)
            
            AskQuestionRouter(endpoint: AskQuestionEndpoint.GetQuestion(questionId: questionId)).request(completion: { (result) in
                if self.allowEdited {
                    self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left), (ItemType.Filter, ItemPosition.Right)])
                }else {
                    self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left)])
                }
                switch result {
                    case .Success(let objects):
                        if let result = objects as? [SLQuestion] {
                            if result.count > 0 {
                                self.question = result[0]
                                self.getQuestionAnswer(questionId, page: page, clear: clear)
                            } else {
                                self.reloadData()
                            }
                        } else {
                            self.reloadData()
                        }
                        break
                    default:
                        self.reloadData()
                }
            })
        }
    }
    
    private func getQuestionAnswer(questionId: Int, page: Int, clear: Bool) {
        let query = AskQuestionRouter(endpoint: AskQuestionEndpoint.GetQuestionAnswer(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, questionId: questionId))
        alterQuery(query, forLoadingPage: page)
        query.request(completion: { (result) in
            switch result {
            case .Success(let objects):
                self.tableView.separatorStyle = self.savedSeparatorStyle!
                self.loading = false
                self.refreshLoadingView(nil)
                self.refreshControl?.endRefreshing()
                if let answers = objects as? [SLAnswer] {
                    var answerList = [SLAnswer]()
                    if clear {
                        self.question?.answers = nil
                    }else {
                        if let answers = self.question?.answers {
                            answerList.appendContentsOf(answers)
                        }
                    }
                    
                    answerList.appendContentsOf(answers)
                    self.question?.answers = answerList
                    self.lastLoadCount = answers.count
                    self.tableView.reloadData()
                }else {
                    self.lastLoadCount = -1
                }
                self.updateHeaderView()
                self.updateQuestionStatus()
                self.updateNavigationTitle()
            default:
                self.lastLoadCount = -1
                self.reloadData()
                self.updateQuestionStatus()
            }
        })
    }
    
    private func reloadData() {
        self.tableView.separatorStyle = self.savedSeparatorStyle!
        self.loading = false
        self.refreshLoadingView(nil)
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
        self.updateHeaderView()
        self.updateQuestionStatus()
        self.updateNavigationTitle()
    }
    
    private func updateNavigationTitle() {
        if let subjectName = question?.category?.subject {
            self.navigationItem.title = subjectName
        }else {
            self.navigationItem.title = ""
        }
    }
    
    // MARK: - Actions
    
    @objc private func refreshControlValueChanged(refreshControl: UIRefreshControl) {
        if !loading {
            loadQuestion(0, clear: true)
        }
    }
    
    func likeAnswer(sender: LoadingButton, atIndexPath indexPath: NSIndexPath) {
        if !allowEdited {
            return
        }
        
        var index = indexPath.row - 1
        if self.question?.questionImages?.count > 0 {
            index = indexPath.row - 2
        }
        
        if let answers = self.question?.answers {
            if index < answers.count {
                let answer = answers[index]
                sender.loading = true
                AskQuestionRouter(endpoint: AskQuestionEndpoint.LikeAnswer(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, answerId: (answer.objectId)!)).request(completion: { (result) in
                    switch result {
                    case .Ok:
                        sender.loading = false
                        answer.like = !answer.like
                        sender.tintColor = answer.like ? UIColor(hexString: Constants.SIBLINKS_LIKE_COLOR) : UIColor(hexString: Constants.SIBLINKS_UNLIKE_COLOR)
                    default:
                        sender.loading = false
                        print("error")
                    }
                })
            }
        }
    }
    
    func editQuestion() {
        let storyboard = UIStoryboard(name: "CustomCropImageScreen", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("CustomCropImage") as! CustomCropImageController
        vc.question = question
        
        let navigationController = SLRootNavigationController(rootViewController: vc)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func deleteQuestion() {
        if self.question?.localId > 0 && (self.question?.objectId == nil || self.question?.objectId == 0) {
            SLLocalDataManager.sharedInstance.removeQuestion(self.question!)
            return
        }
        
        if let questionId = question?.objectId {
            AskQuestionRouter(endpoint: AskQuestionEndpoint.DeleteQuestion(questionId: questionId)).request(completion: { (result) in
                switch result {
                case .Success(let status):
                    if let status = status as? Bool {
                        if status {
                            if let viewController = self.navigationController?.viewControllers[0] as? SLAskViewController {
                                viewController.loadObjects()
                            }
                            self.navigationController?.popViewControllerAnimated(true)
                        }else {
                            print("Error")
                        }
                    }
                default:
                    print("Error")
                }
            })
        }
    }
    
    func resendQuestion() {
        if let question = question {
            self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left), (ItemType.Loading, ItemPosition.Right)])
            if let viewController = navigationController?.viewControllers[0] as? SLAskViewController {
                viewController.updateStatusQuestion(question)
            }
            
            SLLocalDataManager.sharedInstance.uploadQuestion(question, success: {
                self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left), (ItemType.Filter, ItemPosition.Right)])
                self.loadQuestion(0, clear: true)
                }, failure: { (error) in
                    self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left), (ItemType.Resend, ItemPosition.Right)])
            })
        }
    }
    
    override func filter(sender: UIBarButtonItem) {
        self.filterActionSheet = JLActionSheet(delegate: self, dataSource: self)
        self.filterActionSheet?.tableView.registerNib(SLFilterTableViewCell.nib(), forCellReuseIdentifier: SLFilterTableViewCell.cellIdentifier())
        self.filterActionSheet?.show()
    }
    
    func showMentorProfile(indexPath: NSIndexPath) {
        
        var mentor: SLMentor?
        if questionHasImage() {
            if let answers = self.question?.answers {
                if indexPath.row - 2 < answers.count {
                    let answer = answers[indexPath.row - 2]
                    mentor = answer.mentor
                }
            }
        }else {
            if let answers = self.question?.answers {
                if indexPath.row - 1 < answers.count {
                    let answer = answers[indexPath.row - 1]
                    mentor = answer.mentor
                }
            }
        }
        
        if let mentor = mentor {
            let mentorDetailController = SLMentorProfileViewController.controller
            mentorDetailController.mentor = mentor
            self.navigationController?.pushViewController(mentorDetailController, animated: true)
        }
    }
    
    // MARK: - Observer Question
    func observerQuestion(notification: NSNotification) {
        createdQuestion = false
        if let question = question {
            if let status = notification.object as? Bool {
                if !status {
                    return
                }
            } else if let objectId = notification.object as? Int {
                if objectId > 0 {
                    question.objectId = objectId
                }
            }
            
            self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left), (ItemType.Loading, ItemPosition.Right)])
            if question.objectId > 0 {
                self.loadQuestion(0, clear: true)
            } else {
                self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left), (ItemType.Filter, ItemPosition.Right)])
            }
        }
    }
    
    func postQuestion(notification: NSNotification) {
        if let question = notification.object as? SLQuestion {
            self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left), (ItemType.Loading, ItemPosition.Right)])
            self.question = question
            self.updateHeaderView()
            self.tableView.reloadData()
        }
    }
}

extension SLAskDetailViewController {
    
    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if shouldShowPaginationCell() && indexPath.row == indexPathForPaginationCell().row {
            let loadingCell = tableView.dequeueReusableCellWithIdentifier(SLActivityIndicatorTableViewCell.cellIdentifier(), forIndexPath: indexPath)
            return loadingCell
        }else {
            if questionHasImage() {
                switch indexPath.row {
                case AskQuestionDetail.Question.rawValue:
                    if let askCell = tableView.dequeueReusableCellWithIdentifier(SLAskQuestionTableViewCell.cellIdentifier()) as? SLAskQuestionTableViewCell {
                        askCell.configCellWithData(question)
                        return askCell
                    }
                    
                case AskQuestionDetail.QuestionImage.rawValue:
                    if let albumCell = tableView.dequeueReusableCellWithIdentifier(SLAskAlbumTableViewCell.cellIdentifier()) as? SLAskAlbumTableViewCell {
                        albumCell.delegate = self
                        albumCell.configCellWithData(question)
                        return albumCell
                    }
                    
                default:
                    if let answerCell = tableView.dequeueReusableCellWithIdentifier(SLBubbleAnswerTableViewCell.cellIdentifier()) as? SLBubbleAnswerTableViewCell {
                        answerCell.setIndexPath(indexPath, sender: self)
                        if let answers = self.question?.answers {
                            if indexPath.row - 2 < answers.count {
                                let answer = answers[indexPath.row - 2]
                                answerCell.configCellWithData(answer)
                            }
                        }
                        return answerCell
                    }
                }
            } else {
                switch indexPath.row {
                case AskQuestionDetail.Question.rawValue:
                    if let askCell = tableView.dequeueReusableCellWithIdentifier(SLAskQuestionTableViewCell.cellIdentifier()) as? SLAskQuestionTableViewCell {
                        askCell.configCellWithData(question)
                        return askCell
                    }
                    
                default:
                    if let answerCell = tableView.dequeueReusableCellWithIdentifier(SLBubbleAnswerTableViewCell.cellIdentifier()) as? SLBubbleAnswerTableViewCell {
                        answerCell.setIndexPath(indexPath, sender: self)
                        if let answers = self.question?.answers {
                            if indexPath.row - 1 < answers.count {
                                let answer = answers[indexPath.row - 1]
                                answerCell.configCellWithData(answer)
                            }
                        }
                        
                        return answerCell
                    }
                }
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading {
            return 0
        }
        
        var questionCount = (self.question?.questionImages?.count > 0) ? 2 : 1
        if question?.localId > 0 {
            questionCount = (self.question?.localImageNames?.count > 0) ? 2 : 1
        }
        
        let count = (self.question?.answers?.count > 0) ? ((self.question?.answers?.count)! + questionCount) : questionCount
        if shouldShowPaginationCell() {
            return count + 1
        }
        
        return count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func questionHasImage() -> Bool {
        var hasImage = false
        if self.question?.localId > 0 {
            hasImage = self.question?.localImageNames?.count > 0
        }else {
            hasImage = self.question?.questionImages?.count > 0
        }
        
        return hasImage
    }
}

extension SLAskDetailViewController {
    
    // MARK: - Loading View
    private func refreshLoadingView(error: NSError?) {
        if let loadingView = loadingView as? SLLoadingView {
            if loading && firstLoad {
                startLoading(false, completion: nil)
                loadingView.activityIndicator.startAnimating()
            }else {
                loadingView.activityIndicator.startAnimating()
                endLoading(false, error: error, completion: nil)
            }
        }
    }
    
    override func hasContent() -> Bool {
        return !firstLoad
    }
}

extension SLAskDetailViewController: SKPhotoBrowserDelegate {
    func presentPhotoBrowser(index: Int, answer: SLAnswer?) {
        SKPhotoBrowserOptions.displayAction = true
        SKPhotoBrowserOptions.displayToolbar = false
        SKPhotoBrowserOptions.displayCounterLabel = true
        SKPhotoBrowserOptions.displayBackAndForwardButton = true
        SKPhotoBrowserOptions.disableVerticalSwipe = true
        SKPhotoBrowserOptions.displayCloseButton = true
        SKPhotoBrowserOptions.displayDeleteButton = false
        
        let photos = createPhotos(answer)
        if photos.count == 0 {
            return
        }
        
        let browser = SKPhotoBrowser(photos: photos)
        browser.initializePageIndex(index)
        browser.delegate = self
        
        presentViewController(browser, animated: true, completion: nil)
    }
    
    func createPhotos(answer: SLAnswer?) -> [SKPhoto] {
        var photos = [SKPhoto]()
        
        if let answer = answer {
            if let images = answer.answerImages {
                for image in images {
                    let photo = SKPhoto.photoWithImageURL(image)
                    photo.shouldCachePhotoURLImage = true
                    photos.append(photo)
                }
            }
        }else {
            if question?.localId > 0 {
                let images = SLLocalDataManager.sharedInstance.getQuestionPhotos(question!)
                for image in images {
                    let photo = SKPhoto.photoWithImage(image)
                    photos.append(photo)
                }
            }else {
                if let images = question?.questionImages {
                    for image in images {
                        let photo = SKPhoto.photoWithImageURL(image)
                        photo.shouldCachePhotoURLImage = true
                        photos.append(photo)
                    }
                }
            }
        }
        
        return photos
    }
}

extension SLAskDetailViewController: JLActionSheetDataSource {
    
    // MARK: - JLActionSheetDataSource
    
    func JLActionSheetDataSourceTableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.question?.numberOfReplies > 0 {
            return 1
        }else {
            return self.question?.localId > 0 ? 3 : 2
        }
    }
    
    func JLActionSheetDataSourceTableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLFilterTableViewCell.cellIdentifier())
        
        if let filterCell = cell as? SLFilterTableViewCell {
            var actionName = ""
            if self.question?.numberOfReplies > 0 {
                actionName = "Delete"
            }else {
                switch indexPath.row {
                case QuestionAction.Edit.rawValue:
                    actionName = "Edit"
                case QuestionAction.Delete.rawValue:
                    actionName = "Delete"
                case QuestionAction.Resend.rawValue:
                    actionName = "Resend"
                default:
                    actionName = ""
                }
            }
            filterCell.filterTitleLabel.text = actionName
            return filterCell
        }
        
        return UITableViewCell()
    }
    
    func JLActionSheetDataSourceTableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func JLActionSheetDataSourceHeightOfContentView() -> CGFloat {
        if self.question?.numberOfReplies > 0 {
            return 50
        }else {
            return self.question?.localId > 0 ? 150 : 100
        }
    }
}

extension SLAskDetailViewController: JLActionSheetDelegate {
    
    // MARK: - JLActionSheetDelegate
    
    func JLActionSheetDelegateTableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.filterActionSheet?.dismiss()
        if self.question?.numberOfReplies > 0 {
            Constants.showAlert(message: "Are you sure you want to delete?", actions:
                AlertAction(title: Constants.CANCEL_ALERT_BUTTON, style: .Default),
                                AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred, handler: { (_) in
                                    self.deleteQuestion()
                                }))
        }else {
            switch indexPath.row {
            case QuestionAction.Edit.rawValue:
                editQuestion()
            case QuestionAction.Delete.rawValue:
                Constants.showAlert(message: "Are you sure you want to delete?", actions:
                    AlertAction(title: Constants.CANCEL_ALERT_BUTTON, style: .Default),
                                    AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred, handler: { (_) in
                                        self.deleteQuestion()
                                    }))
                
            case QuestionAction.Resend.rawValue:
                resendQuestion()
            default:
                print("Not action")
            }
        }
    }
}

extension SLAskDetailViewController {
    // MARK: - Paging
    private func alterQuery(query: BaseRouter, forLoadingPage page: Int) {
        // Alters a query to add functionality like pagination
        if self.objectsPerPage > 0 {
            query.limit = objectsPerPage
            query.skip = page * objectsPerPage
        }
    }
    
    private func shouldShowPaginationCell() -> Bool {
        // Whether we need to show the pagination cell
        return !editing && question?.answers?.count != 0 && (lastLoadCount >= objectsPerPage)
    }
    
    private func indexPathForPaginationCell() -> NSIndexPath {
        var questionCount = (self.question?.questionImages?.count > 0) ? 2 : 1
        if question?.localId > 0 {
            questionCount = (self.question?.localImageNames?.count > 0) ? 2 : 1
        }
        
        let answerCount = question?.answers?.count ?? 0
        // The row of the pagination cell
        return NSIndexPath(forRow: questionCount + answerCount, inSection: 0)
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
                            
                            if let questionId = question?.objectId {
                                self.getQuestionAnswer(questionId, page: currentPage + 1, clear: false)
                            }
                            
                            break
                        }
                    }
                }
            }
        }
    }
}
