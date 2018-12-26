//
//  SLAskViewController.swift
//  SibLinks
//
//  Created by Jana on 9/9/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import SDCAlertView

enum OrderType: String {
    case newest = "newest", answered = "answered", unanswered = "unanswered"
}

class SLAskViewController: SLQueryViewController {
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightOfTopView: NSLayoutConstraint!
    @IBOutlet weak var questionCountLabel: UILabel!
    @IBOutlet weak var filterLabel: UILabel!
    
    private var questions = [SLQuestion]()
    
    var filterActionSheet: JLActionSheet?
    var heightOfTopViewValue: CGFloat = 0
    var lastContentOffset: CGFloat = 0
    var orderType = OrderType.newest
    let actionSheetDataArray = ["Newest", "Answered", "Unanswered"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell
        self.tableView.registerNib(SLAskTableViewCell.nib(), forCellReuseIdentifier: SLAskTableViewCell.cellIdentifier())
        
        // Config tableview
        self.tableView.separatorStyle = .None
        self.tableView.tableFooterView = UIView()
        
        self.navigationItem.title = "My questions".localized
        emptyView = SLQuestionEmptyView.loadFromNib()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(observerQuestion(_:)), name: Constants.POST_QUESTION_CHANGE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(postQuestion(_:)), name: Constants.POST_QUESTION_SEND, object: nil)
        heightOfTopViewValue = self.heightOfTopView.constant
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationBarButtonItems([(ItemType.Menu, ItemPosition.Left)])
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        self.countQuestion()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func objectsDidLoad(error: NSError?) {
        parseQuestion()
        super.objectsDidLoad(error)
        countQuestion()
    }
    
    func parseQuestion() {
        questions.removeAll()
        let pendingQuestions = SLLocalDataManager.sharedInstance.getLocalQuestions()
        var newQuestions = [SLQuestion]()
        var editedQuestions = [SLQuestion]()
        for question in pendingQuestions {
            if question.localId > 0 && (question.objectId == nil || question.objectId == 0) {
                newQuestions.append(question)
            } else if question.objectId > 0 {
                editedQuestions.append(question)
            }
        }
        
        questions.appendContentsOf(newQuestions)
        var loadQuestions = [SLQuestion]()
        if let questionList = objects() as? [SLQuestion] {
            for question in questionList {
                if editedQuestions.count > 0 {
                    var added = false
                    for editedQuestion in editedQuestions {
                        if question.objectId == editedQuestion.objectId {
                            loadQuestions.append(editedQuestion)
                            added = true
                        }
                    }
                    
                    if !added {
                        loadQuestions.append(question)
                    }
                } else {
                    loadQuestions.append(question)
                }
            }
            questions.appendContentsOf(loadQuestions)
        }
    }
    
    func countQuestion() {
        // Get question count
        AskQuestionRouter(endpoint: AskQuestionEndpoint.CountQuestion(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, subjectId: -1, orderType: orderType)).request { (result) in
            switch result {
            case .Success(let data):
                if let counts = data as? [SLCount] {
                    if counts.count > 0 {
                        var newQuestions = [SLQuestion]()
                        let pendingQuestions = SLLocalDataManager.sharedInstance.getLocalQuestions()
                        for question in pendingQuestions {
                            if question.localId > 0 && (question.objectId == nil || question.objectId == 0) {
                                newQuestions.append(question)
                            }
                        }
                        if let numberOfQuestion = counts[0].numberOfQuestion {
                            var questionString = "You have 0 question."
                            let totalQuestions = numberOfQuestion + newQuestions.count
                            if totalQuestions > 0 {
                                if totalQuestions == 1 {
                                    questionString = "You have \(totalQuestions) question."
                                } else {
                                    questionString = "You have \(totalQuestions) questions."
                                }
                            }
                            
                            self.questionCountLabel.text = questionString
                        }
                    }
                }
            default:
                return
            }
        }
    }
    
    // MARK: - Query
    override func queryForTable() -> BaseRouter? {
        // Subclass override method to query database
        return AskQuestionRouter(endpoint: AskQuestionEndpoint.GetQuestions(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, subjectId: -1, orderType: self.orderType ?? .newest))
    }
    
    override func queryForDelete(object: DataModel) -> BaseRouter? {
        if let question = object as? SLQuestion {
            return AskQuestionRouter(endpoint: AskQuestionEndpoint.DeleteQuestion(questionId: question.objectId!))
        }
        
        return nil
    }
    
    // MARK: - Action
    
