//
//  ConferenceSplitViewController.swift
//  IBA Members Directory
//
//  Created by George Smith on 16/03/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import UIKit

class ConferenceSplitViewController: UISplitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredDisplayMode = .allVisible
        guard let scheduleVC =  viewControllers.first as? ConferenceScheduleTableViewController else {
            return
        }
        if let vc =  viewControllers.last as? ConferenceMapViewController {
            vc.showContainerView = false
            scheduleVC.delegate = vc
        }
        
    }
}
