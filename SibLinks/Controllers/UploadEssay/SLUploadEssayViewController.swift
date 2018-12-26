//
//  SLUploadEssayViewController.swift
//  SibLinks
//
//  Created by Jana on 10/6/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import SDCAlertView
import QuickLook

enum UploadEssayActionSheetType {
    case University
    case Faculty
    case Upload
}

class SLUploadEssayViewController: SLBaseViewController {
    
    static let uploadEssayViewController = "SLUploadEssayViewControllerID"
    static var controller: SLUploadEssayViewController! {
        let controller = UIStoryboard(name: Constants.UPLOAD_ESSAY_STORYBOARD, bundle: nil).instantiateViewControllerWithIdentifier(SLUploadEssayViewController.uploadEssayViewController) as! SLUploadEssayViewController
        return controller
    }

    @IBOutlet weak var tableView: UITableView!
    
    var essay: SLEssay?
    var actionSheetType: UploadEssayActionSheetType?
    var currentCell: SLEssayInfoTableViewCell?
    
    var universityArray = Constants.appDelegate().university
    var facultyArray = Constants.appDelegate().faculty
    var universitySelectedIndexPath: NSIndexPath?
    var facultySelectedIndexPath: NSIndexPath?
    var currentActionSheet: JLActionSheet?
    var school: SLSchool?
    var subject: SLMajor?
    var localUrlFile: NSURL?
    let quickLookController = QLPreviewController()
    
    var previewButton: LoadingButton?
    let previewOptions1 = ["Update Essay", "Download Essay"]
    let previewOptions2 = ["Update Essay", "Preview Now", "Open files with other applications"]
    var documentInteractionController = UIDocumentInteractionController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerNib(SLEssayDownloadTableViewCell.nib(), forCellReuseIdentifier: SLEssayDownloadTableViewCell.cellIdentifier())
        quickLookController.dataSource = self
        quickLookController.delegate = self
        getEssayDetail()
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
                            self.updateEssaySchool()
                            self.updateEssayMajor()
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
    
    func updateEssaySchool() {
        if let school = essay?.school {
            for university in universityArray {
                if school.objectId == university.objectId {
                    school.name = university.name
                    self.school = school
                    break
                }
            }
        }
    }
    
    func updateEssayMajor() {
        if let subject = essay?.major {
            for major in facultyArray {
                if subject.objectId == major.objectId {
                    subject.name = major.name
                    self.subject = subject
                    break
                }
            }
        }
    }
}

extension SLUploadEssayViewController {
    
    override func configView() {
        super.configView()
        
        self.navigationItem.title = "Upload Essay"
        self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left)])
        
        // Register
        self.tableView.registerNib(SLEssayInfoTableViewCell.nib(), forCellReuseIdentifier: SLEssayInfoTableViewCell.cellIdentifier())
        self.tableView.registerNib(SLEssayAttachTableViewCell.nib(), forCellReuseIdentifier: SLEssayAttachTableViewCell.cellIdentifier())
        self.tableView.registerNib(SLEssayAddFileTableViewCell.nib(), forCellReuseIdentifier: SLEssayAddFileTableViewCell.cellIdentifier())
        self.tableView.registerNib(SLEssaySubmitTableViewCell.nib(), forCellReuseIdentifier: SLEssaySubmitTableViewCell.cellIdentifier())
        
        self.tableView.tableFooterView = UIView()
        
        let touchOnScreen = UITapGestureRecognizer(target: self, action: #selector(self.touchOnScreenAction))
        touchOnScreen.cancelsTouchesInView = false
        self.view.addGestureRecognizer(touchOnScreen)
    }
    
}

extension SLUploadEssayViewController {
    
    // MARK: - Actions
    
