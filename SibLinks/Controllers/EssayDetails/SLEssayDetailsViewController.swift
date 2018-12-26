//
//  SLEssayDetailsViewController.swift
//  SibLinks
//
//  Created by Jana on 10/6/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import QuickLook
import SDCAlertView
import Cartography
import Cosmos
import SwiftyJSON

enum EssayDetailType: Int {
    case Content = 0
    case EssayUploaded = 1
    case EssayStatus = 2
    case Comment = 3
    case EssayReviewed = 4
}
class SLEssayDetailsViewController: SLBaseViewController {

    static let nibName = "SLEssayDetailsViewController"
    static var controller: SLEssayDetailsViewController! {
        let controller = SLEssayDetailsViewController(nibName: SLEssayDetailsViewController.nibName, bundle: nil)
        return controller
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabbarBlurImageView: UIImageView!
    @IBOutlet weak var rateReplyStarConstraint: NSLayoutConstraint!
    @IBOutlet weak var starViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ratingView: CosmosView!
    
    var rateReplyStarConstraintValue: CGFloat = 0
    var starViewHeightValue: CGFloat = 0
    
    var essay: SLEssay?
    var rateValue: Int?
    var previewButton: LoadingButton?
    var previewActionSheet: JLActionSheet?
    let previewOptions = ["Preview Now", "Open files with other applications"]
    let quickLookController = QLPreviewController()
    var documentInteractionController = UIDocumentInteractionController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register
        self.tableView.registerNib(SLEssayDetailTableViewCell.nib(), forCellReuseIdentifier: SLEssayDetailTableViewCell.cellIdentifier())
        self.tableView.registerNib(SLEssayDownloadTableViewCell.nib(), forCellReuseIdentifier: SLEssayDownloadTableViewCell.cellIdentifier())
        self.tableView.registerNib(SLEssayStatusTableViewCell.nib(), forCellReuseIdentifier: SLEssayStatusTableViewCell.cellIdentifier())
        self.tableView.registerNib(SLBubbleAnswerTableViewCell.nib(), forCellReuseIdentifier: SLBubbleAnswerTableViewCell.cellIdentifier())
        
        getEssayDetail()
        
        quickLookController.dataSource = self
        quickLookController.delegate = self
        
        rateReplyStarConstraintValue = rateReplyStarConstraint.constant
        starViewHeightValue = starViewHeight.constant
        isShowRatingView(false)
        
        if let essayId = essay?.objectId {
            EssayRouter(endpoint: EssayEndpoint.CheckRateEssay(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, essayUploadId: essayId)).request { (result) in
                switch result {
                case .Success(let objects):
                    if let value = objects as? Int {
                        if value > 0 {
                            self.rateValue = value
                            self.ratingView.rating = Double(value)
                        }
                    }
                default:
                    print("Error")
                }
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update empty state frame equal super view
        loadingView?.frame = self.tableView.frame
        emptyView?.frame = self.tableView.frame
        errorView?.frame = self.tableView.frame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getEssayDetail() {
        if let essayId = essay?.objectId {
            loading = true
            startLoading(false, completion: nil)
            EssayRouter(endpoint: EssayEndpoint.GetEssay(essayId: essayId)).request(completion: { (result) in
                self.loading = false
                switch result {
                case .Success(let objects):
                    if let essayList = objects as? [SLEssay] {
                        if essayList.count > 0 {
                            self.essay = essayList[0]
                            if let type = self.essay?.status {
                                if type == EssayStatus.Reviewed.rawValue {
                                    self.isShowRatingView(true)
                                }
                            }
                            self.tableView.reloadData()
                        }
                    }
                    
                    self.endLoading(false, error: nil, completion: nil)
                    break
                default:
                    self.endLoading(false, error: Constants.RequestError, completion: nil)
                    break
                }
            })
        }
    }
}

extension SLEssayDetailsViewController: UITableViewDataSource {

    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if loading {
            return 0
        }
        
        if let essay = essay {
            if let type = essay.status {
                if type == EssayStatus.Reviewed.rawValue {
                    if essay.essayReviewed != nil {
                        return 5
                    } else {
                        return 4
                    }
                } else {
                    return 3
                }
            }
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case EssayDetailType.Content.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(SLEssayDetailTableViewCell.cellIdentifier())
            if let essayDetailsCell = cell as? SLEssayDetailTableViewCell {
                essayDetailsCell.setIndexPath(indexPath, sender: self)
                essayDetailsCell.configCellWithData(essay)
                return essayDetailsCell
            }
        case EssayDetailType.EssayUploaded.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(SLEssayDownloadTableViewCell.cellIdentifier())
            if let essayDownloadCell = cell as? SLEssayDownloadTableViewCell {
                essayDownloadCell.setIndexPath(indexPath, sender: self)
                essayDownloadCell.configCellWithData(essay)
                return essayDownloadCell
            }
        case EssayDetailType.EssayStatus.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(SLEssayStatusTableViewCell.cellIdentifier())
            if let essayStatusCell = cell as? SLEssayStatusTableViewCell {
                essayStatusCell.setIndexPath(indexPath, sender: self)
                essayStatusCell.configCellWithData(essay)
                return essayStatusCell
            }
        case EssayDetailType.Comment.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(SLBubbleAnswerTableViewCell.cellIdentifier())
            if let answerCell = cell as? SLBubbleAnswerTableViewCell {
                answerCell.setIndexPath(indexPath, sender: self)
                answerCell.configCellWithData(essay)
                return answerCell
            }
        case EssayDetailType.EssayReviewed.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(SLEssayDownloadTableViewCell.cellIdentifier())
            if let essayReviewCell = cell as? SLEssayDownloadTableViewCell {
                essayReviewCell.reviewed = true
                essayReviewCell.setIndexPath(indexPath, sender: self)
                essayReviewCell.configCellWithData(essay)
                return essayReviewCell
            }
        default:
            return UITableViewCell()
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

extension SLEssayDetailsViewController {
    
    // MARK: - Actions
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func ratingEssay(sender: AnyObject) {
        if rateValue > 0 {
            Constants.showAlert("SibLinks", message: "You have already rated it", actions:
                AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Default))
            return
        }
        
        let ratingView = CosmosView()
        ratingView.rating = 0
        ratingView.settings.filledColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
        ratingView.settings.filledBorderColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
        ratingView.settings.emptyBorderColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        
        let rateAlert = AlertController(title: "Rate Essay!", message: "How much do you like this answered?")
        let notNowAction = AlertAction(title: "Not Now", style: .Default, handler: nil)
        rateAlert.addAction(notNowAction)
        let noThanksAction = AlertAction(title: "Send", style: .Preferred) { (action) in
            if ratingView.rating > 0 {
                if let essayId = self.essay?.objectId {
                    let rateValue = Int(ratingView.rating)
                    EssayRouter(endpoint: EssayEndpoint.RateEssay(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, uploadEssayId: essayId, rating: rateValue)).request(completion: { (result) in
                        switch result {
                        case .Ok:
                            self.ratingView.rating = Double(rateValue)
                        default:
                            Constants.showAlert("SibLinks", message: "You cannot be rated at this time", actions:
                                AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Default))
                        }
                    })
                }
            } else {
                Constants.showAlert("SibLinks", message: "Star numbers must be greater than zero", actions:
                    AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Default))
            }
        }
        
        rateAlert.addAction(noThanksAction)
        
        let contentView = rateAlert.contentView
        contentView.addSubview(ratingView)
        constrain(ratingView) { view in
            view.centerX == view.superview!.centerX
            view.top == view.superview!.top
            view.bottom == view.superview!.bottom
        }
        
        rateAlert.present()
    }
    
    func previewEssay(sender: LoadingButton, indexPath: NSIndexPath) {
        self.previewButton = sender
        if sender.loading {
            return
        }
        
        switch indexPath.row {
        case EssayDetailType.EssayUploaded.rawValue:
            if let fileUrl = essay?.essay, let essayId = essay?.objectId, let essayName = essay?.fileName, let fileSize = essay?.fileSize {
                let pathExtension = essayName.pathExtension.characters.count > 0 ? essayName.pathExtension : "pdf"
                let fileName = "essay_\(essayId)_\(essayName)_\(fileSize).\(pathExtension)"
                let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                let essayFolder = documents.stringByAppendingString("/Essays/\(fileName)")
                if NSFileManager.defaultManager().fileExistsAtPath(essayFolder) {
                    previewActionSheet = JLActionSheet(delegate: self, dataSource: self)
                    previewActionSheet?.tableView.registerNib(SLFilterTableViewCell.nib(), forCellReuseIdentifier: SLFilterTableViewCell.cellIdentifier())
                    previewActionSheet?.tableView.tag = EssayDetailType.EssayUploaded.rawValue
                    previewActionSheet?.show()
                } else {
                    previewButton?.loading = true
                    APIManagement.sharedInstance.download(fileUrl, fileName: fileName, completionHandler: { (url, error) in
                        self.previewButton?.loading = false
                        if let url = url {
                            self.previewButton?.setTitle("  Preview", forState: .Normal)
                            self.previewButton?.setImage(UIImage(named: "preview")!, state: .Normal)
                            self.essay?.essayDownloaded = url
                        }
                    })
                }
            }
            break
        case EssayDetailType.EssayReviewed.rawValue:
            if let fileUrl = essay?.essayReviewed, let essayId = essay?.objectId, let essayName = essay?.fileReviewedName, let mentorId = essay?.mentor?.objectId, let fileSize = essay?.fileReviewedSize {
                let pathExtension = essayName.pathExtension.characters.count > 0 ? essayName.pathExtension : "pdf"
                let fileName = "essay_\(mentorId)_\(essayId)_\(essayName)_\(fileSize).\(pathExtension)"
                let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                let essayFolder = documents.stringByAppendingString("/Essays/\(fileName)")
                if NSFileManager.defaultManager().fileExistsAtPath(essayFolder) {
                    previewActionSheet = JLActionSheet(delegate: self, dataSource: self)
                    previewActionSheet?.tableView.registerNib(SLFilterTableViewCell.nib(), forCellReuseIdentifier: SLFilterTableViewCell.cellIdentifier())
                    previewActionSheet?.tableView.tag = EssayDetailType.EssayReviewed.rawValue
                    previewActionSheet?.show()
                } else {
                    previewButton?.loading = true
                    APIManagement.sharedInstance.download(fileUrl, fileName: fileName, completionHandler: { (url, error) in
                        self.previewButton?.loading = false
                        if let url = url {
                            self.previewButton?.setTitle("  Preview", forState: .Normal)
                            self.previewButton?.setImage(UIImage(named: "preview")!, state: .Normal)
                            self.essay?.essayReviewDownloaded = url
                            if QLPreviewController.canPreviewItem(url) {
                                self.quickLookController.reloadData()
                                self.presentViewController(self.quickLookController, animated: true, completion: nil)
                            }
                        }
                    })
                }
            }
            break
        default:
            break
        }
    }
}

extension SLEssayDetailsViewController: JLActionSheetDelegate {

    // MARK: - JLActionSheetDelegate
    
    func JLActionSheetDelegateTableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.previewActionSheet?.dismiss()
        
        switch indexPath.row {
        case 0:
            if tableView.tag == EssayDetailType.EssayReviewed.rawValue {
                if let fileUrl = essay?.essayReviewed, let essayId = essay?.objectId, let essayName = essay?.fileReviewedName, let mentorId = essay?.mentor?.objectId, let fileSize = essay?.fileReviewedSize {
                    let pathExtension = essayName.pathExtension.characters.count > 0 ? essayName.pathExtension : "pdf"
                    let fileName = "essay_\(mentorId)_\(essayId)_\(essayName)_\(fileSize).\(pathExtension)"
                    let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                    let essayFolder = documents.stringByAppendingString("/Essays/\(fileName)")
                    if NSFileManager.defaultManager().fileExistsAtPath(essayFolder) {
                        let url = NSURL(fileURLWithPath: essayFolder)
                        self.essay?.essayReviewDownloaded = url
                        if QLPreviewController.canPreviewItem(url) {
                            self.quickLookController.currentPreviewItemIndex = 1
                            self.quickLookController.reloadData()
                            self.presentViewController(self.quickLookController, animated: true, completion: nil)
                        }
                    } else {
                        previewButton?.loading = true
                        APIManagement.sharedInstance.download(fileUrl, fileName: fileName, completionHandler: { (url, error) in
                            self.previewButton?.loading = false
                            if let url = url {
                                self.previewButton?.setTitle("  Preview", forState: .Normal)
                                self.previewButton?.setImage(UIImage(named: "preview")!, state: .Normal)
                                self.essay?.essayReviewDownloaded = url
                                if QLPreviewController.canPreviewItem(url) {
                                    self.quickLookController.reloadData()
                                    self.presentViewController(self.quickLookController, animated: true, completion: nil)
                                }
                            }
                        })
                    }
                }
            } else {
                if let fileUrl = essay?.essay, let essayId = essay?.objectId, let essayName = essay?.fileName, let fileSize = essay?.fileSize {
                    let pathExtension = essayName.pathExtension.characters.count > 0 ? essayName.pathExtension : "pdf"
                    let fileName = "essay_\(essayId)_\(essayName)_\(fileSize).\(pathExtension)"
                    let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                    let essayFolder = documents.stringByAppendingString("/Essays/\(fileName)")
                    if NSFileManager.defaultManager().fileExistsAtPath(essayFolder) {
                        let url = NSURL(fileURLWithPath: essayFolder)
                        self.essay?.essayDownloaded = url
                        if QLPreviewController.canPreviewItem(url) {
                            self.quickLookController.currentPreviewItemIndex = 0
                            self.quickLookController.reloadData()
                            self.presentViewController(self.quickLookController, animated: true, completion: nil)
                        }
                    } else {
                        previewButton?.loading = true
                        APIManagement.sharedInstance.download(fileUrl, fileName: fileName, completionHandler: { (url, error) in
                            self.previewButton?.loading = false
                            if let url = url {
                                self.previewButton?.setTitle("  Preview", forState: .Normal)
                                self.previewButton?.setImage(UIImage(named: "preview")!, state: .Normal)
                                self.essay?.essayDownloaded = url
                                if QLPreviewController.canPreviewItem(url) {
                                    self.quickLookController.reloadData()
                                    self.presentViewController(self.quickLookController, animated: true, completion: nil)
                                }
                            }
                        })
                    }
                }
            }
            
        case 1:
            if tableView.tag == EssayDetailType.EssayReviewed.rawValue {
                if let fileUrl = essay?.essayReviewed, let essayId = essay?.objectId, let essayName = essay?.fileReviewedName, let mentorId = essay?.mentor?.objectId, let fileSize = essay?.fileReviewedSize {
                    let pathExtension = essayName.pathExtension.characters.count > 0 ? essayName.pathExtension : "pdf"
                    let fileName = "essay_\(mentorId)_\(essayId)_\(essayName)_\(fileSize).\(pathExtension)"
                    let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                    let essayFolder = documents.stringByAppendingString("/Essays/\(fileName)")
                    if NSFileManager.defaultManager().fileExistsAtPath(essayFolder) {
                        let url = NSURL(fileURLWithPath: essayFolder)
                        self.essay?.essayReviewDownloaded = url
                        documentInteractionController = UIDocumentInteractionController(URL: url)
                        documentInteractionController.presentOpenInMenuFromRect(CGRectZero, inView: view, animated: true)
                    } else {
                        previewButton?.loading = true
                        APIManagement.sharedInstance.download(fileUrl, fileName: fileName, completionHandler: { (url, error) in
                            self.previewButton?.loading = false
                            if let url = url {
                                self.previewButton?.setTitle("  Preview", forState: .Normal)
                                self.previewButton?.setImage(UIImage(named: "preview")!, state: .Normal)
                                self.essay?.essayReviewDownloaded = url
                                if QLPreviewController.canPreviewItem(url) {
                                    self.quickLookController.reloadData()
                                    self.presentViewController(self.quickLookController, animated: true, completion: nil)
                                }
                            }
                        })
                    }
                }
            } else {
                if let fileUrl = essay?.essay, let essayId = essay?.objectId, let essayName = essay?.fileName, let fileSize = essay?.fileSize {
                    let pathExtension = essayName.pathExtension.characters.count > 0 ? essayName.pathExtension : "pdf"
                    let fileName = "essay_\(essayId)_\(essayName)_\(fileSize).\(pathExtension)"
                    let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                    let essayFolder = documents.stringByAppendingString("/Essays/\(fileName)")
                    if NSFileManager.defaultManager().fileExistsAtPath(essayFolder) {
                        let url = NSURL(fileURLWithPath: essayFolder)
                        self.essay?.essayDownloaded = url
                        documentInteractionController = UIDocumentInteractionController(URL: url)
                        documentInteractionController.presentOpenInMenuFromRect(CGRectZero, inView: view, animated: true)
                    } else {
                        previewButton?.loading = true
                        APIManagement.sharedInstance.download(fileUrl, fileName: fileName, completionHandler: { (url, error) in
                            self.previewButton?.loading = false
                            if let url = url {
                                self.previewButton?.setTitle("  Preview", forState: .Normal)
                                self.previewButton?.setImage(UIImage(named: "preview")!, state: .Normal)
                                self.essay?.essayDownloaded = url
                                self.documentInteractionController = UIDocumentInteractionController(URL: url)
                                self.documentInteractionController.presentOpenInMenuFromRect(CGRectZero, inView: self.view, animated: true)
                            }
                        })
                    }
                }
            }
        default:
            return
        }
    }
}

extension SLEssayDetailsViewController: JLActionSheetDataSource {
    