    func observerQuestion(notification: NSNotification) {
        self.loadObjects()
    }
    
    func postQuestion(notification: NSNotification) {
        if let question = notification.object as? SLQuestion {
            var row = 0
            if let index = questions.indexOf(question) {
                row = index
            } else {
                questions.insert(question, atIndex: 0)
            }
            
            refreshLoadingView(nil)
            self.tableView.reloadData()
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: row, inSection: 0)) as? SLAskTableViewCell {
                cell.resendButton.loading = true
                
                SLLocalDataManager.sharedInstance.uploadQuestion(question, success: {
                        cell.resendButton.loading = false
                    
                    }, failure: { (error) in
                    cell.resendButton.loading = false
                })
            }
        }
    }
    
    func repostQuestion(indexPath: NSIndexPath, sender: LoadingButton) {
        if indexPath.row < questions.count {
            let question = questions[indexPath.row]
            if question.localId > 0 {
                sender.loading = true
                SLLocalDataManager.sharedInstance.uploadQuestion(question, success: {
                    sender.loading = false
                    }, failure: { (error) in
                    sender.loading = false
                })
            }
        }
    }
    
    func updateStatusQuestion(question: SLQuestion) {
        if let index = questions.indexOf(question) {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            if let askCell = tableView.cellForRowAtIndexPath(indexPath) as? SLAskTableViewCell {
                askCell.resendButton.loading = true
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.questions.count
        return count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLAskTableViewCell.cellIdentifier(), forIndexPath: indexPath)
        if let askCell = cell as? SLAskTableViewCell {
            askCell.delegate = self
            askCell.controller = self
            askCell.indexPath = indexPath
            
            if indexPath.row < questions.count {
                let question = questions[indexPath.row]
                askCell.configCellWithData(question)
            }
            
            if indexPath.row == 0 {
                askCell.topLineView.hidden = true
            } else {
                askCell.topLineView.hidden = false
            }
            
            if indexPath.row == self.objects().count - 1 {
                askCell.bottomLineView.hidden = true
            } else {
                askCell.bottomLineView.hidden = false
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 107
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row < questions.count {
            let question = questions[indexPath.row]
            self.performSegueWithIdentifier(Constants.QUESTION_DETAIL_SEGUE, sender: question)
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.QUESTION_DETAIL_SEGUE {
            if let question = sender as? SLQuestion {
                if let detailViewController = segue.destinationViewController as? SLAskDetailViewController {
                    detailViewController.question = question
                    let status = question.localId > 0
                    detailViewController.createdQuestion = status
                }
            }
        }
    }

}

extension SLAskViewController: MGSwipeTableCellDelegate {
    
    // MARK: - MGSwipeTableCellDelegate
    
    func swipeTableCell(cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }
    
    func swipeTableCell(cell: MGSwipeTableCell, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        swipeSettings.transition = MGSwipeTransition.Border
        
        if (direction == MGSwipeDirection.RightToLeft) {
            let deleteButton = MGSwipeButton(title: "DELETE".localized, backgroundColor: UIColor(hexString: Constants.SIBLINKS_DELETE_BUTTON_COLOR), callback: { (sender) -> Bool in
                if let indexPath = self.tableView.indexPathForCell(sender) {
                    Constants.showAlert(message: "Are you sure you want to delete?", actions:
                        AlertAction(title: Constants.CANCEL_ALERT_BUTTON, style: .Default),
                        AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred, handler: { (_) in
                            self.removeQuestionAtIndexPaths([indexPath], animated: false)
                        }))
                }
                return true
            })
            
            if let indexPath = self.tableView.indexPathForCell(cell) {
                if indexPath.row < self.questions.count {
                    let question = questions[indexPath.row]
                    if question.numberOfReplies > 0 {
                        deleteButton.titleLabel?.font = Constants.regularFontOfSize(14)
                        return [deleteButton]
                    } else {
                        let editButton = MGSwipeButton(title: "EDIT".localized, backgroundColor: UIColor(hexString: Constants.SIBLINKS_EDIT_BUTTON_COLOR), callback: { (sender) -> Bool in
                            let storyboard = UIStoryboard(name: "CustomCropImageScreen", bundle: nil)
                            let vc = storyboard.instantiateViewControllerWithIdentifier("CustomCropImage") as! CustomCropImageController
                            vc.question = question
                            let navigationController = SLRootNavigationController(rootViewController: vc)
                            self.presentViewController(navigationController, animated: true, completion: nil)
                            
                            return true
                        })
                        
                        deleteButton.titleLabel?.font = Constants.regularFontOfSize(14)
                        editButton.titleLabel?.font = Constants.regularFontOfSize(14)
                        return [editButton, deleteButton]
                    }
                }
            }
        }
        
        return nil
    }
    
    func removeQuestionAtIndexPaths(indexPaths: [NSIndexPath], animated: Bool) {
        if indexPaths.count == 0 {
            return
        }
        
        // We need the contents as both an index set and a list of index paths.
        let indexes = NSMutableIndexSet()
        for indexPath in indexPaths {
            if indexPath.section != 0 {
                NSException.raise(NSRangeException, format: "Index Path section %d out of range!", arguments: getVaList([indexPath.section]))
            }
            
            if indexPath.row >= self.questions.count {
                NSException.raise(NSRangeException, format: "Index Path row %d out of range!", arguments: getVaList([indexPath.row]))
            }
            
            indexes.addIndex(indexPath.row)
        }
        
        // Call API Manager delete object
        let objectsToRemove = self.questions.objectsAtIndexes(indexes.toArray())
        
        self.questions.removeObjectsInArray(objectsToRemove)
        self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: animated ? .Automatic : .None)
        
        let deleteGroup = dispatch_group_create()
        var hasError = false
        self.refreshControl?.enabled = false
        loading = true
        for object in objectsToRemove {
            if object.localId > 0 && (object.objectId == nil || object.objectId == 0) {
                SLLocalDataManager.sharedInstance.removeQuestion(object)
                continue
            }
            
            if let query = queryForDelete(object) {
                dispatch_group_enter(deleteGroup)
                query.request(completion: { (result) in
                    switch result {
                    case .Success(let status):
                        if let status = status as? Bool {
                            self.removeObject(object)
                            hasError = !status
                        }
                        dispatch_group_leave(deleteGroup)
                    default:
                        dispatch_group_leave(deleteGroup)
                        hasError = true
                    }
                })
            }
        }
        
        dispatch_group_notify(deleteGroup, dispatch_get_main_queue()) {
            self.refreshControl?.enabled = true
            self.loading = false
            if hasError {
                self.handleDeletionError(nil)
                self.tableView.reloadData()
            }
            
            if self.questions.count == 0 {
                self.endLoading(false, error: nil, completion: nil)
            }
            self.countQuestion()
        }
    }
}

extension SLAskViewController {
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.lastContentOffset <= self.heightOfTopViewValue/2.0 {
            self.topConstraint.constant = 0
        } else {
            self.topConstraint.constant = -self.heightOfTopViewValue
        }
        
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
}

extension SLAskViewController {
    
    // MARK: - Storyboard actions
    
    @IBAction func filterAction(sender: AnyObject) {
        self.tableView.reloadData()
        self.filterActionSheet = JLActionSheet(delegate: self, dataSource: self)
        self.filterActionSheet?.tableView.registerNib(SLFilterTableViewCell.nib(), forCellReuseIdentifier: SLFilterTableViewCell.cellIdentifier())
        self.filterActionSheet?.show()
    }
    
}

extension SLAskViewController: JLActionSheetDataSource {
    
    // MARK: - JLActionSheetDataSource
    
    func JLActionSheetDataSourceTableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.actionSheetDataArray.count
    }
    
    func JLActionSheetDataSourceTableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLFilterTableViewCell.cellIdentifier())
        
        if let filterCell = cell as? SLFilterTableViewCell {
            filterCell.filterTitleLabel.text = self.actionSheetDataArray[indexPath.row]
            return filterCell
        }
        
        return UITableViewCell()
    }
    
    func JLActionSheetDataSourceTableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func JLActionSheetDataSourceHeightOfContentView() -> CGFloat {
        return 150
    }
    
}

extension SLAskViewController: JLActionSheetDelegate {
    
    // MARK: - JLActionSheetDelegate
    
    func JLActionSheetDelegateTableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.filterActionSheet?.dismiss()
        switch indexPath.row {
        case 0:
            self.orderType = .newest
        case 1:
            self.orderType = .answered
        case 2:
            self.orderType = .unanswered
        default:
            self.orderType = .newest
        }
        
        firstLoad = true
        loadObjects()
        // set filter label
        self.filterLabel.text = "\(self.orderType)".capitalizedString
    }
}

extension SLAskViewController {
    override func hasContent() -> Bool {
        if orderType == .newest {
            return self.questions.count > 0
        } else {
            return true
        }
    }
}