    func touchOnScreenAction() {
        UIApplication.sharedApplication().sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, forEvent: nil)
        self.view.endEditing(true)
    }
    
    func previewEssay(sender: LoadingButton, indexPath: NSIndexPath) {
        self.previewButton = sender
        if sender.loading {
            return
        }
        
        if let essayId = essay?.objectId, let essayName = essay?.fileName, let fileSize = essay?.fileSize {
            let pathExtension = essayName.pathExtension.characters.count > 0 ? essayName.pathExtension : "pdf"
            let fileName = "essay_\(essayId)_\(essayName)_\(fileSize).\(pathExtension)"
            let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            let essayFolder = documents.stringByAppendingString("/Essays/\(fileName)")
            if NSFileManager.defaultManager().fileExistsAtPath(essayFolder) {
                let url = NSURL(fileURLWithPath: essayFolder)
                self.essay?.essayDownloaded = url
            }
        }

        self.actionSheetType = .Upload
        currentActionSheet = JLActionSheet(delegate: self, dataSource: self)
        currentActionSheet?.tableView.registerNib(SLFilterTableViewCell.nib(), forCellReuseIdentifier: SLFilterTableViewCell.cellIdentifier())
        currentActionSheet?.show()
    }
    
    func downloadEssay() {
        if let fileUrl = essay?.essay, let essayId = essay?.objectId, let essayName = essay?.fileName, let fileSize = essay?.fileSize {
            let pathExtension = essayName.pathExtension.characters.count > 0 ? essayName.pathExtension : "pdf"
            let fileName = "essay_\(essayId)_\(essayName)_\(fileSize).\(pathExtension)"
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
}

extension SLUploadEssayViewController: UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(SLEssayInfoTableViewCell.cellIdentifier())
            if let essayInfoCell = cell as? SLEssayInfoTableViewCell {
                essayInfoCell.setIndexPath(indexPath, sender: self)
                essayInfoCell.selectionStyle = .None
                essayInfoCell.configCellWithData(essay)
                
                return essayInfoCell
            }
            
        case 1:
            if let file = self.localUrlFile {
                let cell = tableView.dequeueReusableCellWithIdentifier(SLEssayAttachTableViewCell.cellIdentifier())
                if let essayAttachCell = cell as? SLEssayAttachTableViewCell {
                    essayAttachCell.setIndexPath(indexPath, sender: self)
                    essayAttachCell.selectionStyle = .None
                    let urlString = NSURL(fileURLWithPath: "\(file)")
                    essayAttachCell.fileNameLabel.text = urlString.lastPathComponent?.ped_decodeURIComponent()
                    
                    do {
                        let attr: NSDictionary = try NSFileManager.defaultManager().attributesOfItemAtPath(file.path!)
                        essayAttachCell.fileSizeLabel.text = NSByteCountFormatter.stringFromByteCount(Int64(attr.fileSize()), countStyle: .Decimal)
                    } catch {}
                    
                    return essayAttachCell
                }
            } else if essay != nil {
                let cell = tableView.dequeueReusableCellWithIdentifier(SLEssayDownloadTableViewCell.cellIdentifier())
                cell?.selectionStyle = .None
                if let essayDownloadCell = cell as? SLEssayDownloadTableViewCell {
                    essayDownloadCell.setIndexPath(indexPath, sender: self)
                    essayDownloadCell.configCellWithData(essay)
                    return essayDownloadCell
                }
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(SLEssayAddFileTableViewCell.cellIdentifier())
                if let addFileCell = cell as? SLEssayAddFileTableViewCell {
                    addFileCell.setIndexPath(indexPath, sender: self)
                    return addFileCell
                }
            }
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier(SLEssaySubmitTableViewCell.cellIdentifier())
            if let submitCell = cell as? SLEssaySubmitTableViewCell {
                submitCell.setIndexPath(indexPath, sender: self)
                submitCell.selectionStyle = .None
                return submitCell
            }
            
        default:
            return UITableViewCell()
        }
        
        return UITableViewCell()
    }
}

extension SLUploadEssayViewController: UITableViewDelegate {
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            break
        case 1:
            if let file = self.localUrlFile {
                if QLPreviewController.canPreviewItem(file) {
                    quickLookController.reloadData()
                    self.presentViewController(quickLookController, animated: true, completion: nil)
                }
            }
        default:
            break
        }
    }
}

extension SLUploadEssayViewController: SLEssayInfoTableViewCellDelegate {
    
    // MARK: - SLEssayInfoTableViewCellDelegate
    
    func chooseUniversityAction(button: AnyObject, currentCell: SLEssayInfoTableViewCell) {
        self.touchOnScreenAction()
        self.actionSheetType = .University
        self.currentCell = currentCell
        
        self.currentActionSheet = JLActionSheet(delegate: self, dataSource: self)
        self.currentActionSheet?.tableView.registerNib(SLMultipleSelectionTableViewCell.nib(), forCellReuseIdentifier: SLMultipleSelectionTableViewCell.cellIdentifier())
        self.currentActionSheet?.show()
    }
    
