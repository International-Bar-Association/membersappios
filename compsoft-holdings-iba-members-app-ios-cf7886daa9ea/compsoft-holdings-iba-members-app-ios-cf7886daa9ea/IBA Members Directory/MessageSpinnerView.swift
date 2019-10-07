//
//  MessageSpinnerView.swift
//  IBA Members Directory
//
//  Created by George Smith on 14/09/2018.
//  Copyright © 2018 Compsoft plc. All rights reserved.
//

import Foundation
import UIKit

class MessageSpinnerView: UIView {
 
    fileprivate var spinner: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        self.roundView()
        self.addDropShadow()
        self.layer.borderColor = Settings.getConferencePrimaryColour().cgColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSpinner()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSpinner()
    }

    func startSpinning() {
        spinner.startAnimating()
    }
    
    func stopSpinning() {
        spinner.stopAnimating()
    }
    
    private func addSpinner() {
        self.translatesAutoresizingMaskIntoConstraints = false
        spinner = UIActivityIndicatorView(frame: self.frame)
        spinner.color = Settings.getConferencePrimaryColour()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(spinner)
        spinner.layoutAttachAll(to: self)
        
    }
}
