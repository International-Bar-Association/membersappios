//
//  ListCell.swift
//  IBA Members Directory
//
//  Created by Jacob King on 18/05/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import UIKit

class ListCell: UITableViewCell {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var organisationLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var fullAddressLabel: UILabel!
    @IBOutlet weak var selectedIndicatorView: UIView!
    @IBOutlet weak var isAtConferenceImage: UIImageView!
    
    
    override func awakeFromNib() {
        selectionStyle = UITableViewCellSelectionStyle.none

    }
    
    func initialiseCell(_ member : MemberProfile) -> ListCell  {
        
        backgroundColor = UIColor.clear
        fullNameLabel.text = member.firstName as String + " " + (member.lastName as String)
        
        organisationLabel.text = ""
        jobTitleLabel.text = ""
        fullAddressLabel.text = ""

        organisationLabel.text = member.firmName as? String
        if let position = member.jobPosition as? String {
            jobTitleLabel.text = position
        }
        
        fullAddressLabel.text = member.getAddressStringForMember()
        
        
        profilePicture.image = UIImage(named: "profile_image")
        if let image = member.getImageForUser()
        {
            profilePicture.image = image
            
        } else {
            profilePicture.downloadImageFrom(link: member.imageURLString! as String, contentMode: .scaleAspectFit, completion: { (data) in
                if data != nil {
                    member.imageData = data as! NSData
                }
            })
        }
        
        if member.currentConference != nil {
            isAtConferenceImage.alpha = 0.0
        }else {
            isAtConferenceImage.alpha = 0.0
        }
        
        return self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if (selected) {
            selectedIndicatorView.backgroundColor = schemeColour_LightBlue
        } else {
            selectedIndicatorView.backgroundColor = UIColor(red: 245, green: 245, blue: 245)
        }
    }
    
}