    func chooseFalcultyAction(button: AnyObject, currentCell: SLEssayInfoTableViewCell) {
        self.touchOnScreenAction()
        self.actionSheetType = .Faculty
        self.currentCell = currentCell
        
        self.currentActionSheet = JLActionSheet(delegate: self, dataSource: self)
        self.currentActionSheet?.tableView.registerNib(SLMultipleSelectionTableViewCell.nib(), forCellReuseIdentifier: SLMultipleSelectionTableViewCell.cellIdentifier())
        self.currentActionSheet?.show()
    }
    
}

extension SLUploadEssayViewController: SLEssayAttachTableViewCellDelegate {
    
    // MARK: - SLEssayAttachTableViewCellDelegate
    
    func removeAttachFile(cell: SLEssayAttachTableViewCell) {
        self.localUrlFile = nil
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
    }
    
}

extension SLUploadEssayViewController: SLEssayAddFileTableViewCellDelegate {
    
    // MARK: - SLEssayAttachTableViewCellDelegate
    
    func addAttachFileAction() {
        let documentPicker = DocumentPickerViewController(documentTypes: ["com.adobe.pdf", "com.microsoft.word.doc", "com.microsoft.excel.xls", "org.openxmlformats.wordprocessingml.document", "public.xml", "org.openxmlformats.spreadsheetml.sheet", "public.plain-text"], inMode: .Import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .FormSheet
        self.presentViewController(documentPicker, animated: true, completion: nil)
    }
    
}

extension SLUploadEssayViewController: SLEssaySubmitTableViewCellDelegate {
    
