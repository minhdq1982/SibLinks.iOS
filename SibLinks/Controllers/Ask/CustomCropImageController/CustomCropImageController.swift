//
//  CustomCropImageController.swift
//  SibLinks
//
//  Created by Thuan on 9/16/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import SDCAlertView
import IBAnimatable
import Kingfisher

let heightTableViewSubject = 6 * 44
let duration = 0.3
let photoSize: CGFloat = 40
let placeholder = "Enter your question".localized

class CustomCropImageController: SLBaseViewController, UITextViewDelegate {
    
    var question: SLQuestion?
    var image: UIImage?
    var photos: [UIImage] = []
    var originPhotos = [UIImage]()
    var cropViewController: TOCropViewController?
    var openTblSubject = false
    var indexPhoto = 0
    var oldIndexPhoto = 0
    lazy var categories: [SLCategory] = {
        return Constants.appDelegate().categories
    }()
    var category: SLCategory?
    var opaque: UIView?
    private var addQuestion = false
    private var editedImages = [String]()
    var keyboardVisible = false
    lazy var tapInBlur: UITapGestureRecognizer = self.createTapInView()
    lazy var tapInNavigation: UITapGestureRecognizer = self.createTapInView()
    private func createTapInView() -> UITapGestureRecognizer {
        let tapInBlur = UITapGestureRecognizer()
        tapInBlur.addTarget(self, action: #selector(self.tapInBlurView))
        return tapInBlur
    }
    
    @IBOutlet weak var sendButton: LoadingButton! {
        didSet {
            sendButton.setActivityIndicatorStyle(.Gray, state: .Normal)
        }
    }
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var pickSubjectView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var enterQuestionTextView: UITextView!
    @IBOutlet weak var addMoreButton: LoadingButton!  {
        didSet {
            addMoreButton.setActivityIndicatorStyle(.Gray, state: .Normal)
        }
    }
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var imageBrowser: UIView!
    @IBOutlet weak var heightTableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewEnterQuestionConstraint: NSLayoutConstraint!
    
    lazy var navigationBlurView: UIView = {
        let navigationBlurView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 64))
        navigationBlurView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        Constants.appDelegate().window?.addSubview(navigationBlurView)
        return navigationBlurView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        self.tableView.registerNib(PickSubjectCell.nib(), forCellReuseIdentifier: PickSubjectCell.cellIdentifier())
        
        self.navigationController?.navigationBarHidden = false
        self.title = "Ask a question".localized
        self.navigationBarButtonItems([(ItemType.Back, ItemPosition.Left)])
        
        self.initView()
        self.initViewGesture()
        self.registerForKeyboardNotifications()
        
        self.fetchQuestionPhotos()
        interactiveViewArray = [self.addMoreButton, enterQuestionTextView]
        self.tableView.reloadData()
        
        self.blurView.addGestureRecognizer(self.tapInBlur)
        self.navigationBlurView.addGestureRecognizer(self.tapInNavigation)
        self.navigationBlurView.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.initCropView()
        self.initGalleryView()
        self.tableView.reloadData()
    }
    
    func tapInBlurView() {
        self.blurView.hidden = true
        self.navigationBlurView.hidden = true
        if keyboardVisible {
            self.enterQuestionTextView.resignFirstResponder()
        } else {
            self.pickSubject(nil)
        }
    }
    
}

extension CustomCropImageController {
    
    // MARK: - Actions
    
    @IBAction func addQuestion(sender: AnyObject) {
        if photos.count == 0 {
            self.postQuestionAPI([])
            return
        }
        
        // FIXME: Don't understand how to check it?
//        if self.indexPhoto == self.oldIndexPhoto {
//            addQuestion = true
//            cropViewController?.toolbar.doneButtonTapped!()
//            return
//        }
        
        self.postQuestionAPI(self.photos as [UIImage])
    }
    
    @IBAction func resetAction(sender: AnyObject) {
        if indexPhoto < self.originPhotos.count {
            self.image = self.originPhotos[indexPhoto]
            if let imageIdentifier = self.originPhotos[indexPhoto].accessibilityIdentifier {
                if editedImages.contains(imageIdentifier) {
                    editedImages.removeObject(imageIdentifier)
                }
            }
            
            self.initCropView()
        }
    }
    
