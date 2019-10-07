//
//  ContentViewCell.swift
//  IBA Members Directory
//
//  Created by George Smith on 02/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import UIKit

class ContentViewCell: UITableViewCell {
    
    @IBOutlet var contentImage: UIImageView!
    @IBOutlet var contentTitle: UILabel!
    @IBOutlet var contentTypeImage: UIImageView!
    @IBOutlet var contentType: UILabel!
    @IBOutlet var contentUpdatedTimeAgo: UILabel!
    @IBOutlet var selectedIndicatorView: UIView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if (selected) {
            selectedIndicatorView.backgroundColor = schemeColour_LightBlue
        } else {
            selectedIndicatorView.backgroundColor = UIColor(red: 245, green: 245, blue: 245)
        }
    }
}
