//
//  SLSignUpViewController.swift
//  SibLinks
//
//  Created by Jana on 9/5/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import SDCAlertView
import FBSDKLoginKit
import GoogleSignIn

class SLSignUpViewController: SLBaseViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView! {
        didSet {
            // Set background image view
            if let imagePath = NSBundle.mainBundle().pathForResource("signup-background", ofType: "jpg") {
                backgroundImageView.image = UIImage(contentsOfFile: imagePath)
            }
        }
    }

    @IBOutlet weak var termsOfServiceTextView: UITextView! {
        didSet {
            let myString = "By Create a new account, you agree with our Terms of Services."
            let attributedString = NSMutableAttributedString(string: myString, attributes: [NSFontAttributeName:Constants.regularFontOfSize(12)])
            
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: Constants.SIBLINKS_SEGMENTED_TEXT_COLOR), range: NSRange(location:0, length:myString.characters.count))
            attributedString.addAttribute(NSFontAttributeName, value: Constants.boldFontOfSize(12), range: NSRange(location:44, length:17))
            termsOfServiceTextView.attributedText = attributedString
            termsOfServiceTextView.textAlignment = .Center
        }
    }
    
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            backButton.addTarget(self, action: #selector(self.backAction), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            
        }
    }
    
    @IBOutlet weak var emailTextField: FloatingLabelTextFieldWithIcon! {
        didSet {
            emailTextField.delegate = self
            emailTextField.iconFont = UIFont.init(name: "FontAwesome", size: 15)
            emailTextField.iconText = "\u{f007}"
            emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
            emailTextField.delegate = self
        }
    }
    
    @IBOutlet weak var passwordTextField: FloatingLabelTextFieldWithIcon! {
        didSet {
            passwordTextField.delegate = self
            passwordTextField.iconFont = UIFont.init(name: "FontAwesome", size: 15)
            passwordTextField.iconText = "\u{f023}"
            passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
            passwordTextField.delegate = self
        }
    }
    
    @IBOutlet weak var confirmPasswordTextField: FloatingLabelTextFieldWithIcon! {
        didSet {
            confirmPasswordTextField.delegate = self
            confirmPasswordTextField.iconFont = UIFont.init(name: "FontAwesome", size: 15)
            confirmPasswordTextField.iconText = "\u{f023}"
            confirmPasswordTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
            confirmPasswordTextField.delegate = self
        }
    }
    
    @IBOutlet weak var signUpButton: LoadingButton! {
        didSet {
            signUpButton.setActivityIndicatorAlignment(ActivityIndicatorAlignment.Center)
            signUpButton.addTarget(self, action: #selector(self.signUpAction), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var loginWithFacebookButton: LoadingButton! {
        didSet {
            loginWithFacebookButton.setActivityIndicatorAlignment(ActivityIndicatorAlignment.Center)
            loginWithFacebookButton.addTarget(self, action: #selector(self.loginWithFacebookAction), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var loginWithGoogleButton: LoadingButton! {
        didSet {
            loginWithGoogleButton.addTarget(self, action: #selector(self.loginWithGoogleAction), forControlEvents: .TouchUpInside)
        }
    }
    
    let userViewModel = SLUserViewModel.sharedInstance
    
    var activeTextField: UITextField?
    var trackingEmailTextField: Bool = false
    var trackingFirstNameTextField: Bool = false
    var trackingLastNameTextField: Bool = false
    var trackingHighSchoolTextField: Bool = false
    var trackingConfirmPasswordTextField: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(myMethodToHandleTap(_:)))
        tap.delegate = self
        termsOfServiceTextView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Interactive
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
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
    
    // MARK: - UITapGestureRecognizer
    func myMethodToHandleTap(sender: UITapGestureRecognizer) {
        let myTextView = sender.view as! UITextView
        let layoutManager = myTextView.layoutManager
        var location = sender.locationInView(myTextView)
        location.x -= myTextView.textContainerInset.left;
        location.y -= myTextView.textContainerInset.top;
        
        let characterIndex = layoutManager.characterIndexForPoint(location, inTextContainer: myTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        if characterIndex < myTextView.textStorage.length {
            if characterIndex > 44 && characterIndex != 53 && characterIndex != 61 {
                let termsOfServiceViewController = SLTermsOfServiceViewController.controller
                self.navigationController?.pushViewController(termsOfServiceViewController, animated: true)
            }
        }
    }
}

extension SLSignUpViewController {
    
    // MARK: - Configure view
    override func configView() {
        self.navigationController?.navigationBarHidden = true
        
        self.title = "Sign up".localized
        
        let touchOnScreen = UITapGestureRecognizer(target: self, action: #selector(self.touchOnScreenAction))
        self.view.addGestureRecognizer(touchOnScreen)
        
        self.interactiveViewArray = [self.emailTextField, self.passwordTextField, self.confirmPasswordTextField, self.signUpButton, self.loginWithFacebookButton, self.loginWithGoogleButton]
    }
    
}

extension SLSignUpViewController {
    
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

extension SLSignUpViewController: UITextFieldDelegate {

    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.activeTextField = nil
        
        switch textField {
        case self.emailTextField:
            self.trackingEmailTextField = true
            if !self.emailTextField.text!.isEmail() {
                self.emailTextField.lineColor = colorFromHex(Constants.SIBLINKS_TEXTFIELD_RED_COLOR)
            } else {
                self.emailTextField.lineColor = colorFromHex(Constants.SIBLINKS_COMMON_HEX_COLOR)
            }
            
        case self.passwordTextField:
            if self.passwordTextField.text!.characters.count < 6 {
                self.passwordTextField.lineColor = colorFromHex(Constants.SIBLINKS_TEXTFIELD_RED_COLOR)
            } else {
                self.passwordTextField.lineColor = colorFromHex(Constants.SIBLINKS_COMMON_HEX_COLOR)
            }
            
        case self.confirmPasswordTextField:
            self.trackingConfirmPasswordTextField = true
            if self.confirmPasswordTextField.text!.characters.count < 6 || self.confirmPasswordTextField.text != self.passwordTextField.text {
                self.confirmPasswordTextField.lineColor = colorFromHex(Constants.SIBLINKS_TEXTFIELD_RED_COLOR)
            } else {
                self.confirmPasswordTextField.lineColor = colorFromHex(Constants.SIBLINKS_COMMON_HEX_COLOR)
            }
            
        default:
            return
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case self.emailTextField:
            self.passwordTextField.becomeFirstResponder()
            
        case self.passwordTextField:
            self.confirmPasswordTextField.becomeFirstResponder()
            
        default:
            self.signUpAction()
        }
        return true
    }
}

extension SLSignUpViewController {
    
    // MARK: - Textfield did change
    
    func textFieldDidChange(textField: UITextField) {
        switch textField {
        case self.emailTextField:
            if self.trackingEmailTextField {
                if !self.emailTextField.text!.isEmail() {
                    self.emailTextField.errorMessage = "Invalid email".localized
                    self.emailTextField.lineColor = colorFromHex(Constants.SIBLINKS_TEXTFIELD_RED_COLOR)
                } else {
                    self.emailTextField.errorMessage = ""
                    self.emailTextField.lineColor = colorFromHex(Constants.SIBLINKS_COMMON_HEX_COLOR)
                }
            }
            
        case self.passwordTextField:
            if self.trackingConfirmPasswordTextField {
                if self.passwordTextField.text!.characters.count < 6 || self.confirmPasswordTextField.text != self.passwordTextField.text {
                    self.passwordTextField.lineColor = colorFromHex(Constants.SIBLINKS_TEXTFIELD_RED_COLOR)
                    self.confirmPasswordTextField.lineColor = colorFromHex(Constants.SIBLINKS_TEXTFIELD_RED_COLOR)
                } else {
                    self.passwordTextField.lineColor = colorFromHex(Constants.SIBLINKS_COMMON_HEX_COLOR)
                    self.confirmPasswordTextField.lineColor = colorFromHex(Constants.SIBLINKS_COMMON_HEX_COLOR)
                }
            }
            
        case self.confirmPasswordTextField:
            if self.trackingConfirmPasswordTextField {
                if self.confirmPasswordTextField.text!.characters.count < 6 && self.trackingConfirmPasswordTextField || self.confirmPasswordTextField.text != self.passwordTextField.text {
                    self.passwordTextField.lineColor = colorFromHex(Constants.SIBLINKS_TEXTFIELD_RED_COLOR)
                    self.confirmPasswordTextField.lineColor = colorFromHex(Constants.SIBLINKS_TEXTFIELD_RED_COLOR)
                } else {
                    self.passwordTextField.lineColor = colorFromHex(Constants.SIBLINKS_COMMON_HEX_COLOR)
                    self.confirmPasswordTextField.lineColor = colorFromHex(Constants.SIBLINKS_COMMON_HEX_COLOR)
                }
            }
            
        default:
            return
        }
    }
}

extension SLSignUpViewController {
    
    // MARK: - Actions
    
    func touchOnScreenAction() {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.confirmPasswordTextField.resignFirstResponder()
    }
    
    func backAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func signUpAction() {
        self.touchOnScreenAction()
        if self.signUpButton.loading {
            return
        }
        
        guard self.emailTextField.text?.characters.count > 0 && self.passwordTextField.text?.characters.count > 0 && self.confirmPasswordTextField.text?.characters.count > 0 else {
            Constants.showAlert("SibLinks", message: "Please enter all fields.", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
            return
        }
        
        guard self.emailTextField.text!.isEmail() else {
            Constants.showAlert("SibLinks", message: "Email is not valid.", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
            return
        }
        
        guard self.passwordTextField.text!.characters.count >= 6 else {
            Constants.showAlert("SibLinks", message: "Password must be greater than or equal 6 characters.", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
            return
        }
        
        guard self.passwordTextField.text == self.confirmPasswordTextField.text else {
            Constants.showAlert("SibLinks", message: "Your password and confirmation password do not match.", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
            return
        }
        
        let email = self.emailTextField.text ?? ""
        let password = self.passwordTextField.text ?? ""
        
        self.signUpButton.loading = true
        self.setEnableInteractiveView(false)
        self.userViewModel.signUpWithEmail(email, password: password, firstname: "", lastname: "", highSchool: "", success: {
            SLTrackingEvent.sharedInstance.sendSignUpWithEmailEvent(SLTrackingEvent.kSLSignUpScreen)
            self.userViewModel.signInWithEmail(email, password: password, success: { 
                self.signUpButton.loading = false
                self.setEnableInteractiveView(true)
                self.showMainView()
                }, failure: { (error) in
                    self.signUpButton.loading = false
                    self.setEnableInteractiveView(true)
                    ErrorHandlingController.handleAPIError(error)
                }, networkFailure: { (error) in
                    self.signUpButton.loading = false
                    self.setEnableInteractiveView(true)
                    ErrorHandlingController.handleNetworkError(error)
            })
            }, failure: { (error) in
                self.signUpButton.loading = false
                self.setEnableInteractiveView(true)
                ErrorHandlingController.handleAPIError(error)
            }, networkFailure: { (error) in
                self.signUpButton.loading = false
                self.setEnableInteractiveView(true)
                ErrorHandlingController.handleNetworkError(error)
        })
    }

    func loginWithFacebookAction() {
        self.loginWithFacebookButton.loading = true
        self.setEnableInteractiveView(false)
        self.loginWithFacebook({
            self.getFacebookUser({ (result) in
                
                let email = (result?.objectForKey("email") as? String) ?? ""
                let firstname = (result?.objectForKey("first_name") as? String) ?? ""
                let lastname = (result?.objectForKey("last_name") as? String) ?? ""
                let facebookId = (result?.objectForKey("id") as? String) ?? ""
                
                self.userViewModel.signInWithFacebook(email, firstname: firstname, lastname: lastname, facebookId: facebookId, success: {
                    self.setEnableInteractiveView(true)
                    self.loginWithFacebookButton.loading = false
                    self.showMainView()
                    }, failure: { (error) in
                        self.setEnableInteractiveView(true)
                        self.loginWithFacebookButton.loading = false
                        // Error
                    }, networkFailure: { (error) in
                        self.setEnableInteractiveView(true)
                        self.loginWithFacebookButton.loading = false
                })
                }, failure: { (error) in
                    self.setEnableInteractiveView(true)
                    self.loginWithFacebookButton.loading = false
                    // Error
            })
        }) { (error) in
            self.setEnableInteractiveView(true)
            self.loginWithFacebookButton.loading = false
            // Error
        }
    }
    
    func loginWithGoogleAction() {
        if self.loginWithGoogleButton.loading {
            return
        }
        
        self.setEnableInteractiveView(false)
        self.loginWithGoogleButton.loading = true
        GIDSignIn.sharedInstance().signIn()
    }
    
    func showMainView() {
        SLTrackingEvent.sharedInstance.sendSignInWithEmailEvent(SLTrackingEvent.kSLSignUpScreen)
        self.performSegueWithIdentifier(Constants.SLIDE_MENU_SEGUE, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.SLIDE_MENU_SEGUE {
            if let sideViewController = segue.destinationViewController as? SLSideMenuViewController {
                sideViewController.showProfile = true
            }
        }
    }
}

extension SLSignUpViewController: UIGestureRecognizerDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
}

extension SLSignUpViewController {
    
    // MARK: - Facebook
    
    func loginWithFacebook(success: (() -> Void)?, failure: ((String?) -> Void)?) {
        if let _ = FBSDKAccessToken.currentAccessToken() {
            success?()
        } else {
            let loginManager = FBSDKLoginManager()
            loginManager.loginBehavior = .Native
            loginManager.logInWithReadPermissions(["email", "public_profile", "user_friends"], fromViewController: self) { (result, error) in
                if (error != nil) {
                    failure?("Error")
                } else if (result.isCancelled) {
                    failure?("Cancelled")
                } else {
                    success?()
                }
            }
        }
    }
    
    func getFacebookUser(success: ((AnyObject!) -> Void)?, failure: ((String?) -> Void)?) {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, gender, first_name, last_name, locale, email"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if (error != nil) {
                failure?("Error")
            } else {
                success?(result)
            }
        })
    }
    
}

extension SLSignUpViewController: GIDSignInUIDelegate {
    
    // MARK: - Google
    
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        
    }
    
    // Present a view that prompts the user to sign in with Google
    func signIn(signIn: GIDSignIn!, presentViewController viewController: UIViewController!) {
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!, dismissViewController viewController: UIViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension SLSignUpViewController: GIDSignInDelegate {
    
    // MARK: - GIDSignInDelegate
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if let user = user {
            let email = "\(user.profile.email)"
            let firstname = "\(user.profile.name)"
            let lastname = ""
            let googleId = "\(user.userID)"
            var image = ""
            if user.profile.hasImage {
                let imageUrl = user.profile.imageURLWithDimension(120)
                image = imageUrl.absoluteString ?? ""
            }
            
            self.userViewModel.signInWithGooglePlus(email, firstname: firstname, lastname: lastname, googleId: googleId,image: image, success: {
                self.setEnableInteractiveView(true)
                self.loginWithGoogleButton.loading = false
                self.showMainView()
                }, failure: { (error) in
                    self.setEnableInteractiveView(true)
                    self.loginWithGoogleButton.loading = false
                    // Error
                }, networkFailure: { (error) in
                    self.setEnableInteractiveView(true)
                    self.loginWithGoogleButton.loading = false
            })
        } else {
            self.setEnableInteractiveView(true)
            self.loginWithGoogleButton.loading = false
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        print("didDisconnectWithUser")
    }
    
}