    // MARK: - JLActionSheetDataSource
    func JLActionSheetDataSourceTableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previewOptions.count
    }
    
    func JLActionSheetDataSourceTableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLFilterTableViewCell.cellIdentifier())
        
        if let filterCell = cell as? SLFilterTableViewCell {
            filterCell.filterTitleLabel.text = previewOptions[indexPath.row]
            return filterCell
        }
        
        return UITableViewCell()
    }
    
    func JLActionSheetDataSourceTableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func JLActionSheetDataSourceHeightOfContentView() -> CGFloat {
        return 100
    }
}

extension SLEssayDetailsViewController {
    override func hasContent() -> Bool {
        return !loading
    }
}

extension SLEssayDetailsViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        if let type = essay?.status {
            if type == EssayStatus.Reviewed.rawValue {
                var items = 0
                if essay?.essayDownloaded != nil {
                    items += 1
                }
                
                if essay?.essayReviewDownloaded != nil {
                    items += 1
                }
                
                return items
            } else {
                if essay?.essayDownloaded != nil {
                    return 1
                }
            }
        }
        
        return 0
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        if let type = essay?.status {
            if type == EssayStatus.Reviewed.rawValue {
                if index == 0 {
                    if essay?.essayDownloaded != nil {
                        return essayPreviewItem()
                    } else if essay?.essayReviewDownloaded != nil {
                        return essayReviewedPreviewItem()
                    }
                }

                if index == 1 {
                    if essay?.essayReviewDownloaded != nil {
                        return essayReviewedPreviewItem()
                    }
                }
            } else {
                if essay?.essayDownloaded != nil {
                    return essayPreviewItem()
                }
            }
        }
        
        return NSURL()
    }
    
    private func essayPreviewItem() -> QLPreviewItem {
        let previewItem = PreviewItem()
        if let file = essay?.essayDownloaded {
            previewItem.filePath = file
        }
        
        if let title = essay?.fileName {
            previewItem.title = title
        }
        
        return previewItem
    }
    
    private func essayReviewedPreviewItem() -> QLPreviewItem {
        let previewItem = PreviewItem()
        if let file = essay?.essayReviewDownloaded {
            previewItem.filePath = file
        }
        
        if let title = essay?.fileReviewedName {
            previewItem.title = title
        }
        
        return previewItem
    }
}

