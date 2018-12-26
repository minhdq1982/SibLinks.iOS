//
//  SLForgotPasswordViewController.swift
//  SibLinks
//
//  Created by Jana on 9/5/16.
//  Copyright © 2016 SibLinks Inc. All rights reserved.
//

import UIKit
import SDCAlertView

class SLForgotPasswordViewController: SLBaseViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView! {
        didSet {
            // Set background image view
            if let imagePath = NSBundle.mainBundle().pathForResource("signup-background", ofType: "jpg") {
                backgroundImageView.image = UIImage(contentsOfFile: imagePath)
            }
        }
    }
    
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            backButton.addTarget(self, action: #selector(self.backAction), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var emailTextField: FloatingLabelTextFieldWithIcon! {
        didSet {
            emailTextField.iconFont = UIFont.init(name: "FontAwesome", size: 15)
            emailTextField.iconText = "\u{f007}"
            emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        }
    }
    
    @IBOutlet weak var sendRequestNewPasswordButton: LoadingButton! {
        didSet {
            sendRequestNewPasswordButton.setActivityIndicatorAlignment(ActivityIndicatorAlignment.Center)
            sendRequestNewPasswordButton.addTarget(self, action: #selector(self.requestNewPasswordAction), forControlEvents: .TouchUpInside)
        }
    }
    
    let userViewModel = SLUserViewModel.sharedInstance
    
    var trackingEmailTextField: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Interactive
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SLForgotPasswordViewController {
    
    // MARK: - Configure view
    
    override func configView() {
        super.configView()
        
        self.title = "Forgot Password".localized
        
        let touchOnScreen = UITapGestureRecognizer(target: self, action: #selector(self.touchOnScreenAction))
        self.view.addGestureRecognizer(touchOnScreen)
    }
    
}

extension SLForgotPasswordViewController: UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        switch textField {
        case self.emailTextField:
            self.trackingEmailTextField = true
            if !self.emailTextField.text!.isEmail() {
                self.emailTextField.lineColor = colorFromHex(Constants.SIBLINKS_TEXTFIELD_RED_COLOR)
            } else {
                self.emailTextField.lineColor = colorFromHex(Constants.SIBLINKS_COMMON_HEX_COLOR)
            }
        default:
            return
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
}

extension SLForgotPasswordViewController {
    
    // MARK: - Textfield did change
    
    func textFieldDidChange(textField: UITextField) {
        switch textField {
        case self.emailTextField:
            if self.trackingEmailTextField {
                if !self.emailTextField.text!.isEmail() {
                    self.emailTextField.lineColor = colorFromHex(Constants.SIBLINKS_TEXTFIELD_RED_COLOR)
                } else {
                    self.emailTextField.lineColor = colorFromHex(Constants.SIBLINKS_COMMON_HEX_COLOR)
                }
            }
            
        default:
            return
        }
    }
}

extension SLForgotPasswordViewController {
    
    // MARK: - Actions
    
    func touchOnScreenAction() {
        self.emailTextField.resignFirstResponder()
    }
    
    func backAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func requestNewPasswordAction() {
        self.touchOnScreenAction()
        
        if self.sendRequestNewPasswordButton.loading {
            return
        }
        
        guard self.emailTextField.text?.characters.count > 0 else {
            Constants.showAlert("SibLinks", message: "Please enter your email.", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
            return
        }
        
        guard self.emailTextField.text!.isEmail() else {
            Constants.showAlert("SibLinks", message: "Email is not valid.", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred))
            return
        }
        
        let email = self.emailTextField.text ?? ""
        sendRequestNewPasswordButton.loading = true
        self.userViewModel.forgotPassword(email, success: { 
            self.sendRequestNewPasswordButton.loading = false
            Constants.showAlert("SibLinks", message: "Password has been sent to your email!", actions: AlertAction(title: Constants.OK_ALERT_BUTTON, style: .Preferred, handler: { (_) in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            self.navigationController?.popViewControllerAnimated(true)
            }, failure: { (error) in
                self.sendRequestNewPasswordButton.loading = false
                ErrorHandlingController.handleAPIError(error)
            }, networkFailure: { (error) in
                self.sendRequestNewPasswordButton.loading = false
                ErrorHandlingController.handleNetworkError(error)
        })
    }
    
}

extension SLForgotPasswordViewController: UIGestureRecognizerDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
}
