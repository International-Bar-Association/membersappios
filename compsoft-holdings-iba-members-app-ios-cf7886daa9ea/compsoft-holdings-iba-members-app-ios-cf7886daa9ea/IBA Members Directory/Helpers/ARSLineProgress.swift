//
//  ARSLineProgressCustom.swift
//  thomas-higgins
//
//  Created by George Smith on 16/11/2017.
//  Copyright © 2017 Thomas Higgins. All rights reserved.
//

import Foundation
import ARSLineProgress

extension ARSLineProgress {
    
    static func showWithProgressObjectBlocking(view: UIView?, _ progress: Progress, completionBlock: (() -> Void)?)  {
        if view != nil {
            view?.isUserInteractionEnabled = false
            ARSLineProgress.showWithProgressObject(progress, onView: view!, completionBlock: { 
                view?.isUserInteractionEnabled = true
                if completionBlock != nil {
                    completionBlock!()
                }
            })
        } else {
            UIApplication.shared.windows.first?.isUserInteractionEnabled = false
            ARSLineProgress.showWithProgressObject(progress) {
                //iew.isUserInteractionEnabled = true
                UIApplication.shared.windows.first?.isUserInteractionEnabled = true
                if completionBlock != nil {
                    completionBlock!()
                }
            }
        }
    }
    
    static func showBlocking(view: UIView?, completionBlock: (() -> Void)?)  {
        if view != nil {
            view?.isUserInteractionEnabled = false
           ARSLineProgress.show()
            
        } else {
            ARSLineProgress.show()
        }
    }
    
    static func hideBlocking(view: UIView?, completionBlock: (() -> Void)?)  {
        if view != nil {
            view?.isUserInteractionEnabled = true
            ARSLineProgress.hide()
            
        } else {
            ARSLineProgress.hide()
        }
    }
    
    static func cancelProgressWithFailAnimationBlocking(_ view: UIView?, showFail: Bool, completionBlock: (() -> Void)?) {
        
       ARSLineProgress.cancelProgressWithFailAnimation(showFail) {
        
            if view != nil {
                view?.isUserInteractionEnabled = true
            } else {
                UIApplication.shared.windows.first?.isUserInteractionEnabled = true
            }
        
            guard let block = completionBlock else {
                return
            }
        
            block()
        }
    }
}
