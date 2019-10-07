//
//  P2PMessageTableViewCell.swift
//  IBA Members Directory
//
//  Created by George Smith on 27/03/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import UIKit

class P2PMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var lastMessageText: UILabel!
    @IBOutlet weak var atConferenceButton: UIImageView!
    @IBOutlet weak var selectedIndicatorView: UIView!
    @IBOutlet weak var newMessageIndicator: UIImageView!
    @IBOutlet weak var roundedView: UIView!
    
    
    var message: MessageListProtocol!
 
    func createFromMessage(_ message: inout MessageListProtocol) {
        self.message = message
        self.userLabel.text = message.title != nil ? message.title as String : ""
        let messageText = message.lastSentMessageData?.text
        let messageDate = message.lastSentMessageData?.timeSent
        if let message = messageText  {
            self.lastMessageText.text = message as String
        } else {
            self.lastMessageText.text = ""
        }
        
        if messageDate != nil {
            if Date().daysFrom(messageDate!) > 0 {
                self.time.text = messageDate!.toTimeString("dd/MM/yyyy")
            } else {
                self.time.text = Date().offsetFrom(messageDate!)
            }
        } else {
            self.time.text = ""
        }
        
        if message.imageData == nil {
            if message.imageURLString != nil {
                if message.imageURLString != "N/A" {
                    profileImage.image = #imageLiteral(resourceName: "icon_profile_image_placeholder_rome")
                    var mess = message
                    
                    if let imgUrl = message.imageURLString, let url = URL.cleaned(root: PROFILE_IMAGE_LOCATION, path: imgUrl as String) {
                    
                        profileImage.downloadImageFrom(url: url, contentMode: .scaleAspectFit, completion: { (data) in
                            if let imageData = data {
                                mess.imageData = imageData
                                DispatchQueue.main.async {
                                    self.profileImage.image = UIImage(data:imageData)
                                }
                            }
                           
                        })
                    }
                } else {
                    profileImage.image = #imageLiteral(resourceName: "icon_profile_image_placeholder_rome")
                }
            } else {
                profileImage.image = #imageLiteral(resourceName: "icon_profile_image_placeholder_rome")
            }
        } else {
            profileImage.image = UIImage(data: message.imageData)
        }
        
        if message.getHasBeenRead() {
            newMessageIndicator.alpha = 0.0
        } else {
            newMessageIndicator.alpha = 1.0
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if (selected) {
            selectedIndicatorView.backgroundColor = schemeColour_LightBlue
        } else {
            selectedIndicatorView.backgroundColor = UIColor(red: 245, green: 245, blue: 245)
        }
    }

}

protocol ViewProfileDelegate {
    func didWantToViewProfile(memberId: NSNumber)
}

class ConferenceDirectorySearchTableViewCell: P2PMessageTableViewCell {

    @IBOutlet weak var viewProfileButton: UIButton!
    
    var viewProfileDelegate: ViewProfileDelegate!
    var memberId:  NSNumber!
    
    func setup(attendee: Attendee, delegate: ViewProfileDelegate) {
        self.memberId = attendee.attendeeId
        self.viewProfileDelegate = delegate
        createFromMemberProfile(attendee)
    }
    
    func createFromMemberProfile (_ profile: Attendee){
        userLabel.text = "\(profile.firstName ?? "") \(profile.lastName ?? "")"
        lastMessageText.text = "\(profile.firmName ?? "")"
        if profile.profilePicture != nil {
            if profile.profilePicture != "N/A" {
                profileImage.image = #imageLiteral(resourceName: "icon_profile_image_placeholder_rome")
                //var mess = message
                
                if let imgUrl = profile.profilePicture, let url = URL.cleaned(root: PROFILE_IMAGE_LOCATION, path: imgUrl as String) {
                
                    profileImage.downloadImageFrom(url: url, contentMode: .scaleAspectFit, completion: { (data) in
                        if let imageData = data {
                            DispatchQueue.main.async {
                                self.profileImage.image = UIImage(data:imageData)
                            }
                            
                        }
                    })
                }
            } else {
                profileImage.image = #imageLiteral(resourceName: "icon_profile_image_placeholder_rome")
            }
        } else {
            profileImage.image = #imageLiteral(resourceName: "icon_profile_image_placeholder_rome")
        }
    }

    
    override func awakeFromNib() {
        self.roundedView.clipsToBounds = true
        self.roundedView.layer.cornerRadius = 20
        self.selectedIndicatorView.clipsToBounds = true
        self.selectedIndicatorView.layer.cornerRadius = 20
    }
    
    @IBAction func viewProfileHit(_ sender: Any) {
        viewProfileDelegate.didWantToViewProfile(memberId: self.memberId)
    }
}

class ConferenceP2PMessageTableViewCell: P2PMessageTableViewCell {
    
    override func awakeFromNib() {
        self.roundedView.clipsToBounds = true
        self.roundedView.layer.cornerRadius = 20
        self.selectedIndicatorView.clipsToBounds = true
        self.selectedIndicatorView.layer.cornerRadius = 20
    }
}

class ConferenceNoFoundEntriesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var noDataText: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    enum EntryType {
        case directory
        case threads
        
        var image: UIImage {
            get {
                switch self {
                case .directory:
                    return #imageLiteral(resourceName: "icon_profile_image_placeholder_rome")
                case .threads:
                    return #imageLiteral(resourceName: "icon_no_conversations")
                }
            }
        }
        var text: NSAttributedString {
            get {
                switch self {
                case .directory:
                    let titleString = "Sorry, contact not found.\n\n".toAttributedString(withColour: UIColor(hex: "7F7F7F"), andFont: Fonts.regular(.regular))
                    let subtitle = "There are no members attending the conference with that name.".toAttributedString(withColour: UIColor(hex: "7F7F7F"), andFont: Fonts.smallHalf(.regular))
                    var mutStr = NSMutableAttributedString(attributedString: titleString)
                    mutStr.append(subtitle)
                    return mutStr
                    
                case .threads:
                    return "You have no conversations yet, search for a contact to start one".toAttributedString(withColour: UIColor(hex: "7F7F7F"))
                }
            }
        }
    }
    
    
    func setup(type: EntryType) {
        switch type {
        case .directory:
            noDataText.attributedText = type.text
            noDataText.setNeedsDisplay()
            icon.image = type.image
            icon.tintColor = Settings.getConferenceSecondaryColour()
            return
        case .threads:
            noDataText.attributedText = type.text
            noDataText.setNeedsDisplay()
            icon.image = type.image
            return
        }
    }
}