    @IBAction func removeAction(sender: AnyObject) {
        if photos.count > 0 {
            
            //  TODO: Store remove image's url to question.editingImages
            if let imageIdentifier = photos[indexPhoto].accessibilityIdentifier {
                if !editedImages.contains(imageIdentifier) {
                    editedImages.append(imageIdentifier)
                }
            }
            
            photos.removeAtIndex(indexPhoto)
            originPhotos.removeAtIndex(indexPhoto)
            
            if photos.count == 0 {
                self.image = nil
            } else {
                self.image = photos[0]
            }
            
            self.indexPhoto = 0
            self.oldIndexPhoto = 0
            self.initCropView()
            self.initGalleryView()
        }
    }
    
    @IBAction func rotateAction(sender: AnyObject) {
        cropViewController?.toolbar.rotateClockwiseButtonTapped!()
    }
    
}

extension CustomCropImageController {
    
    // MARK: - Get categories
    func postQuestionAPI(imagesCropped: [UIImage]){
        if sendButton.loading == true {
            return
        }
        
        if category == nil {
            Constants.showAlert("SibLinks", message: "Please choose subject!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
            return
        }
        
        let title = self.enterQuestionTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if title.characters.count == 0 {
            Constants.showAlert("SibLinks", message: "Please enter your question!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
            return
        }
        
        guard self.enterQuestionTextView.text.characters.count < 1000 else {
            Constants.showAlert("SibLinks", message: "Your question must be less than 1000 characters!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
            return
        }
        
        addQuestion = false
        
        sendButton.loading = true
        setEnableInteractiveView(false)
        if let question = question {
            // Check if question do not have local id then generate a new one
            if !(question.localId > 0) {
                // In case editing live question, but still not have local ID
                question.localId = SLLocalDataManager.sharedInstance.generateLocalQuestionId()
            }
            
            // Update question info
            question.category?.objectId = self.category!.objectId;
            question.category?.subject = self.category!.subject
            question.title = self.enterQuestionTextView.text
            question.editingImages = self.editedImages
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                // Save editing question to local
                SLLocalDataManager.sharedInstance.saveQuestion(question, images: imagesCropped)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // Post question did edited notification
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.POST_QUESTION_SEND, object: question)
                    self.sendButton.loading = false
                    self.setEnableInteractiveView(true)
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    SLTrackingEvent.sharedInstance.sendAskAQuestionEvent(SLTrackingEvent.kSLAskAQuestionScreen)
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.PUSH_POST_ASK_SUCCESS, object: nil)
                })
            })
        } else {
            // Create new question
            let question = SLQuestion()
            question.student = SLUser()
            question.student?.objectId = SLUserViewModel.sharedInstance.currentUser?.userId
            question.title = self.enterQuestionTextView.text
            question.category = SLCategory()
            question.category?.objectId = self.category!.objectId
            question.category?.subject = self.category!.subject
            question.localId = SLLocalDataManager.sharedInstance.generateLocalQuestionId()
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                // Save new question
                SLLocalDataManager.sharedInstance.saveQuestion(question, images: imagesCropped)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // Post new question created
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.POST_QUESTION_SEND, object: question)
                    self.sendButton.loading = false
                    self.setEnableInteractiveView(true)
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.PUSH_POST_ASK_SUCCESS, object: nil)
                })
            })
        }
    }
    
}

extension CustomCropImageController {
    
    // MARK: - Actions
    
