//
//  EditMyProfileViewController.swift
//  IBA Members Directory
//
//  Created by Jacob King on 13/05/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import UIKit


protocol EditBiographyDelegate
{
    func biographyDidUpdate()
    
}

class EditMyProfileViewController: IBABaseUIViewController, UITextViewDelegate {

    @IBOutlet weak var txtBio: UITextView!
    @IBOutlet weak var lblBioCharCount: UILabel!
    @IBOutlet weak var editViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var makePublicSwitch: UISwitch!
    
    var delegate : EditBiographyDelegate!
    
    let maxCharacterCount = 1024
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myProfile = MemberProfile.getMyProfile()!
        
        if myProfile.biography != nil {
            txtBio.text = String(myProfile.biography)
        }
        textViewDidChange(txtBio)
        txtBio.becomeFirstResponder()
        makePublicSwitch.isOn = Bool(myProfile.isPublic!)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditMyProfileViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditMyProfileViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    //MARK: Button pressed methods
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
       
        Networking.updateProfileBiography(txtBio.text, completion:profileUpdateSuccess)
    }
    
    @IBAction func cancelPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        
    }
    
    
    func profileUpdateSuccess(_ success:Bool)
    {
        if success
        {
            let myProfile = MemberProfile.getMyProfile()!

            if Bool(myProfile.isPublic!) == makePublicSwitch.isOn
            {
                updateUserProfile(success)

            }
            else
            {
                Networking.changeProfilePrivacy(updateUserProfile)
            }
        }
    }
    
    func updateUserProfile(_ success:Bool)
    {
        if success
        {
            let myProfile = MemberProfile.getMyProfile()!
            myProfile.biography = txtBio.text
            myProfile.isPublic = makePublicSwitch.isOn as NSNumber?
            myProfile.commit()
            delegate.biographyDidUpdate()
            dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: UITextVewDelegate methods
    func textViewDidChange(_ textView: UITextView) {
        //Bio character limiting method.
        var charCount = textView.text.characters.count
        var charsRemaining = maxCharacterCount - charCount
        
        if charsRemaining < 0  {
            
            textView.text = textView.text.substring(to: textView.text.index(textView.text.startIndex, offsetBy: 1024))
            charCount = textView.text.characters.count
            charsRemaining = maxCharacterCount - charCount
            print("Character limit for bio reached; removing excess characters.")
        }
        
        lblBioCharCount.text = CHARACTERS_REMAINING_TEXT + "\(charsRemaining)"
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        var keyboardHeight : CGFloat
        
        if(!UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) && (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)){
            keyboardHeight = keyboardFrame.size.width
        }
        else
        {
            keyboardHeight = keyboardFrame.size.height
        }

        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.editViewBottomConstraint.constant = keyboardHeight + 20
            self.view.layoutIfNeeded()
        })
    }
    
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.editViewBottomConstraint.constant = 20
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}
