//
//  LoginViewController.swift
//  IBA Members Directory
//
//  Created by Jacob King on 14/05/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import UIKit
import AirshipKit
import MessageUI

class LoginViewController: IBABaseUIViewController, MFMailComposeViewControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var contactIBAButton: UIButton!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var loggingInView: UIView!
    @IBOutlet weak var loginObjectViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginObjectView: UIView!
    @IBOutlet weak var rememberLoginDetailsSwitch: UISwitch!
    
    var hasJustUpdated = false
    var keyboardShowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        emailTextField.placeholder = LOGIN_USERNAME_PLACEHOLDER_TEXT
        passwordTextField.placeholder = LOGIN_PASSWORD_PLACEHOLDER_TEXT
        loginButton.setTitle(LOGIN_BUTTON_TEXT, for: UIControlState())
        contactIBAButton.setTitle(CONTACT_IBA_BUTTON_TEXT, for: UIControlState())
        redrawViewForNoKeyboardForOrientation(UIApplication.shared.statusBarOrientation)

        rememberLoginDetailsSwitch.isOn = Settings.getRememberLoginDetails()
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if rememberLoginDetailsSwitch.isOn || hasJustUpdated
        {
            emailTextField.text = Settings.getUserEmail()
            passwordTextField.text = Settings.getUserPassword()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillChange(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
       // redrawViewForNoKeyboardForOrientation(UIApplication.sharedApplication().statusBarOrientation)
    }
    
    @IBAction func rememberLoginSwitchChanged(_ sender: UISwitch) {
        Settings.setRememberLoginDetails(sender.isOn)
    }
    
    
    //MARK: Button pressed methods
    @IBAction func loginPressed(_ sender: AnyObject) {
        
        validateTextFieldsAndLogIn()
    }
    
    func didLogIn(_ successful: Bool)
    {
        if successful
        {
            Settings.setUserEmail(emailTextField.text)
            Settings.setUserPassword(passwordTextField.text)
            Settings.setIsLoggedIn(true)
            //dismissViewControllerAnimated(true, completion: nil)
            let vc = self.storyboard?.instantiateInitialViewController()
            present(vc!, animated: true, completion: { 
                Networking.refreshDictionariesAndCheckForConference()
                UAirship.namedUser().identifier = "\(Settings.getUserId())"
                UAirship.push().updateRegistration()
                Networking.configurePushDeviceToken({ 
                    print("Configured push for user")
                })
            })
        }
        else
        {
            let alert = UIAlertView(title: ERROR_TEXT, message: LOGIN_ERROR_MESSAGE_TEXT, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            Settings.setIsLoggedIn(false)
        }
        
        dimView.isHidden = true
        loggingInView.isHidden = true
        UIApplication.shared.endIgnoringInteractionEvents()
        
    }
    
    @IBAction func contactIBAPressed(_ sender: AnyObject) {
        
        if !MFMailComposeViewController.canSendMail()
        {
            let alert = UIAlertView(title: NO_EMAIL_ACCOUNT_TITLE, message: NO_EMAIL_ACCOUNT_TEXT, delegate: nil, cancelButtonTitle: OK_TEXT)
            alert.show()
            return
        }
        let mailController = MFMailComposeViewController()
        mailController.setToRecipients([NSString(string: "member@int-bar.org") as String])
        mailController.setSubject(EMAIL_IBA_SUBJECT)
        mailController.mailComposeDelegate = self
        
        present(mailController, animated: true, completion: nil)
        
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        print("Forgot password")
        UIApplication.shared.openURL(URL(string: "https://www.ibanet.org/Access/ForgottenDetails.aspx")!)
    }
    
    func validateTextFieldsAndLogIn()
    {
        if emailTextField.text == ""
        {
            let alert = UIAlertView(title: NO_EMAIL_ADDRESS_TITLE_ERROR, message: NO_EMAIL_ADDRESS_MESSAGE_ERROR, delegate: nil, cancelButtonTitle: OK_TEXT)
            alert.show()
        }
        else if passwordTextField.text == ""
        {
            let alert = UIAlertView(title: NO_PASSWORD_TITLE_ERROR, message: NO_PASSWORD_MESSAGE_ERROR, delegate: nil, cancelButtonTitle: OK_TEXT)
            alert.show()
        }
        else
        {
            Networking.loginWithUsernameAndPassword(emailTextField.text!, password: passwordTextField.text!, completion: didLogIn)
            passwordTextField.resignFirstResponder()
            dimView.isHidden = false
            loggingInView.isHidden = false
            UIApplication.shared.beginIgnoringInteractionEvents()
            
        }
    }
    
    //MARK: MFMailComposeViewControllerDelegate methods
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Mail cancelled")
        case MFMailComposeResult.saved.rawValue:
            print("Mail saved")
        case MFMailComposeResult.sent.rawValue:
            print("Mail sent")
        case MFMailComposeResult.failed.rawValue:
            print("Mail sent failure: %@", [error!.localizedDescription])
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: UITextFieldDelegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField
        {
            passwordTextField.becomeFirstResponder()
        }
        else
        {
            loginPressed(self)
        }
        return true
    }
    
    @objc func keyboardWillChange(_ notification: Notification) {
        
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        var newScreenHeight : CGFloat
        if(!UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) && (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)){
            newScreenHeight = view.frame.size.width - keyboardFrame.size.width
        }
        else
        {
             newScreenHeight = view.frame.size.height - keyboardFrame.size.height
        }
        let screenHeightMinusLoginView = newScreenHeight - loginObjectView.bounds.size.height
        moveLoginViewToMiddle(screenHeightMinusLoginView/2)
        keyboardShowing = true
    }
    
    
    @objc func keyboardWillHide()
    {
        redrawViewForNoKeyboardForOrientation(UIApplication.shared.statusBarOrientation)
        keyboardShowing = false
    }
    
    func redrawViewForNoKeyboardForOrientation(_ orientation: UIInterfaceOrientation) {
        
        var screenHeight : CGFloat
        
        if !UIInterfaceOrientationIsPortrait(orientation) && (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)
        {
            screenHeight = view.frame.size.width
        }
        else
        {
            screenHeight = view.frame.size.height
        }

        moveLoginViewToMiddle((screenHeight - loginObjectView.frame.size.height)/2)

    }
    
    func moveLoginViewToMiddle(_ topHeightConstraintSize: CGFloat )
    {
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            
            //if view is gonna be offscreen then pin to top
            if topHeightConstraintSize < 44
            {
                self.loginObjectViewTopConstraint.constant = 22
            }
            else
            {
                self.loginObjectViewTopConstraint.constant = topHeightConstraintSize - 22
            }
            self.view.layoutIfNeeded()
            self.view.updateConstraints()
        })
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if !keyboardShowing
        {
            moveLoginViewToMiddle((size.height - loginObjectView.frame.size.height)/2)
        }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if !keyboardShowing
        {
            redrawViewForNoKeyboardForOrientation(toInterfaceOrientation)
        }
    }
    
    
}