    @IBAction func addMoreAction(sender: AnyObject) {
        if addMoreButton.loading {
            return
        }
        
        if photos.count == 4 {
            Constants.showAlert(message: "You can't add more than 4 images!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Default))
            return
        }
        
        self.oldIndexPhoto = self.indexPhoto
        cropViewController?.toolbar.doneButtonTapped!()
        
        let controller = SLAskCameraViewController.controller
        controller.isAddMore = true;
        controller.delegate = self
        let navigationController = SLRootNavigationController(rootViewController: controller)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
}

extension CustomCropImageController {
    
    func initViewGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(CustomCropImageController.pickSubject(_:)))
        pickSubjectView.userInteractionEnabled = true
        pickSubjectView.addGestureRecognizer(tap)
        
        let tapScreen = UITapGestureRecognizer(target: self, action: #selector(CustomCropImageController.tapOutSide(_:)))
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(tapScreen)
        tapScreen.cancelsTouchesInView = false
    }
    
    func initView() {
        enterQuestionTextView.contentInset.top = 5
        enterQuestionTextView.delegate = self
        enterQuestionTextView.text = placeholder
        enterQuestionTextView.textColor = UIColor.grayColor()
    }
    
    func fetchQuestionPhotos() {
        if let question = question {
            // Update category, subject
            if let category = question.category {
                self.category = category
                self.subjectLabel.text = category.subject
            }
            
            if let title = question.title {
                self.enterQuestionTextView.text = title
                sendButton.hidden = false
                self.enterQuestionTextView.textColor = UIColor.blackColor()
            }
            
            let isLocalQuestion = question.isLocalQuestion()
            if (isLocalQuestion == true)  {
                //  Fetch photo in local
                photos += SLLocalDataManager.sharedInstance.getQuestionPhotos(question)
                originPhotos += SLLocalDataManager.sharedInstance.getQuestionPhotos(question)
                
                if self.photos.count > 0 {
                    self.image = self.photos[0]
                }
                
                self.initCropView()
                self.initGalleryView()
            } else {
                //  TODO need to fetch photo from internet --> Then call initGalleryView() to update UI
                if let images = question.questionImages {
                    let downloadGroup = dispatch_group_create()
                    self.addMoreButton.loading = true
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    for imagePath in images {
                        dispatch_group_enter(downloadGroup)
                        let url = NSURL(string: imagePath)!
                        ImageDownloader.defaultDownloader.downloadImageWithURL(url, options: nil, progressBlock: nil, completionHandler: { (image, error, imageURL, originalData) in
                            if let image = image {
                                image.accessibilityIdentifier = imagePath
                                self.photos.append(image)
                                self.originPhotos.append(image)
                            }
                            dispatch_group_leave(downloadGroup)
                        })
                    }
                    
                    dispatch_group_notify(downloadGroup, dispatch_get_main_queue()) {
                        self.addMoreButton.loading = false
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        if self.photos.count > 0 {
                            self.image = self.photos[0]
                        }
                        
                        self.initCropView()
                        self.initGalleryView()
                    }
                }
            }
        }
    }
    
    func initGalleryView() {
        let margin = CGFloat(((photoSize-1)*2 > 0) ?? 0)
        let frameX = self.imageBrowser.frame.size.width/2 - (CGFloat(photos.count) * photoSize + margin)/2
        for imageView in self.imageBrowser.subviews {
            imageView.removeFromSuperview()
        }
        
        for i in 0 ..< photos.count {
            let photo = photos[i]
            let imageView = UIImageView(image: photo)
            let x = CGFloat(frameX + (CGFloat(i) * (photoSize + 2)))
            imageView.frame = CGRectMake(x, 5, photoSize, photoSize)
            imageView.tag = i
            imageView.userInteractionEnabled = true
            imageView.layer.borderWidth = 1.0
            imageView.layer.borderColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR).CGColor
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.selectGallery(_:)))
            imageView.addGestureRecognizer(tap)
            
            if self.image == photos[i] {
                self.indexPhoto = i
                self.oldIndexPhoto = i
                opaque = UIView(frame: CGRectMake(0, 0, photoSize, photoSize))
                opaque!.backgroundColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
                opaque!.alpha = 0.5
                imageView.addSubview(opaque!)
            }
            
            self.imageBrowser.addSubview(imageView)
        }
        
        if photos.count >= 5 {
            addMoreButton.hidden = true
        } else {
            addMoreButton.hidden = false
        }
    }
    
    func initCropView() {
        if let cropView = cropViewController {
            
            cropView.view.removeFromSuperview()
            cropViewController = nil
        }
        
        guard image != nil else {
            return
        }
        
        cropViewController = TOCropViewController(image: self.image!)
        cropViewController?.delegate = self
        cropViewController?.view.frame = self.containerView.bounds
        cropViewController?.toolbar.hidden = true
        UIView.performWithoutAnimation {
            if let cropViewController = self.cropViewController {
                self.containerView.addSubview(cropViewController.view)
                cropViewController.toolbar.resetButtonTapped!()
            }
        }
    }
    
    // MARK: - TextViewDelegate
    func textViewDidChange(textView: UITextView) {
        let text = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if text.characters.count == 0 {
            sendButton.hidden = true
        } else {
            sendButton.hidden = false
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.grayColor() {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.grayColor()
        }
    }
}

