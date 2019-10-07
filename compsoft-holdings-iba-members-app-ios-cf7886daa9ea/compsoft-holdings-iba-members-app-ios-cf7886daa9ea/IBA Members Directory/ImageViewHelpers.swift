//
//  ImageViewHelpers.swift
//  IBA Members Directory
//
//  Created by George Smith on 02/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func downloadImageFrom(url: URL, contentMode: UIViewContentMode,completion: @escaping (_ imageData: Data?) -> Void) {
        
        downloadImageFrom(link: url.absoluteString, contentMode: contentMode, completion: completion)
    }
    
    func downloadImageFrom(link:String?, contentMode: UIViewContentMode,completion: @escaping (_ imageData: Data?) -> Void) {
        
        guard let link = link, let url = URL(string:link) else { return }
        
        URLSession.shared.dataTask( with: url, completionHandler: {
            (data, response, error) -> Void in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    completion(nil)
                    return
                }
            }
            
            DispatchQueue.main.async {

                self.contentMode =  contentMode
                if let data = data {
                    self.image = UIImage(data: data)
                    //self.image = self.resizeImage(self.frame.width * 2)
                    
                }
            }
            completion(data)
        }).resume()
    }
    
    func resizeImage(_ newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / self.image!.size.width
        let newHeight = image!.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.image!.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func roundImage() {
        self.layer.borderWidth = 1.0
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.cornerRadius = 2.5
        self.clipsToBounds = true
    }
}

extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
