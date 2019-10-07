//
//  ContentDetailWebViewController.swift
//  IBA Members Directory
//
//  Created by George Smith on 08/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import UIKit

class ContentDetailWebViewController: UIViewController {
    
    @IBOutlet var webview: UIWebView!
    var content : Content!
    
    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        dismiss(animated: true) {
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
            }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if content.additionalData != nil {
            
            webview.load(content.additionalData as Data, mimeType: self.content.mimeType as String, textEncodingName: "utf-8", baseURL: NSURL() as URL)
            
        }
        else
        {
            let url = URL(string: content.url as String)
            let request = URLRequest(url: url!)
            print(self.view)
            print(webview)
            webview.loadRequest(request)
        }
        
        webview.scalesPageToFit = true

    }
}
