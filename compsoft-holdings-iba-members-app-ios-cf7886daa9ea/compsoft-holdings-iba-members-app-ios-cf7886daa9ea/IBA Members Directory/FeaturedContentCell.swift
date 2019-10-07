//
//  FeaturedContentCell.swift
//  IBA Members Directory
//
//  Created by George Smith on 02/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import UIKit

class FeaturedContentCell :UITableViewCell {
    
    @IBOutlet var featuredImage: UIImageView!
    @IBOutlet var featuredTitle: UILabel!
    @IBOutlet var featuredType: UILabel!
    @IBOutlet var createdTimeAgo: UILabel!
    @IBOutlet var featuredTypeImage: UIImageView!
    @IBOutlet var selectedCellView: UIView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if (selected) {
            selectedCellView.backgroundColor = schemeColour_LightBlue
        } else {
            selectedCellView.backgroundColor = UIColor.white
        }
    }
}
