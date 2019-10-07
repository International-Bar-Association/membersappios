//
//  ProfileViewController.swift
//  IBA Members Directory
//
//  Created by Jacob King on 13/05/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import UIKit
import MessageUI

enum ProfileDisplayType: Int    {
    case myProfile = 0
    case directoryProfile = 1
    case favouriteProfile = 2
}

class ProfileViewController: IBABaseUIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, EditBiographyDelegate, EditProfilePictureDelegate {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var organisationLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var fullAddressLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var committeesTable: UITableView!
    @IBOutlet weak var areasOfPracticeTable: UITableView!
    @IBOutlet weak var committeesTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var areaOfPracticeTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
    @IBOutlet weak var biographyHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contactInfoLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var committeesLabel: UILabel!
    @IBOutlet weak var areasOfPracticeLabel: UILabel!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var editBioButton: UIButton!
    
    @IBOutlet weak var publicLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    

    var shouldShowClose = false
    
    var currentProfile : MemberProfile!
    var callGestureRecognizer: UITapGestureRecognizer!
    var emailGestureRecognizer: UITapGestureRecognizer!
    var profilePictureGestureRegognizer: UITapGestureRecognizer!
    let tableOffset = 16 as CGFloat

    
    var profileDisplayType: ProfileDisplayType = ProfileDisplayType.myProfile
    var shouldGetUpdatedProfileFromServer = true
    var fcAlert: FCAlertView!
    var blurredView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePictureGestureRegognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.profilePictureTapped))
        profilePicture.addGestureRecognizer(profilePictureGestureRegognizer)
        
        contactInfoLabel.text = CONTACT_INFO_LABEL
        bioLabel.text = BIO_LABEL
        committeesLabel.text = COMMITTEE_LABEL
        areasOfPracticeLabel.text = AREA_OF_PRACTICE_LABEL
        
        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1
        {
            areasOfPracticeTable.estimatedRowHeight = 44.0
            areasOfPracticeTable.rowHeight = UITableViewAutomaticDimension
            committeesTable.estimatedRowHeight = 44.0
            committeesTable.rowHeight = UITableViewAutomaticDimension
        }
        getUpdatedProfile()
        guard currentProfile != nil else {
            let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.logUserOut(true)
            return
        }
        
        if profileDisplayType == ProfileDisplayType.myProfile && !currentProfile.canViewProfile() {
            blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            
            
            blurredView.translatesAutoresizingMaskIntoConstraints = false
            blurredView.frame = self.view.bounds
            blurredView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.view.insertSubview(blurredView, at: 0)
            self.view.bringSubview(toFront: blurredView)
            
            fcAlert = FCAlertView()
            fcAlert.hideDoneButton = false
            fcAlert.dismissOnOutsideTouch = true
            self.view.addSubview(fcAlert)
            
            fcAlert.doneBlock = {
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
                self.present(mailController, animated: true, completion: nil)
                
            }
            
            
            fcAlert.showAlert(inView: self, withTitle: "Upgrade Membership", withSubtitle: "In order to view the profile page, you will need to upgrade your IBA membership. Upgrade now or contact the IBA for more information", withCustomImage: UIImage(named: "image_placeholder"), withDoneButtonTitle: "Upgrade!", andButtons: nil)
            
            setupView()
            reloadTableViews()
        }
        
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        if let alert = fcAlert {
         alert.dismiss()
        }
        
    }
    
    @IBAction func closeModal(_ sender: Any) {
        self.dismiss(animated: true) { 
            
        }
    }
    
    @IBAction func messageMe(_ sender: Any) {
            
            if let tabBarController = tabBarController {
                tabBarController.selectedIndex = 1
                if let splitViewController = tabBarController.selectedViewController as? SplitViewController {
                    var _P2PMessageThread = P2PMessageThread()
                    if let existingThread = P2PMessageThread.getById(threadId: currentProfile.userId) {
                        _P2PMessageThread = existingThread
                        
                    } else {
                        _P2PMessageThread.threadId = currentProfile.userId
                        
                        _P2PMessageThread.senderId = MemberProfile.getMyProfile()?.id
                        _P2PMessageThread.title = currentProfile.firstName! + " " + currentProfile.lastName! as NSString
                        _P2PMessageThread.imageURLString = currentProfile.imageURLString as! NSString
                        _P2PMessageThread.imageData = currentProfile.imageData as? Data
                        _P2PMessageThread.commit()
                    }
                    
                    if let messageNavController = splitViewController.viewControllers[0] as? UINavigationController {
                        if messageNavController.childViewControllers.count > 1 {
                            //Message Detail is showing.
                            if let meesgageNav = messageNavController.childViewControllers[1] as?  ContentNavController {
                                
                            
                            if let messageDetailViewController = meesgageNav.childViewControllers[0] as? P2PMessagesContainingViewController {
                                messageDetailViewController.messageThread = _P2PMessageThread
                                messageDetailViewController.reloadTopView()
                                messageDetailViewController.reloadMessageThread()
                            }
                            }
                        } else {
                            if let messagesViewController = messageNavController.childViewControllers[0] as? MessageListViewController {
                                
                                messagesViewController.arrivedFromPush = true
                                messagesViewController.messageIdFromPush = _P2PMessageThread.threadId as! Int
                                messagesViewController.viewAppearFromPush(isP2P: true)
                            }
                        }
                    }
                }
            }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if profileDisplayType == ProfileDisplayType.myProfile && !currentProfile.canViewProfile() {
            self.view.setNeedsUpdateConstraints()
            fcAlert = FCAlertView()
            fcAlert.hideDoneButton = false
            fcAlert.dismissOnOutsideTouch = false
            self.view.addSubview(fcAlert)
            
            
            fcAlert.doneBlock = {
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
                self.present(mailController, animated: true, completion: nil)
                
            }
            
            fcAlert.showAlert(inView: self, withTitle: "Upgrade Subscripton", withSubtitle: "Unfortunately you need to upgrade your subscription in order to view the profile page. Upgrade now or contact IBA for more information.", withCustomImage: UIImage(named: "image_placeholder"), withDoneButtonTitle: "Upgrade!", andButtons: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //getUpdatedProfile()
        if profileDisplayType == ProfileDisplayType.myProfile {
            getUpdatedProfile()
            checkForIncompleteProfile()
            NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.reloadTableViews), name: NSNotification.Name(rawValue: "UpdatedDictionariesFromServer"), object: nil)
            
        }
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
   
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        let logOut = UIAlertAction(title: "Log out", style: .destructive) { (action) in
            Networking.logout(self.userLoggedOut)
        }
        let contactUs = UIAlertAction(title: "Contact Us", style: UIAlertActionStyle.default) { (action) in
            self.contactUsHit()
        }
        
        if let presenter = actionSheet.popoverPresentationController {
            presenter.barButtonItem = self.rightBarButton
        }
        actionSheet.addAction(contactUs)
        actionSheet.addAction(logOut)
        actionSheet.addAction(cancel)
        self.present(actionSheet,animated: true)
        
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
            //Show Error
        }
    }
    
    func contactUsHit() {
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
    
    
    func getUpdatedProfile()
    {
        //only do this if we're logged in.
        if Settings.getUserAPISessionKey() != nil
        {
            if profileDisplayType == ProfileDisplayType.myProfile  {
                currentProfile = MemberProfile.getMyProfile()
                if currentProfile != nil && currentProfile.userId != nil {
                    
                    Networking.getProfileForId(currentProfile.userId, showError:false, completion: { (profile) in
                        self.receivedUpdatedMemberDetailsFromServer(profile, shouldSave: true)
                    })

                }
                
            }
            else
            {
                //if we already have the profile in db (ie its a favourite) then show this until we get back updated one from server - but we should get earlier on if we have
                let favouriteProfile = MemberProfile.getProfileForFavouriteMemberId(currentProfile.userId)
                if favouriteProfile != nil
                {
                    currentProfile = favouriteProfile
                    Networking.getProfileForId(currentProfile.userId, showError:false, completion: { (profile) in
                        self.receivedUpdatedMemberDetailsFromServer(profile, shouldSave: true)
                    })
                }
                else
                {
                    Networking.getProfileForId(currentProfile.userId,showError:false, completion: { (profile) in
                        self.receivedUpdatedMemberDetailsFromServer(profile, shouldSave: false)
                    })
                }
            }
        }
    }
    
    func checkIfProfileStillFavourite()
    {
        let favouriteProfile = MemberProfile.getProfileForFavouriteMemberId(currentProfile.userId)
        if favouriteProfile != nil
        {
            currentProfile.memberType = MemberType.memberTypeFavourite.rawValue as NSNumber
        }
        else
        {
            currentProfile.memberType = MemberType.memberTypeNone.rawValue as NSNumber
        }
    }
    
    func showSignOutDropdown() {
        
    }
    
    //MARK: Button pressed methods
    @IBAction func rightBarButtonPressed(_ sender: AnyObject) {
        switch profileDisplayType   {
            
        case .myProfile:
            showActionSheet()
            break
        case .favouriteProfile: removeCurrentMemberFromFavourites()
            
        case .directoryProfile:
            if currentProfile.memberType == MemberType.memberTypeFavourite.rawValue as NSNumber
            {
                removeCurrentMemberFromFavourites()
            }
            else
            {
                addCurrentMemberToFavourites()
            }
            break
        default:
            return
        }
    }
    
    @IBAction func editBioButtonPressed(_ sender: AnyObject) {
        
        let reachability = Reachability.forInternetConnection()
        let networkStatus = reachability?.currentReachabilityStatus().rawValue
        if networkStatus == NotReachable.rawValue
        {
            //show error
            let alert = UIAlertView(title: NO_INTERNET_TITLE_TEXT, message: NO_INTERNET_BIO_TEXT, delegate: self, cancelButtonTitle: OK_TEXT)
            alert.tag = 1
            alert.show()
            return
        }
        showEditBioView()
    }
    
    @IBAction func cameraButtonPressed(_ sender: AnyObject) {
        profilePictureTapped()
    }
    
    
    @objc func profilePictureTapped()  {
        
        if profileDisplayType == ProfileDisplayType.myProfile
        {
            let reachability = Reachability.forInternetConnection()
            let networkStatus = reachability?.currentReachabilityStatus().rawValue
            if networkStatus == NotReachable.rawValue
            {
                //show error
                let alert = UIAlertView(title: NO_INTERNET_TITLE_TEXT, message: NO_INTERNET_PHOTO_TEXT, delegate: self, cancelButtonTitle: OK_TEXT)
                alert.tag = 2
                alert.show()
                return
            }
            showPhotoActionSheet()
        }
    }
    
    @IBAction func phoneNumberPressed(_ sender: AnyObject) {
        
        let formattedNumber = (currentProfile.phoneNumber)?.replacingOccurrences(of: " ", with: "", options: [], range: nil)
        
        let alert = UIAlertView(title: formattedNumber, message: nil, delegate: self, cancelButtonTitle: "Cancel")
        alert.addButton(withTitle: "Copy")
        alert.tag = 3
        if UIDevice.current.userInterfaceIdiom == .phone {
            
            alert.addButton(withTitle: "Call")
        }
        alert.show()
    }
    
    
    
    @IBAction func emailButtonPressed(_ sender: AnyObject) {
        if !MFMailComposeViewController.canSendMail()
        {
            let alert = UIAlertView(title: NO_EMAIL_ACCOUNT_TITLE, message: NO_EMAIL_ACCOUNT_TEXT, delegate: nil, cancelButtonTitle: OK_TEXT)
            alert.show()
            return
        }
        let emailController = MFMailComposeViewController()
        emailController.mailComposeDelegate = self
        var emailToSend = currentProfile.emailAddress
        
        if emailToSend == nil  {
            emailToSend = "NO EMAIL FOR ACCOUNT"
        }
        
        emailController.setToRecipients([emailToSend!])
        emailController.setSubject(EMAIL_MEMBER_SUBJECT)
        emailController.setMessageBody("\(EMAIL_TEXT) \(fullNameLabel.text!),", isHTML: false)
        self.present(emailController, animated: true, completion: nil)
    }
    
    
    //MARK: MFMailCompsoseDelegate methods
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
    
    
    //MARK: Favourite member methods
    func addCurrentMemberToFavourites()
    {
        currentProfile.memberType = MemberType.memberTypeFavourite.rawValue as NSNumber!
        currentProfile.commit()
        GAEventManager.sendFavouriteAddedEvent()
        setRightBarButtonItem()
    }
    
    func removeCurrentMemberFromFavourites()
    {
        currentProfile.memberType = MemberType.memberTypeNone.rawValue  as NSNumber!
        if let memberProfileDatabaseEntry = MemberProfile.getProfileForFavouriteMemberId(currentProfile.userId)
        {
            memberProfileDatabaseEntry.remove()
        }
        setRightBarButtonItem()
        
        if let navController = splitViewController?.viewControllers[0] as? UINavigationController
        {
            let masterViewController : UIViewController = navController.viewControllers[0]
            if masterViewController.isKind(of: FavouritesTableViewController.self)
            {
                let favouritesTableViewController : FavouritesTableViewController = masterViewController as! FavouritesTableViewController
                favouritesTableViewController.reloadFavouritesView()
            }
        }
    }
    
    
    //MARK: Loading view methods
    func receivedUpdatedMemberDetailsFromServer(_ memberProfile: MemberProfile?, shouldSave: Bool)
    {
        if memberProfile != nil
        {
            currentProfile = memberProfile
            if shouldSave {
                currentProfile.commit()
            }
            //reload all views now we've got an updated version of member from server
            setupView()
            reloadTableViews()
        }
    }
    
    @objc func reloadTableViews()
    {
        areasOfPracticeTable.reloadData()
        committeesTable.reloadData()
        setTableHeightConstraints()
    }
    
    func setTableHeightConstraints()
    {
        areasOfPracticeTable.sizeToFit()
        committeesTable.sizeToFit()
        
        //Set both tables equal height if on iPad as next to each other
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            if areasOfPracticeTable.contentSize.height > committeesTable.contentSize.height
            {
                areaOfPracticeTableHeightConstraint.constant = areasOfPracticeTable.contentSize.height + tableOffset
                committeesTableHeightConstraint.constant = areasOfPracticeTable.contentSize.height + tableOffset
            }
            else
            {
                areaOfPracticeTableHeightConstraint.constant = committeesTable.contentSize.height + tableOffset
                committeesTableHeightConstraint.constant = committeesTable.contentSize.height + tableOffset
            }
        }
        else
        {
            areaOfPracticeTableHeightConstraint.constant = areasOfPracticeTable.contentSize.height + tableOffset
            committeesTableHeightConstraint.constant = committeesTable.contentSize.height + tableOffset
        }
    }
    
    func setupView()
    {
        
        if shouldShowClose && self.isModal() {
            
            let button1 = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeModal(_:)))
            self.navigationItem.leftBarButtonItem  = button1
        }
        if currentProfile == nil 
        {
            fullNameLabel.text = ""
            organisationLabel.text = ""
            jobTitleLabel.text = ""
            emailButton.setTitle("", for: UIControlState())
            phoneButton.setTitle("", for: UIControlState())
            bioTextView.text = ""
            fullAddressLabel.text = ""
            editBioButton.isHidden = true
            cameraButton.isHidden = true
            publicLabel.isHidden = true
            rightBarButton.image = nil
            return
        }
        
        fullNameLabel.text = "\(currentProfile.firstName!) \(currentProfile.lastName!)"
        organisationLabel.text = currentProfile.firmName as String?
        jobTitleLabel.text = currentProfile.jobPosition as String?
        
        let underlineAndBlueAttribute = [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue, NSAttributedStringKey.foregroundColor : schemeColour_LightBlue] as [NSAttributedStringKey : Any]
        if currentProfile.phoneNumber != nil
        {
            let phoneAttributedString = NSAttributedString(string: currentProfile.phoneNumber!, attributes: underlineAndBlueAttribute)
            phoneButton.setAttributedTitle(phoneAttributedString, for: UIControlState())
        }
        else
        {
            phoneButton.setTitle("", for: UIControlState())
        }
        if currentProfile.emailAddress != nil
        {
            let emailAttributedString = NSAttributedString(string: currentProfile.emailAddress as String, attributes: underlineAndBlueAttribute)
            emailButton.setAttributedTitle(emailAttributedString, for: UIControlState())
        }
        else
        {
            emailButton.setTitle("", for: UIControlState())
        }
        
        fullAddressLabel.text = currentProfile.getAddressStringForMember()
        
        bioTextView.text = currentProfile.biography as String?
        bioTextView.sizeToFit()
        if bioTextView.text != nil
        {
            biographyHeightConstraint.constant = bioTextView.frame.size.height + 15
        }
        else
        {
            biographyHeightConstraint.constant = bioTextView.frame.size.height
        }
        //self.view.layoutIfNeeded()
        //self.view.updateConstraints()
        
        
        if profileDisplayType == .myProfile
        {
            editBioButton.isHidden = false
            cameraButton.isHidden = false
            publicLabel.isHidden = false
            if Bool(currentProfile.isPublic!)
            {
                publicLabel.text = "Your Profile Is Public"
                publicLabel.textColor = UIColor.darkGreenColor()
            }
            else
            {
                publicLabel.text = "Your Profile Is Private"
                publicLabel.textColor = UIColor.darkRedColor()
                
            }
            self.navigationItem.title = "My Profile"
        }
        else
        {
            editBioButton.isHidden = true
            cameraButton.isHidden = true
            publicLabel.isHidden = true
            
        }
        
        profilePicture.image = UIImage(named: "profile_image")
        if let imageData = currentProfile.imageData {
            profilePicture.image = UIImage(data: imageData as Data)
        } else {
            profilePicture.downloadImageFrom(link: currentProfile.imageURLString as? String, contentMode: .scaleAspectFit) { (imageData) in
                if imageData != nil {
                    self.currentProfile.imageData = imageData as! NSData
                    if self.currentProfile.memberType == 1 {
                        self.currentProfile.commit()
                    }
                }
            }
        }
        
        setRightBarButtonItem()
    }
    
    func setRightBarButtonItem()
    {
        //we need to see if the profile has been unfavourited on another tab view
        if profileDisplayType != ProfileDisplayType.myProfile
        {
            checkIfProfileStillFavourite()
        }
        switch profileDisplayType   {
        case .myProfile:rightBarButton.image = UIImage(named: "more_nav")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        case .favouriteProfile:
            
            rightBarButton.image = UIImage(named: "favourites_button_active")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        default:
            if currentProfile.memberType == MemberType.memberTypeFavourite.rawValue as NSNumber
            {
                rightBarButton.image = UIImage(named: "favourites_button_active")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            }
            else
            {
                rightBarButton.image = UIImage(named: "favourites_button")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
            }
            break
        }
    }
    
    func checkForIncompleteProfile()    {
        
        if currentProfile == nil {
            return
        }
        
        if Settings.getRunCountSinceLastReminder() == 5 {
            
            var incompleteElements = [String]()
            
            if currentProfile.biography == nil  {
                incompleteElements.append(BIOGRAPHY_TEXT)
            }
            if currentProfile.imageURLString == nil   {
                incompleteElements.append(PROFILE_PICTURE_TEXT)
            }
            
            if incompleteElements.count != 0    {
                
                let reminder = UIAlertView(title: REMINDER_TEXT, message: REMINDER_MESSAGE, delegate: self, cancelButtonTitle: nil)
                reminder.tag = 2
                
                if incompleteElements.contains(BIOGRAPHY_TEXT) {
                    reminder.addButton(withTitle: ADD_MISSING_BIO)
                }
                if incompleteElements.contains(PROFILE_PICTURE_TEXT) {
                    reminder.addButton(withTitle: ADD_MISSING_PICTURE)
                }
                reminder.addButton(withTitle: REMIND_ME_LATER)
            }
            Settings.setRunCountSinceLastReminder(0)
        }   else    {
            if Settings.getRunCountSinceLastReminder() == nil   {
                Settings.setRunCountSinceLastReminder(0)
            }
            
            Settings.setRunCountSinceLastReminder(Settings.getRunCountSinceLastReminder()! + 1)
        }
        print(Settings.getRunCountSinceLastReminder())
    }
    
    func showEditBioView()
    {
        if UIDevice.current.userInterfaceIdiom == .phone    {
            performSegue(withIdentifier: "EditProfile-iPhone", sender: self)
        } else {
            performSegue(withIdentifier: "EditProfile", sender: self)
        }
    }
    
    func showPhotoActionSheet()
    {
        let photoActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        photoActionSheet.addButton(withTitle: TAKE_PHOTO)
        photoActionSheet.addButton(withTitle: CHOOSE_FROM_LIBRARY)
        photoActionSheet.tag = 1
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            var rect: CGRect!
            rect = profilePicture.convert(profilePicture.frame, to: self.view)
            photoActionSheet.show(from: rect, in: self.view, animated: true)
        }   else    {
            photoActionSheet.addButton(withTitle: CANCEL_TEXT)
            photoActionSheet.show(in: self.view)
        }
    }
    
    //MARK: EditBiographyDelegate method
    func biographyDidUpdate()
    {
        if profileDisplayType == ProfileDisplayType.myProfile  {
            currentProfile = MemberProfile.getMyProfile()
            setupView()
        }
    }
    
    //MARK: EditProfilePictureDelegate method
    func pictureUpdatedWithData(_ data: Data)
    {
        self.currentProfile.imageData = data as NSData
        self.currentProfile.commit()
        self.profilePicture.image = UIImage(data: data)
    }
    
    //MARK: UITableview datasource/delegate methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 {
            return UITableViewAutomaticDimension
        }
        
        if tableView == areasOfPracticeTable && currentProfile.areasOfPractice.count > 0
        {
            let areaOfPracticeId = currentProfile.areasOfPractice[indexPath.row] as! NSNumber
            if let areaOfPractice = AreaOfPractice.getAreaOfPracticeForId(areaOfPracticeId) as AreaOfPractice?
            {
                let rect = areaOfPractice.areaOfPracticeName.boundingRect(with: CGSize(width: areasOfPracticeTable.frame.width - CGFloat(16), height: 90), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
                return rect.height + 20
            }
            
        }
        else if tableView == committeesTable && currentProfile.committess.count > 0
        {
            let committeeId = currentProfile.committess[indexPath.row] as! NSNumber
            if let committee = Committee.getCommitteeForCommitteeId(committeeId) as Committee?
            {
                let rect = committee.committeeName.boundingRect(with: CGSize(width: committeesTable.frame.width - CGFloat(16), height: 90), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
                return rect.height + 16
            }
        }
        return 40 // Or whatever calculated value you need for cell height
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Size to fit caused crash and gave no indication as to why.
        tableView.isScrollEnabled = false
        if currentProfile != nil
        {
            if tableView == areasOfPracticeTable && currentProfile.areasOfPractice != nil
            {
                if currentProfile.areasOfPractice.count == 0
                {
                    return 1
                }
                return currentProfile.areasOfPractice.count
            }
            else if tableView == committeesTable && currentProfile.committess != nil
            {
                if currentProfile.committess.count == 0
                {
                    return 1
                }
                return currentProfile.committess.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if tableView == areasOfPracticeTable
        {
            //if no areas of practice in profile then set a cell to say none
            if currentProfile.areasOfPractice.count == 0
            {
                let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "noneCell")! as UITableViewCell
                cell.textLabel!.text = "None"
                return cell
            }
            
            let cell : AreaOfPracticeCell = tableView.dequeueReusableCell(withIdentifier: "AreaOfPracticeCell") as! AreaOfPracticeCell
            cell.bulletPointView.isHidden = true
            let areaOfPracticeId = currentProfile.areasOfPractice[indexPath.row] as! NSNumber
            
            if let areaOfPractice = AreaOfPractice.getAreaOfPracticeForId(areaOfPracticeId) as AreaOfPractice?
            {
                cell.bulletPointView.isHidden = false
                cell.titleLabel?.text = areaOfPractice.areaOfPracticeName as String
                cell.titleLabel?.lineBreakMode = .byWordWrapping
                cell.titleLabel?.numberOfLines = 0
                cell.titleLabel.sizeToFit()
            }
            return cell
        }
        
        
        //if no committees in profile then set a cell to say none
        if currentProfile.committess.count == 0
        {
            let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "noneCell")! as UITableViewCell
            cell.textLabel!.text = "None"
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommitteeCell") as! CommitteeCell
        let committeeId = currentProfile.committess[indexPath.row] as! NSNumber
        if let committee = Committee.getCommitteeForCommitteeId(committeeId) as Committee?
        {
            cell.titleLabel?.text = committee.committeeName as String
            cell.titleLabel?.lineBreakMode = .byWordWrapping
            cell.titleLabel?.numberOfLines = 0
            cell.titleLabel.sizeToFit()
            
        }
        return cell
    }
    
    
    //MARK: UIActionSheetDelegate method
    func actionSheet(_ actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        
        if actionSheet.tag == 1 {
            
            let imagePicker = LandscapeEnabledImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            
            switch buttonIndex  {
            case 0:
                
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                
            case 1:
                
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                
            default: return
            }
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    //UIAlertViewDelegate method
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.tag == 2
        {
            switch alertView.buttonTitle(at: buttonIndex)! {
                
            case ADD_MISSING_BIO:
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    
                    performSegue(withIdentifier: "EditProfile", sender: self)
                    
                } else if UIDevice.current.userInterfaceIdiom == .phone {
                    
                    performSegue(withIdentifier: "EditProfile-iPhone", sender: self)
                    
                }
                
            case ADD_MISSING_PICTURE:
                
                let imagePicker = LandscapeEnabledImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                
                switch buttonIndex  {
                case 0:
                    
                    imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                    
                case 1:
                    
                    imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                    
                default: return
                }
                present(imagePicker, animated: true, completion: nil)
                
            case REMIND_ME_LATER:
                break
                
            default:
                break
            }
        }
        else if alertView.tag == 3
        {
            if alertView.buttonTitle(at: buttonIndex) == "Copy"
            {
                let pb = UIPasteboard.general
                pb.string = alertView.title
            }
            else if alertView.buttonTitle(at: buttonIndex) == "Call"
            {
                let formattedNumber = alertView.title
                let url = URL(string: "tel://\(formattedNumber)")
                UIApplication.shared.openURL(url!)
            }
        }
    }
    
    
    //MARK: UIImagePickerControllerDelegate method
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        dismiss(animated: true, completion: { () -> Void in
            
            //let image = info[UIImagePickerControllerEditedImage] as! UIImage
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            if (picker.sourceType == UIImagePickerControllerSourceType.camera) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            
            let editPhotoNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditProfilePictureNavigationController") as! UINavigationController
            let editPhotoViewController : EditProfilePictureViewController = editPhotoNavigationController.viewControllers[0] as! EditProfilePictureViewController
            editPhotoViewController.image = image
            editPhotoViewController.delegate = self
            
            self.present(editPhotoNavigationController, animated: true, completion: nil)
            
        })
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditProfile-iPhone" || segue.identifier == "EditProfile"
        {
            let navigationController : UINavigationController = segue.destination as! UINavigationController
            let editViewController : EditMyProfileViewController = navigationController.viewControllers[0] as! EditMyProfileViewController
            editViewController.delegate = self
            
        }
    }
    
    //MARK: Delegate callback method catches the status bar changing colour and prevents it.
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if navigationController.isKind(of: UIImagePickerController.self) {
            
            let picker = navigationController as! UIImagePickerController
            
            if picker.sourceType == UIImagePickerControllerSourceType.photoLibrary  {
                
                UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.none)
                UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
                
            }
            
            
        }
        
    }
    
}