extension CustomCropImageController: TOCropViewControllerDelegate {
    
    // MARK: - TOCropViewControllerDelegate
    
    func cropViewController(cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        
        // TO DO: Add url of photo to question.editingImages
        
        if self.indexPhoto == self.oldIndexPhoto && addQuestion {
            if let imageIdentifier = photos[indexPhoto].accessibilityIdentifier {
                if !editedImages.contains(imageIdentifier) && photos[self.oldIndexPhoto] != image {
                    editedImages.append(imageIdentifier)
                }
            }

            photos[self.indexPhoto] = image
            self.postQuestionAPI(photos)
            return
        }
        
        if self.oldIndexPhoto < photos.count {
            if let imageIdentifier = photos[oldIndexPhoto].accessibilityIdentifier {
                if !editedImages.contains(imageIdentifier) && photos[self.oldIndexPhoto] != image {
                    editedImages.append(imageIdentifier)
                }
            }
            
            photos[self.oldIndexPhoto] = image
        }
    }
}

extension CustomCropImageController {
    
    // MARK: - Custom method
    
    func tapOutSide(sender: UITapGestureRecognizer?) {
        self.view.endEditing(true)
    }
    
    func pickSubject(sender: UITapGestureRecognizer?) {
        if self.sendButton.loading == true {
            return
        }
        
        if self.bottomViewEnterQuestionConstraint.constant > 0 {
            self.view.endEditing(true)
        }
        
        if openTblSubject {
            self.heightTableViewConstraint.constant = 0
            openTblSubject = false
            self.blurView.hidden = true
            self.navigationBlurView.hidden = true
        } else {
            self.heightTableViewConstraint.constant = CGFloat(heightTableViewSubject)
            openTblSubject = true
            self.blurView.hidden = false
            self.navigationBlurView.hidden = false
        }
        
        UIView.animateWithDuration(duration, animations: {
            self.view.layoutIfNeeded()
        }) { finished in
                
        }
    }
    
    func showKeyboardForViewEnterQuestion(keyboardSize: CGSize?) {
        if (self.heightTableViewConstraint.constant > 0) {
            self.heightTableViewConstraint.constant = 0
            self.openTblSubject = false
        }
        
        self.bottomViewEnterQuestionConstraint.constant = CGFloat((keyboardSize?.height)!)
        UIView.animateWithDuration(duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func selectGallery(sender: UITapGestureRecognizer) {
        self.opaque?.removeFromSuperview()
        if let opaque = opaque {
            opaque.backgroundColor = UIColor(hexString: Constants.SIBLINKS_COMMON_HEX_COLOR)
            opaque.alpha = 0.5
            sender.view!.addSubview(opaque)
        }
        cropViewController?.toolbar.doneButtonTapped!()
        self.oldIndexPhoto = self.indexPhoto
        self.indexPhoto = sender.view!.tag
        self.image = photos[sender.view!.tag]
        self.initCropView()
    }
}

extension CustomCropImageController {
    
    override func keyboardWillShow(notification: NSNotification) {
        self.blurView.hidden = false
        self.navigationBlurView.hidden = false
        keyboardVisible = true
        
        let userInfo: NSDictionary = notification.userInfo!
        let keyboardSize = userInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        self.showKeyboardForViewEnterQuestion(keyboardSize)
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        self.blurView.hidden = true
        self.navigationBlurView.hidden = true
        keyboardVisible = false
        
        self.bottomViewEnterQuestionConstraint.constant = 0
        UIView.animateWithDuration(duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
}

extension CustomCropImageController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PickSubjectCell.cellIdentifier())
        cell?.textLabel?.font = Constants.regularFontOfSize(14)
        
        if let pickCell = cell as? PickSubjectCell {
            let cate = categories[indexPath.row]
            pickCell.titleLabel.text = cate.subject
            
            return pickCell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        category = categories[indexPath.row]
        self.subjectLabel.text = category?.subject
        self.pickSubject(nil)
    }
    
}
