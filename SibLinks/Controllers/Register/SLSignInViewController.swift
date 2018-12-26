//
//  SLSignInViewController.swift
//  SibLinks
//
//  Created by Jana on 9/5/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import SDCAlertView
import FBSDKLoginKit
import GoogleSignIn
import Moya

class SLSignInViewController: SLBaseViewController {

    @IBOutlet weak var backgroundImageView: UIImageView! {
        didSet {
            // Set background image view
            if let imagePath = NSBundle.mainBundle().pathForResource("signin-background", ofType: "jpg") {
                backgroundImageView.image = UIImage(contentsOfFile: imagePath)
            }
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            
        }
    }
    
    // Set up email text field
    @IBOutlet weak var emailTextField: FloatingLabelTextFieldWithIcon! {
        didSet {
            emailTextField.iconFont = Constants.fontAwesomeOfSize(15)
            emailTextField.iconText = Constants.EMAIL_ICON
            emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        }
    }
    
    // Set up password text field
    @IBOutlet weak var passwordTextField: FloatingLabelTextFieldWithIcon! {
        didSet {
            passwordTextField.iconFont = Constants.fontAwesomeOfSize(15)
            passwordTextField.iconText = Constants.PASSWORD_ICON
            passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        }
    }
    
    @IBOutlet weak var forgotPasswordButton: UIButton! {
        didSet {
            forgotPasswordButton.addTarget(self, action: #selector(self.forgotPasswordAction), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var loginButton: LoadingButton! {
        didSet {
            loginButton.setActivityIndicatorAlignment(ActivityIndicatorAlignment.Center)
            loginButton.addTarget(self, action: #selector(self.loginAction), forControlEvents: .TouchUpInside)
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
    
    @IBOutlet weak var createAnAccountButton: UIButton!
    
    let userViewModel = SLUserViewModel.sharedInstance
    
    var activeTextField: UITextField?
    var trackingEmailTextField: Bool = false
    var trackingPasswordTextField: Bool = false
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !Constants.appDelegate().appLauched {
            // Add splash screen if sign in lauched first
            addSplashScreen()
            Constants.appDelegate().appLauched = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Set default color status bar
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        
        // Register For Keyboard Notifications
        self.registerForKeyboardNotifications()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        touchOnScreenAction()
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
}

extension SLSignInViewController {

    // MARK: - Configure view
    
    override func configView() {
        self.navigationController?.navigationBarHidden = true
        
        let touchOnScreen = UITapGestureRecognizer(target: self, action: #selector(self.touchOnScreenAction))
        self.view.addGestureRecognizer(touchOnScreen)
        
        self.interactiveViewArray = [self.emailTextField, self.passwordTextField, self.forgotPasswordButton, self.loginButton, self.loginWithFacebookButton, self.loginWithGoogleButton, self.createAnAccountButton]
    }
    
}

extension SLSignInViewController {
    
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

extension SLSignInViewController: UITextFieldDelegate {

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
                self.emailTextField.errorMessage = "Invalid email".localized
                self.emailTextField.lineColor = colorFromHex(Constants.SIBLINKS_TEXTFIELD_RED_COLOR)
            } else {
                self.emailTextField.errorMessage = ""
                self.emailTextField.lineColor = colorFromHex(Constants.SIBLINKS_COMMON_HEX_COLOR)
            }
        case self.passwordTextField:
            self.trackingPasswordTextField = true
            if self.passwordTextField.text!.characters.count < 6 {
                self.passwordTextField.errorMessage = "Invalid password".localized
                self.passwordTextField.lineColor = colorFromHex(Constants.SIBLINKS_TEXTFIELD_RED_COLOR)
            } else {
                self.passwordTextField.errorMessage = ""
                self.passwordTextField.lineColor = colorFromHex(Constants.SIBLINKS_COMMON_HEX_COLOR)
            }
        default:
            return
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case self.emailTextField:
            self.passwordTextField.becomeFirstResponder()
        default:
            self.loginAction()
        }
        return true
    }
}

extension SLSignInViewController {

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
            if self.trackingPasswordTextField {
                if self.passwordTextField.text!.characters.count < 6 && self.trackingPasswordTextField {
                    self.passwordTextField.errorMessage = "Invalid password".localized
                    self.passwordTextField.lineColor = colorFromHex(Constants.SIBLINKS_TEXTFIELD_RED_COLOR)
                } else {
                    self.passwordTextField.errorMessage = ""
                    self.passwordTextField.lineColor = colorFromHex(Constants.SIBLINKS_COMMON_HEX_COLOR)
                }
            }
        default:
            return
        }
    }
    
}

extension SLSignInViewController {
    
    // MARK: - Actions
    
    func touchOnScreenAction() {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    func forgotPasswordAction() {
        
    }
    
    func loginAction() {
        self.touchOnScreenAction()
        if self.loginButton.loading {
            return
        }
        guard self.emailTextField.text?.characters.count > 0 && self.passwordTextField.text?.characters.count > 0 else {
            Constants.showAlert("SibLinks", message: "Please enter email and password.", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
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
        
        let email = self.emailTextField.text ?? ""
        let password = self.passwordTextField.text ?? ""
        
        // Enable loading and disable ui control
        self.loginButton.loading = true
        self.setEnableInteractiveView(false)
        self.userViewModel.signInWithEmail(email, password: password, success: { 
            // Disable loading and enable ui control
            self.loginButton.loading = false
            self.setEnableInteractiveView(true)
            if (self.userViewModel.currentUser != nil) {
                switch self.userViewModel.currentUser?.status?.lowercaseString ?? "" {
                case "true":
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    self.showMainView()
                default:
                    Constants.showAlert("SibLinks", message: "Failure!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
                }
            } else {
                Constants.showAlert("SibLinks", message: "Missing user info!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
            }
            }, failure: { (error) in
                self.loginButton.loading = false
                self.setEnableInteractiveView(true)
                ErrorHandlingController.handleAPIError(error)
            }, networkFailure: { (error) in
                self.loginButton.loading = false
                self.setEnableInteractiveView(true)
                ErrorHandlingController.handleNetworkError(error)
        })
    }
    
    func loginWithFacebookAction() {
        if self.loginWithFacebookButton.loading {
            return
        }
        
        self.loginWithFacebookButton.loading = true
        self.setEnableInteractiveView(false)
        self.loginWithFacebook({
            self.getFacebookUser({ (result) in
                
                let email = (result?.objectForKey("email") as? String) ?? (result?.objectForKey("id") as? String) ?? ""
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
                        
                        Constants.showAlert(Constants.APP_NAME_ALERT_TITLE, message: "You cannot sign in at this time!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
                    }, networkFailure: { (error) in
                        self.setEnableInteractiveView(true)
                        self.loginWithFacebookButton.loading = false
                })
                }, failure: { (error) in
                    self.setEnableInteractiveView(true)
                    self.loginWithFacebookButton.loading = false
                    
                    Constants.showAlert(Constants.APP_NAME_ALERT_TITLE, message: "You cannot sign in at this time!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
            })
        }) { (error) in
            self.setEnableInteractiveView(true)
            self.loginWithFacebookButton.loading = false
            
            Constants.showAlert(Constants.APP_NAME_ALERT_TITLE, message: "You cannot sign in at this time!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
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
    
    func createAnAccountAction() {
        // Fix when show sign up and listener google sign in API
        GIDSignIn.sharedInstance().uiDelegate = nil
        GIDSignIn.sharedInstance().delegate = nil

        self.performSegueWithIdentifier(Constants.SIGN_OUT_SEGUE, sender: nil)
    }
    
    func showMainView() {
        SLTrackingEvent.sharedInstance.sendSignInWithEmailEvent(SLTrackingEvent.kSLSignInScreen)
        self.performSegueWithIdentifier(Constants.SLIDE_MENU_SEGUE, sender: nil)
    }
}

extension SLSignInViewController: GIDSignInUIDelegate {
    
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

extension SLSignInViewController: GIDSignInDelegate {
    
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
            
            self.userViewModel.signInWithGooglePlus(email, firstname: firstname, lastname: lastname, googleId: googleId, image: image, success: {
                self.setEnableInteractiveView(true)
                self.loginWithGoogleButton.loading = false
                self.showMainView()
                }, failure: { (error) in
                    self.setEnableInteractiveView(true)
                    self.loginWithGoogleButton.loading = false
                    
                    Constants.showAlert(Constants.APP_NAME_ALERT_TITLE, message: "You cannot sign in at this time!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
                }, networkFailure: { (error) in
                    self.setEnableInteractiveView(true)
                    self.loginWithGoogleButton.loading = false
            })
        } else {
            self.setEnableInteractiveView(true)
            self.loginWithGoogleButton.loading = false
            
            Constants.showAlert(Constants.APP_NAME_ALERT_TITLE, message: "You cannot sign in at this time!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        print("didDisconnectWithUser")
    }
    
}

extension SLSignInViewController {

    // MARK: - Facebook
    
    func loginWithFacebook(success: (() -> Void)?, failure: ((String?) -> Void)?) {
        if let _ = FBSDKAccessToken.currentAccessToken() {
            success?()
        } else {
            let loginManager = FBSDKLoginManager()
            loginManager.loginBehavior = .Native
            loginManager.logInWithReadPermissions(["email", "public_profile", "user_friends"], fromViewController: self) { (result, error) in
                if (error != nil) {
                    failure?("Error: \(error)")
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
