//
//  ContentNavController.swift
//  IBA Members Directory
//
//  Created by George Smith on 08/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import UIKit

class ContentNavController: UINavigationController {

    override func viewWillAppear(_ animated: Bool) {
        self.setNavigationBarHidden(false, animated: false)
    }
}