    // MARK: - SLEssaySubmitTableViewCellDelegate
    func submitAction(button: AnyObject) {
        guard let submitButton = button as? LoadingButton else {
            return
        }
        
        if submitButton.loading {
            return
        }
        
        var title = ""
        var content = ""
        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? SLEssayInfoTableViewCell {
            title = cell.essayTitleTextField.text!
            content = cell.essayContentTextView.text
        }
        
        if title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count == 0 {
            Constants.showAlert("SibLinks", message: "Please enter your essay title!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
            return
        }
        
        if content.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 1000 {
            Constants.showAlert("SibLinks", message: "Your essay title must be less than 1000 characters!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
            return
        }
        
        if content.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count == 0 {
            Constants.showAlert("SibLinks", message: "Please enter your essay content!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
            return
        }
        
        if content.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 1000 {
            Constants.showAlert("SibLinks", message: "Your essay content must be less than 1000 characters!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
            return
        }
        
        if school == nil || school?.objectId == 0 {
            Constants.showAlert("SibLinks", message: "Please choose university!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
            return
        }
        
        if subject == nil || subject?.objectId == 0 {
            Constants.showAlert("SibLinks", message: "Please choose faculty!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
            return
        }
        
        if essay != nil {
            if let fileUrl = self.localUrlFile {
                do {
                    let attributesOfItem = try NSFileManager.defaultManager().attributesOfItemAtPath(fileUrl.path ?? "")
                    if let fileSize = attributesOfItem[NSFileSize]?.longLongValue {
                        guard fileSize < 5 * 1024 * 1024 else {
                            Constants.showAlert("SibLinks", message: "Attachments must be less than 5MB!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
                            return
                        }
                    }
                } catch {
                    self.localUrlFile = nil
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
                    Constants.showAlert("SibLinks", message: "Attachment is removed. Please try again later!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
                    return
                }
            }
            
            var file: NSData?
            var fileName: String?
            
            if let url = self.localUrlFile {
                let urlString = NSURL(fileURLWithPath: "\(url)")
                fileName = urlString.lastPathComponent?.ped_decodeURIComponent()
                file = NSData(contentsOfURL: url)
            }
            
            submitButton.loading = true
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            submitButton.setTitle("Submitting", forState: .Normal)
            // Update
            EssayRouter(endpoint: EssayEndpoint.UpdateEssay(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, essayId: (essay?.objectId)!,title: title, content: content, majorId: (subject?.objectId)!, schoolId: (school?.objectId)!, fileName: fileName, file: file)).request(completion: { (result) in
                submitButton.setTitle("Submit", forState: .Normal)
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                switch result {
                case .Success(let status):
                    if let status = status as? Bool {
                        if status {
                            submitButton.loading = false
                            self.navigationController?.popViewControllerAnimated(true)
                            NSNotificationCenter.defaultCenter().postNotificationName(Constants.UPLOAD_ESSAY, object: true)
                            return
                        }
                    }
                    
                    submitButton.loading = false
                    Constants.showAlert("SibLinks", message: "Opps, error", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
                default:
                    submitButton.loading = false
                    Constants.showAlert("SibLinks", message: "Opps, error", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
                }
            })
        } else {
            guard let fileUrl = self.localUrlFile else {
                Constants.showAlert("SibLinks", message: "Please select essay to upload!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
                return
            }
            
            do {
                let attributesOfItem = try NSFileManager.defaultManager().attributesOfItemAtPath(fileUrl.path ?? "")
                if let fileSize = attributesOfItem[NSFileSize]?.longLongValue {
                    guard fileSize < 5 * 1024 * 1024 else {
                        Constants.showAlert("SibLinks", message: "Attachments must be less than 5MB!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
                        return
                    }
                    
                    submitButton.loading = true
                    UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                    submitButton.setTitle("Submitting", forState: .Normal)
                    if let data = NSData(contentsOfURL: fileUrl), let file = self.localUrlFile {
                        let urlString = NSURL(fileURLWithPath: "\(file)")
                        let fileName = urlString.lastPathComponent?.ped_decodeURIComponent()
                        EssayRouter(endpoint: EssayEndpoint.UploadEssay(userId: (SLUserViewModel.sharedInstance.currentUser?.userId)!, title: title, content: content, majorId: (subject?.objectId)!, schoolId: (school?.objectId)!, fileName: fileName!, file: data)).request(completion: { (result) in
                            submitButton.setTitle("Submit", forState: .Normal)
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            switch result {
                            case .Success(let status):
                                if let status = status as? Bool {
                                    if status {
                                        submitButton.loading = false
                                        self.navigationController?.popViewControllerAnimated(true)
                                        NSNotificationCenter.defaultCenter().postNotificationName(Constants.UPLOAD_ESSAY, object: true)
                                        return
                                    }
                                }
                                
                                submitButton.loading = false
                                Constants.showAlert("SibLinks", message: "Opps, error", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
                            default:
                                submitButton.loading = false
                                Constants.showAlert("SibLinks", message: "Opps, error", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
                            }
                        })
                    }
                }
            } catch {
                self.localUrlFile = nil
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
                Constants.showAlert("SibLinks", message: "Attachment is removed. Please try again later!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
                return
            }
        }
    }
}

extension SLUploadEssayViewController: JLActionSheetDataSource {
    
    // MARK: - JLActionSheetDataSource
    
    func JLActionSheetDataSourceTableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.actionSheetType! {
        case .University:
            return self.universityArray.count
        case .Faculty:
            return self.facultyArray.count
        case .Upload:
            if self.essay?.essayDownloaded != nil {
                return previewOptions2.count
            } else {
                return previewOptions1.count
            }
        }
    }
    
    func JLActionSheetDataSourceTableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SLMultipleSelectionTableViewCell.cellIdentifier())
        
        if self.actionSheetType == .Upload {
            let filterCell = tableView.dequeueReusableCellWithIdentifier(SLFilterTableViewCell.cellIdentifier(), forIndexPath: indexPath) as! SLFilterTableViewCell
            if self.essay?.essayDownloaded != nil {
                filterCell.filterTitleLabel.text = previewOptions2[indexPath.row]
            } else {
                filterCell.filterTitleLabel.text = previewOptions1[indexPath.row]
            }

            return filterCell
        } else {
            if let multipleSelectionCell = cell as? SLMultipleSelectionTableViewCell {
                switch self.actionSheetType! {
                case .University:
                    let school = self.universityArray[indexPath.row]
                    multipleSelectionCell.multipleSelectionTitleLabel.text = school.name
                    if (self.universitySelectedIndexPath == indexPath) {
                        multipleSelectionCell.multipleSelectionMarkImageView.hidden = false
                    } else {
                        multipleSelectionCell.multipleSelectionMarkImageView.hidden = true
                    }
                case .Faculty:
                    let subject = self.facultyArray[indexPath.row]
                    multipleSelectionCell.multipleSelectionTitleLabel.text = subject.name
                    if (self.facultySelectedIndexPath == indexPath) {
                        multipleSelectionCell.multipleSelectionMarkImageView.hidden = false
                    } else {
                        multipleSelectionCell.multipleSelectionMarkImageView.hidden = true
                    }
                default:
                    break
                }
                return multipleSelectionCell
            }
        }
        
        return UITableViewCell()
    }
    
    func JLActionSheetDataSourceTableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func JLActionSheetDataSourceHeightOfContentView() -> CGFloat {
        switch self.actionSheetType! {
        case .University:
            if self.universityArray.count > 3 {
                return 200
            } else {
                return 50 * CGFloat(self.universityArray.count)
            }
        case .Faculty:
            if self.facultyArray.count > 3 {
                return 200
            } else {
                return 50 * CGFloat(self.facultyArray.count)
            }
        case .Upload:
            if self.essay?.essayDownloaded != nil {
                return 150
            } else {
                return 100
            }
        }
    }
    
}

extension SLUploadEssayViewController: JLActionSheetDelegate {
    
    // MARK: - JLActionSheetDelegate
    
    func JLActionSheetDelegateTableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.currentActionSheet?.dismiss()
        switch self.actionSheetType! {
        case .University:
            self.school = self.universityArray[indexPath.row]
            self.currentCell?.setUniversity(self.school?.name ?? "")
            self.universitySelectedIndexPath = indexPath
            
        case .Faculty:
            self.subject = self.facultyArray[indexPath.row]
            self.currentCell?.setFuculty(self.subject?.name ?? "")
            self.facultySelectedIndexPath = indexPath
            
        case .Upload:
            if self.essay?.essayDownloaded != nil {
                switch indexPath.row {
                case 0: // indexPath: 0 - Change essay
                    self.addAttachFileAction()
                    break
                case 1: // indexPath: 1 - Preview
                    self.quickLookController.reloadData()
                    self.presentViewController(self.quickLookController, animated: true, completion: nil)
                    break
                case 2: // indexPath: 2 - Open with app
                    if let url = essay?.essayDownloaded {
                        documentInteractionController = UIDocumentInteractionController(URL: url)
                        documentInteractionController.presentOpenInMenuFromRect(CGRectZero, inView: view, animated: true)
                    }
                    break
                default:
                    break
                }
            } else {
                switch indexPath.row {
                case 0: // indexPath: 0 - Change essay
                    self.addAttachFileAction()
                    break
                case 1: // indexPath: 1 - Download
                    self.downloadEssay()
                    break
                default:
                    break
                }
            }
        }
        
        self.actionSheetType = nil
        self.currentCell = nil
    }
}

extension SLUploadEssayViewController: UIDocumentPickerDelegate {
    
    // MARK: - UIDocumentPickerDelegate
    
    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        self.localUrlFile = url
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
    }
    
    func documentPickerWasCancelled(controller: UIDocumentPickerViewController) {
    
    }
}

extension SLUploadEssayViewController {
    
    // MARK: - Convert file size
    
    
}

extension SLUploadEssayViewController: QLPreviewControllerDataSource {
    
    // MARK: - QLPreviewControllerDataSource
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        if self.localUrlFile != nil || self.essay?.essayDownloaded != nil {
            return 1
        }
        
        return 0
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        if let file = self.localUrlFile {
            return file
        } else if let file = self.essay?.essayDownloaded {
            return file
        }
        
        return NSURL()
    }
}

extension SLUploadEssayViewController: QLPreviewControllerDelegate {
    func previewControllerWillDismiss(controller: QLPreviewController) {
        print("The Preview Controller will be dismissed")
    }
    
    func previewControllerDidDismiss(controller: QLPreviewController) {
        print("The Preview Controller has been dismissed.")
    }
    
    func previewController(controller: QLPreviewController, shouldOpenURL url: NSURL, forPreviewItem item: QLPreviewItem) -> Bool {
        if let file = self.localUrlFile {
            if item as! NSURL == file {
                return true
            }
        } else if let file = self.essay?.essayDownloaded {
            if item as! NSURL == file {
                return true
            }
        }
        
        else {
            print("Will not open URL \(url.absoluteString)")
        }
        
        return false
    }
}

extension SLUploadEssayViewController {
    override func hasContent() -> Bool {
        return !loading
    }
}

class DocumentPickerViewController: UIDocumentPickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: .Default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().translucent = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        Constants.appDelegate().customizeUIAppearance()
    }
}
