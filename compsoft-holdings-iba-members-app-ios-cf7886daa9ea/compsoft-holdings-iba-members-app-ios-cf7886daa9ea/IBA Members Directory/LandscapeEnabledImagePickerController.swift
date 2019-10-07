//
//  LandscapeEnabledImagePickerController.swift
//  IBA Members Directory
//
//  Created by Jacob King on 15/06/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import UIKit

class LandscapeEnabledImagePickerController: UIImagePickerController {
    
    
    
    override var shouldAutorotate : Bool {
        return true
    }
    

    
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
}
