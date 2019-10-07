//
//  NoContentMessagesViewController.swift
//  IBA Members Directory
//
//  Created by George Smith on 27/06/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import Foundation


class NoContentMessagesViewController: UIViewController {
    var labelText:String!
    @IBOutlet weak var noContentMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if labelText != nil {
            noContentMessageLabel.text = labelText
            noContentMessageLabel.alpha = 1.0
        } else {
            noContentMessageLabel.alpha = 0.0
        }

    }
}
