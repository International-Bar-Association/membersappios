//
//  LoadingCell.swift
//  IBA Members Directory
//
//  Created by Louisa Mousley on 04/06/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import Foundation
import UIKit

class LoadingCell : UITableViewCell
{
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.loadingActivityIndicator.startAnimating()
    }
    
    override func prepareForReuse() {
        super.layoutSubviews()
        self.loadingActivityIndicator.stopAnimating()
    }

}