extension SLEssayDetailsViewController {
    
    // MARK: - RatingView
    func isShowRatingView(value: Bool) {
        if value {
            rateReplyStarConstraint.constant = rateReplyStarConstraintValue
            starViewHeight.constant = starViewHeightValue
            tabbarBlurImageView.hidden = false
        } else {
            rateReplyStarConstraint.constant = 0
            starViewHeight.constant = 0
            tabbarBlurImageView.hidden = true
        }
    }
}

extension SLEssayDetailsViewController: QLPreviewControllerDelegate {
    func previewControllerWillDismiss(controller: QLPreviewController) {
        print("The Preview Controller will be dismissed")
    }
    
    func previewControllerDidDismiss(controller: QLPreviewController) {
        print("The Preview Controller has been dismissed.")
    }
    
    func previewController(controller: QLPreviewController, shouldOpenURL url: NSURL, forPreviewItem item: QLPreviewItem) -> Bool {
        if let essayUrl = essay?.essayDownloaded {
            if essayUrl == url {
                return true
            }
        } else if let essayUrl = essay?.essayReviewDownloaded {
            if essayUrl == url {
                return true
            }
        } else {
            print("Will not open URL \(url.absoluteString)")
        }
        
        return false
    }
}

class PreviewItem: NSObject, QLPreviewItem {
    
    var filePath: NSURL?
    var title: String?
    
    var previewItemURL: NSURL {
        if let filePath = filePath {
            return filePath
        }
        
        return NSURL()
    }
    
    var previewItemTitle: String? {
        if let title = title {
            return title
        }
        return nil
    }
    
}
