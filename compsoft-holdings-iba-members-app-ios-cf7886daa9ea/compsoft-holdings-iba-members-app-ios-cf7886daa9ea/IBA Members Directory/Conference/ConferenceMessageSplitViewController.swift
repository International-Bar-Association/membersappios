//
//  ConferenceMessageSplitViewController.swift
//  IBA Members Directory
//
//  Created by George Smith on 02/08/2018.
//  Copyright © 2018 Compsoft plc. All rights reserved.
//

import Foundation

class ConferenceMessageSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        self.delegate = self
        self.preferredDisplayMode = .allVisible
    }
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        return true
    }
}
