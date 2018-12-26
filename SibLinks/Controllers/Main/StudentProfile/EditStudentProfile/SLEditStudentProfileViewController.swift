//
//  SLEditStudentProfileViewController.swift
//  SibLinks
//
//  Created by Jana on 9/15/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import IBAnimatable
import SDCAlertView

enum GenderType: String {
    case Male = "M", Female = "F", Other = "O"
}

enum ActionSheetType {
    case HighSchool
    case Gender
    case FavoriteSubjects
}

class SLEditStudentProfileViewController: SLBaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstNameTextField: AnimatableTextField!
    @IBOutlet weak var lastnameNameTextField: AnimatableTextField!
    @IBOutlet weak var highSchoolNameTextField: AnimatableTextField!
    @IBOutlet weak var genderTextField: AnimatableTextField!
    
    @IBOutlet weak var birthdayTextField: AnimatableTextField! {
        didSet {
            birthdayTextField.tintColor = UIColor.clearColor()
            let datePickerView = UIDatePicker()
            datePickerView.maximumDate = NSDate()
            datePickerView.datePickerMode = UIDatePickerMode.Date
            birthdayTextField.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(SLEditStudentProfileViewController.handleDatePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
        }
    }
    
    @IBOutlet weak var favoriteSubjectsTextField: AnimatableTextField!
    @IBOutlet weak var aboutMeTextField: AnimatableTextField!
    @IBOutlet weak var avatarImageView: AnimatableImageView!
    @IBOutlet weak var changeAvatarButton: UIButton!
    @IBOutlet weak var saveButton: LoadingButton!
    
    @IBOutlet weak var highSchoolButton: UIButton! {
        didSet {
            highSchoolButton.addTarget(self, action: #selector(self.selectHighSchoolAction(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var genderButton: UIButton! {
        didSet {
            genderButton.addTarget(self, action: #selector(self.selectGenderAction(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var birthdayButton: UIButton! {
        didSet {
            birthdayButton.addTarget(self, action: #selector(self.selectBirthdayAction(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var favoriteSubjectsButton: UIButton! {
        didSet {
            favoriteSubjectsButton.addTarget(self, action: #selector(self.selectFavoriteSubjectsAction(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
    var activeTextField: UITextField?
    
    lazy var keyboardToolbar: UIToolbar = self.createKeyboardToolBar()
    private func createKeyboardToolBar() -> UIToolbar {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 35)
        keyboardToolbar.barStyle = .Default
        keyboardToolbar.sizeToFit()
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.pickBirthDate))
        doneButton.tintColor = colorFromHex(Constants.SIBLINKS_COMMON_HEX_COLOR)
        keyboardToolbar.items = [space, doneButton]
        return keyboardToolbar
    }
    
    let userViewModel = SLUserViewModel.sharedInstance
    var user: SLUser?
    weak var delegate: SLStudentProfileViewController?
    var selectedGender: GenderType?
    var selectedHighSchool: SLSchool?
    var listHighSchool = Constants.appDelegate().university
    var listGender = ["Male", "Female", "Decline to state"]
    var listFavoriteSubjects = Constants.appDelegate().categories
    var listFavoriteSubjectsSelected = [SLCategory]()
    var highSchoolActionSheet: JLActionSheet?
    var genderActionSheet: JLActionSheet?
    var favoriteSubjectsActionSheet: JLActionSheet?
    var actionSheetType: ActionSheetType?

    override func viewDidLoad() {
        super.viewDidLoad()
        getUserProfile()
        interactiveViewArray = [firstNameTextField, lastnameNameTextField, highSchoolNameTextField, genderTextField, birthdayTextField, favoriteSubjectsTextField, aboutMeTextField, changeAvatarButton, genderButton]
        
        self.birthdayTextField.inputAccessoryView = self.keyboardToolbar
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register For Keyboard Notifications
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Destroy For Keyboard Notifications
        self.destroyForKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleDatePicker(sender: UIDatePicker) {
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "dd MMM yyyy"
//        self.birthdayTextField.text = dateFormatter.stringFromDate(sender.date)
    }

    func getUserProfile() {
        if let user = user {
            if let firstName = user.firstname {
                firstNameTextField.text = firstName
            } else {
                firstNameTextField.text = ""
            }
            
            if let lastName = user.lastname {
                lastnameNameTextField.text = lastName
            } else {
                lastnameNameTextField.text = ""
            }
            
            if let schoolId = user.school {
                var schoolName = ""
                for school in Constants.appDelegate().university {
                    if school.objectId == schoolId.toInt() {
                        if let schoolNameValue = school.name {
                            schoolName = schoolNameValue
                        }
                    }
                }
                highSchoolNameTextField.text = schoolName
            } else {
                highSchoolNameTextField.text = ""
            }
            
            if let gender = user.gender {
                var genderString = "Decline to state"
                switch gender {
                case (GenderType.Male).rawValue:
                    genderString = "Male"
                    selectedGender = .Male
                case (GenderType.Female).rawValue:
                    genderString = "Female"
                    selectedGender = .Female
                default:
                    genderString = "Decline to state"
                    selectedGender = .Other
                }
                genderTextField.text = genderString
            } else {
                genderTextField.text = ""
            }
            
            if let birthday = user.birthday {
                birthdayTextField.text = birthDateFormatter.stringFromDate(birthday)
            } else {
                birthdayTextField.text = ""
            }
            
            if let favorite = user.defaultSubjectId {
                var subjectString = ""
                let subjectIdArray = favorite.componentsSeparatedByString(",")
                if subjectIdArray.count > 0 {
                    for index in 0 ..< subjectIdArray.count {
                        for category in Constants.appDelegate().categories {
                            if category.objectId == "\(subjectIdArray[index])".toInt() {
                                if subjectString == "" {
                                    subjectString += "\(category.subject ?? "")"
                                } else {
                                    subjectString += ", \(category.subject ?? "")"
                                }
                            }
                        }
                    }
                }
                
                favoriteSubjectsTextField.text = subjectString
            } else {
                favoriteSubjectsTextField.text = ""
            }
            
            if let about = user.aboutMe {
                aboutMeTextField.text = about
            } else {
                aboutMeTextField.text = ""
            }
            
            if let imageUrl = user.imageUrl {
                avatarImageView.kf_setImageWithURL(NSURL(string: imageUrl), placeholderImage: Constants.noAvatarImage)
            } else {
                avatarImageView.image = Constants.noAvatarImage
            }
        } else {
            firstNameTextField.text = ""
            lastnameNameTextField.text = ""
            highSchoolNameTextField.text = ""
            genderTextField.text = ""
            birthdayTextField.text = ""
            favoriteSubjectsTextField.text = ""
            aboutMeTextField.text = ""
            avatarImageView.image = Constants.noAvatarImage
        }
    }
}

extension SLEditStudentProfileViewController {
    
    // MARK: - Configure
    
    override func configView() {
        
        let touchOnScreen = UITapGestureRecognizer(target: self, action: #selector(self.touchOnScreenAction))
        touchOnScreen.cancelsTouchesInView = false
        self.view.addGestureRecognizer(touchOnScreen)
    }
    
}

extension SLEditStudentProfileViewController {
    
    // MARK: - Keyboard notification
    override func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo!
        let keyboardSize = userInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        guard let activeTextField = self.activeTextField else {
            return
        }
        
        var viewRect = view.frame
        viewRect.size.height -= keyboardSize.height
        if CGRectContainsPoint(viewRect, activeTextField.frame.origin) {
            self.scrollView.scrollRectToVisible(activeTextField.frame, animated: true)
        }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        self.scrollView.contentInset = UIEdgeInsetsZero
        self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
    }
    
}

extension SLEditStudentProfileViewController: UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.activeTextField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case self.firstNameTextField:
            self.lastnameNameTextField.becomeFirstResponder()
        case self.lastnameNameTextField:
            self.lastnameNameTextField.resignFirstResponder()
        case self.highSchoolNameTextField:
            self.highSchoolNameTextField.becomeFirstResponder()
        case self.genderTextField:
            self.birthdayTextField.becomeFirstResponder()
        case self.birthdayTextField:
            self.birthdayTextField.resignFirstResponder()
        case self.favoriteSubjectsTextField:
            self.aboutMeTextField.becomeFirstResponder()
        default:
            self.touchOnScreenAction()
            self.saveAction(textField)
        }
        return true
    }
}

extension SLEditStudentProfileViewController {
    
    // MARK: - Actions
    func pickBirthDate() {
        if let datePickerView = self.birthdayTextField.inputView as? UIDatePicker {
            self.birthdayTextField.text = birthDateFormatter.stringFromDate(datePickerView.date)
        }
        
        touchOnScreenAction()
    }
    
    func touchOnScreenAction() {
        self.firstNameTextField.resignFirstResponder()
        self.lastnameNameTextField.resignFirstResponder()
        self.highSchoolNameTextField.resignFirstResponder()
        self.genderTextField.resignFirstResponder()
        self.birthdayTextField.resignFirstResponder()
        self.favoriteSubjectsTextField.resignFirstResponder()
        self.aboutMeTextField.resignFirstResponder()
    }
    
    @IBAction func closeViewControllerAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func changeYourAvatarAction(sender: AnyObject) {
        let cameraViewController = SLCameraViewController.controller
        cameraViewController.delegate = self
        self.presentViewController(cameraViewController, animated: true, completion: nil)
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        if saveButton.loading {
            return
        }
        
        let firstname = self.firstNameTextField.text ?? ""
        let lastname = self.lastnameNameTextField.text ?? ""
        
        var schoolId = ""
        let schoolName = self.highSchoolNameTextField.text ?? ""
        for school in Constants.appDelegate().university {
            if school.name == schoolName {
                if let schookId = school.objectId {
                    schoolId = "\(schookId)"
                }
            }
        }
        
        let birthdayString = self.birthdayTextField.text ?? ""
        if let birthday = birthDateFormatter.dateFromString(birthdayString) {
            self.user?.birthday = birthday
        }
        
        var categoriesString = ""
        let defaultSubjectId = self.favoriteSubjectsTextField.text ?? ""
        let subjectIdArray = defaultSubjectId.componentsSeparatedByString(", ")
        for index in 0 ..< subjectIdArray.count {
            for category in Constants.appDelegate().categories {
                if (category.subject ?? "") == subjectIdArray[index] {
                    if categoriesString == "" {
                        categoriesString += "\(category.objectId ?? 0)"
                    } else {
                        categoriesString += ",\(category.objectId ?? 0)"
                    }
                }
            }
        }
        
        let aboutMe = self.aboutMeTextField.text ?? ""

        // Update user again
        self.user?.firstname = firstname.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.user?.lastname = lastname.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.user?.school = schoolId.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.user?.gender = selectedGender?.rawValue
        self.user?.defaultSubjectId = categoriesString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.user?.aboutMe = aboutMe.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        guard let existUser = self.user else {
            return
        }
        
        saveButton.loading = true
        setEnableInteractiveView(false)
        
        let updateGroup = dispatch_group_create()
        
        // Upload avatar image
        if let image = existUser.uploadAvatar {
            dispatch_group_enter(updateGroup)
            self.userViewModel.uploadAvatar(existUser, avatarImage: image, success: { 
                dispatch_group_leave(updateGroup)
                }, failure: { (error) in
                    dispatch_group_leave(updateGroup)
                }, networkFailure: { (error) in
                    dispatch_group_leave(updateGroup)
            })
        }
        
        // Update user profile
        var hasError = false
        dispatch_group_enter(updateGroup)
        self.userViewModel.updateProfileWithUser(existUser, success: {
            dispatch_group_leave(updateGroup)
            self.saveButton.loading = false
            self.setEnableInteractiveView(true)
            }, failure: { (error) in
                dispatch_group_leave(updateGroup)
                self.saveButton.loading = false
                self.setEnableInteractiveView(true)
                ErrorHandlingController.handleAPIError(error)
                hasError = true
            }) { (error) in
                dispatch_group_leave(updateGroup)
                self.saveButton.loading = false
                self.setEnableInteractiveView(true)
                ErrorHandlingController.handleNetworkError(error)
                hasError = true
        }
        
        dispatch_group_notify(updateGroup, dispatch_get_main_queue()) {
            if !hasError {
                if let studentViewController = self.delegate {
                    studentViewController.updateUserProfile()
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func selectHighSchoolAction(sender: AnyObject) {
        self.actionSheetType = .HighSchool
        
        self.highSchoolActionSheet = JLActionSheet(delegate: self, dataSource: self)
        self.highSchoolActionSheet?.tableView.registerNib(SLFilterTableViewCell.nib(), forCellReuseIdentifier: SLFilterTableViewCell.cellIdentifier())
        self.highSchoolActionSheet?.show()
    }
    
    func selectGenderAction(sender: AnyObject) {
        self.actionSheetType = .Gender
        
        self.genderActionSheet = JLActionSheet(delegate: self, dataSource: self)
        self.genderActionSheet?.tableView.registerNib(SLFilterTableViewCell.nib(), forCellReuseIdentifier: SLFilterTableViewCell.cellIdentifier())
        self.genderActionSheet?.show()
    }
    
    func selectBirthdayAction(sender: AnyObject) {
        if let datePickerView = self.birthdayTextField.inputView as? UIDatePicker {
            if let birthdayString = birthdayTextField.text {
                if let birthday = birthDateFormatter.dateFromString(birthdayString) {
                    datePickerView.date = birthday
                }
            }
        }
        
        self.birthdayTextField.becomeFirstResponder()
    }
    
    func selectFavoriteSubjectsAction(sender: AnyObject) {
        self.actionSheetType = .FavoriteSubjects
        
        self.favoriteSubjectsActionSheet = JLActionSheet(delegate: self, dataSource: self)
        self.favoriteSubjectsActionSheet?.tableView.registerNib(SLMultipleSelectionTableViewCell.nib(), forCellReuseIdentifier: SLMultipleSelectionTableViewCell.cellIdentifier())
        self.favoriteSubjectsActionSheet?.show()
    }
    
}

extension SLEditStudentProfileViewController: JLActionSheetDataSource {
    
    // MARK: - JLActionSheetDataSource
    
    func JLActionSheetDataSourceTableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.actionSheetType! {
        case .HighSchool:
            return self.listHighSchool.count
        case .Gender:
            return self.listGender.count
        case .FavoriteSubjects:
            return self.listFavoriteSubjects.count
        }
    }
    
    func JLActionSheetDataSourceTableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch self.actionSheetType! {
        case .HighSchool:
            let cell = tableView.dequeueReusableCellWithIdentifier(SLFilterTableViewCell.cellIdentifier())
            
            if let genderCell = cell as? SLFilterTableViewCell {
                let highSchool = listHighSchool[indexPath.row]
                genderCell.filterTitleLabel.text = highSchool.name
                return genderCell
            }
        case .Gender:
            let cell = tableView.dequeueReusableCellWithIdentifier(SLFilterTableViewCell.cellIdentifier())
            
            if let genderCell = cell as? SLFilterTableViewCell {
                genderCell.filterTitleLabel.text = self.listGender[indexPath.row]
                return genderCell
            }
            
        case .FavoriteSubjects:
            let cell = tableView.dequeueReusableCellWithIdentifier(SLMultipleSelectionTableViewCell.cellIdentifier())
            
            if let multipleSelectionCell = cell as? SLMultipleSelectionTableViewCell {
                if indexPath.row < listFavoriteSubjects.count {
                    let category = listFavoriteSubjects[indexPath.row]
                    multipleSelectionCell.configCellWithData(category)
                }
                if self.listFavoriteSubjectsSelected.contains(self.listFavoriteSubjects[indexPath.row]) {
                    multipleSelectionCell.multipleSelectionMarkImageView.hidden = false
                } else {
                    multipleSelectionCell.multipleSelectionMarkImageView.hidden = true
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
        case .HighSchool:
            if self.listHighSchool.count < 4 {
                return (50 * CGFloat(self.listHighSchool.count))
            }
            return 200
        case .Gender:
            return 150
        case .FavoriteSubjects:
            if self.listFavoriteSubjects.count < 4 {
                return (50 * CGFloat(self.listFavoriteSubjects.count))
            }
            return 200
        }
    }
    
}

extension SLEditStudentProfileViewController: JLActionSheetDelegate {
    
    // MARK: - JLActionSheetDelegate
    
    func JLActionSheetDelegateTableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch self.actionSheetType! {
        case .HighSchool:
            self.highSchoolActionSheet?.dismiss()
            self.selectedHighSchool = self.listHighSchool[indexPath.row]
            self.highSchoolNameTextField.text = self.selectedHighSchool?.name
            
        case .Gender:
            self.genderActionSheet?.dismiss()
            switch indexPath.row {
            case 0:
                self.selectedGender = .Male
                self.genderTextField.text = "Male"
            case 1:
                self.selectedGender = .Female
                self.genderTextField.text = "Female"
            case 2:
                self.selectedGender = .Other
                self.genderTextField.text = "Decline to state"
            default:
                self.selectedGender = .Other
                self.genderTextField.text = "Decline to state"
            }
            
        case .FavoriteSubjects:
            let selectedObject = self.listFavoriteSubjects[indexPath.row]
            if self.listFavoriteSubjectsSelected.contains(selectedObject) {
                self.listFavoriteSubjectsSelected.removeObject(selectedObject)
            } else {
                self.listFavoriteSubjectsSelected.append(selectedObject)
            }
            
            var categoriesName = [String]()
            for category in listFavoriteSubjectsSelected {
                categoriesName.append(category.subject!)
            }
            
            let favoriteSubjectsString = categoriesName.joinWithSeparator(", ")
            self.favoriteSubjectsTextField.text = favoriteSubjectsString
            
            self.favoriteSubjectsActionSheet?.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        }
    }
}

extension SLEditStudentProfileViewController: SLCameraViewControllerDelegate {
    
    // MARK: - SLCameraViewControllerDelegate
    
    func result(image: UIImage) {
        self.avatarImageView.image = image
        guard let existUser = self.user else {
            return
        }
        
        existUser.uploadAvatar = image
    }
    
}
