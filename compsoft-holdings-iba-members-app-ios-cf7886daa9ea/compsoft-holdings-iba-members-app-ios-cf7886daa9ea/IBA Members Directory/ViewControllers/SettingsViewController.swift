//
//  SettingsViewController.swift
//  IBA Members Directory
//
//  Created by Jacob King on 13/05/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: IBABaseUIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var contactIBAButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var versionNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = SETTINGS_TEXT

        versionLabel.text = VERSION_LABEL
        contactIBAButton.setTitle(CONTACT_IBA_BUTTON_TEXT, for: UIControlState())
        signOutButton.setTitle(SIGN_OUT_BUTTON_TEXT, for: UIControlState())

        let buildNumberString = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let versionNumberString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String

        versionNumberLabel.text = "\(versionNumberString).\(buildNumberString)"

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
    
    @IBAction func signOutButtonPressed(_ sender: AnyObject) {
        Networking.logout(userLoggedOut)
    }
    
    func userLoggedOut(_ loggedOutSuccessful : Bool)
    {
        if loggedOutSuccessful
        {
            let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.logUserOut(true)
        }
        else
        {
            //TODO: LKM show error
        }
    }
}
