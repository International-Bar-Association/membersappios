//
//  EditProfilePictureViewController.swift
//  IBA Members Directory
//
//  Created by Louisa Mousley on 08/06/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol EditProfilePictureDelegate
{
    func pictureUpdatedWithData(_ data: Data)
}

class EditProfilePictureViewController : UIViewController
{
    
    @IBOutlet weak var indicatorView: UIView!
    var imageView: UIImageView?
    var image : UIImage!
    var delegate : EditProfilePictureDelegate!
    var center: CGPoint!
    
    @IBOutlet weak var indicatorViewVerticalInsetTop: NSLayoutConstraint!
    @IBOutlet weak var indicatorViewVerticalInsetBottom: NSLayoutConstraint!
    @IBOutlet weak var spaceView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicatorView.layer.borderColor = UIColor.white.cgColor
        indicatorView.layer.borderWidth = 8
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(EditProfilePictureViewController.didPan(_:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(EditProfilePictureViewController.didPinch(_:)))
        
        indicatorView.addGestureRecognizer(pan)
        indicatorView.addGestureRecognizer(pinch)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        imageView = UIImageView()
        imageView?.image = image
        
        
        imageView!.frame = AVMakeRect(aspectRatio: image.size, insideRect: indicatorView.frame)
        
        center = imageView!.center
        
        spaceView.insertSubview(imageView!, belowSubview: indicatorView)
    }
    
    @objc func didPan(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: spaceView)
        //  imageView!.center = CGPoint(x:imageView!.center.x + translation.x, y:imageView!.center.y + translation.y)
        
        if (imageView!.frame.minX + translation.x >= indicatorView.frame.minX && imageView!.frame.maxX + translation.x <= indicatorView.frame.maxX) || ((imageView!.frame.size.width >= indicatorView.frame.size.width) && (imageView!.frame.minX + translation.x <= indicatorView.frame.minX && imageView!.frame.maxX + translation.x >= indicatorView.frame.maxX)) {
            imageView!.center.x += translation.x
        }
        
        if (imageView!.frame.minY + translation.y >= indicatorView.frame.minY && imageView!.frame.maxY + translation.y <= indicatorView.frame.maxY) || ((imageView!.frame.size.height >= indicatorView.frame.size.height) && (imageView!.frame.minY + translation.y <= indicatorView.frame.minY && imageView!.frame.maxY + translation.y >= indicatorView.frame.maxY)) {
            imageView!.center.y += translation.y
        }
        
        recognizer.setTranslation(CGPoint.zero, in: spaceView)
    }
    
    @objc func didPinch(_ recognizer: UIPinchGestureRecognizer) {
        
        let view = UIView(frame: imageView!.frame)
        
        view.transform = imageView!.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
        
        
        if view.frame.size.width >= indicatorView.frame.size.width || view.frame.size.height >= indicatorView.frame.size.height {
            
            imageView!.transform = imageView!.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
        
        if recognizer.state == UIGestureRecognizerState.ended {
            
            if imageView!.frame.minX > indicatorView.frame.minX || imageView!.frame.maxX < indicatorView.frame.maxX {
                
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.imageView!.center = self.indicatorView.center
                })
            }
            
            if imageView!.frame.size.height < indicatorView.frame.size.height && imageView!.frame.size.width < indicatorView.frame.size.width {
                
                
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.imageView!.frame = AVMakeRect(aspectRatio: self.image.size, insideRect: self.indicatorView.frame)
                })
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        
        let croppedImage = grabIndicatedImage()
        UIGraphicsBeginImageContext(CGSize(width: 75, height: 100))
        
        UIGraphicsGetCurrentContext()?.setFillColor(UIColor.black.cgColor)
        
        if 75 / 100 == croppedImage.size.width / croppedImage.size.height  {
            croppedImage.draw(in: CGRect(x: 0, y: 0, width: 75, height: 100))
            
        } else {
            
            let croppedImageSize : CGRect = AVMakeRect(aspectRatio: croppedImage.size, insideRect: CGRect(x: 0, y: 0, width: 75, height: 100))
            croppedImage.draw(in: croppedImageSize)
        }
        
        let resizedCroppedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        let data = UIImagePNGRepresentation(resizedCroppedImage!)
        Networking.updateProfilePicture(data!, completion:self.photoUploaded)
    }
    
    
    func grabIndicatedImage() -> UIImage  {
        
        UIGraphicsBeginImageContext(self.view.layer.frame.size)
        let context : CGContext = UIGraphicsGetCurrentContext()!;
        self.view.layer.render(in: context)
        let screenshot : UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        
        let rectToCrop = CGRect(x: indicatorView.frame.minX + 8, y: indicatorView.frame.minY + 72, width: indicatorView.frame.width - 16, height: indicatorView.frame.height - 16)
        
        let imageRef : CGImage = screenshot.cgImage!.cropping(to: rectToCrop)!
        let croppedImage = UIImage(cgImage: imageRef)
        
        
        UIGraphicsEndImageContext();
        return croppedImage
    }
    
    func photoUploaded(_ success:Bool, data:Data?)
    {
        if success && data != nil
        {
            //TODO: LKM delegate method to
            delegate.pictureUpdatedWithData(data!)
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertView(title: ERROR_TEXT, message: PHOTO_UPLOAD_ERROR_TEXT, delegate: nil, cancelButtonTitle: OK_TEXT)
            alert.show()
        }
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)
        {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.imageView!.center = self.indicatorView.center
                self.imageView!.frame = AVMakeRect(aspectRatio: self.image.size, insideRect: self.indicatorView.frame)
            })
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        
        coordinator.animate(alongsideTransition: { (context) -> Void in
            
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.imageView!.center = self.indicatorView.center
                    self.imageView!.frame = AVMakeRect(aspectRatio: self.image.size, insideRect: self.indicatorView.frame)
                })
            }
        }, completion: { (context) -> Void in
            
            
        })
    }
}
