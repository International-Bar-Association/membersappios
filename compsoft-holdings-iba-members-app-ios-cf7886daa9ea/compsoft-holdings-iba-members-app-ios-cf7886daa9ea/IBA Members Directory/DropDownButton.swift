//
//  DropDownButton.swift
//  IBA Members Directory
//
//  Created by George Smith on 30/07/2018.
//  Copyright © 2018 Compsoft plc. All rights reserved.
//

import Foundation

protocol DropdownButtonDatasource {
    func numberOfRows(in dropdownButton: DropdownButton,for dropdown: DropdownButton) -> Int
}

protocol DropdownButtonDelegate {
    func titleForRow(in dropdownButton: DropdownButton,for indexPath: IndexPath) -> String
    func didSelectRow(in dropdownButton: DropdownButton, at indexPath: IndexPath)
}

class DropdownButton: UIButton,UIKeyInput {
    var hasText: Bool = false
    var shouldDismissAfterSelection: Bool! = false
    var pickerView: UIPickerView!
    
    func insertText(_ text: String) {
        
    }
    
    func deleteBackward() {
        
    }
    
    func reloadData() {
        pickerView.reloadAllComponents()
    }
    
    override var canBecomeFirstResponder: Bool {
        get{
            return true
        }
    }
    
    private var _inputView: UIView?
    override var inputView: UIView? {
        get {
            return _inputView
        }
        set {
            _inputView = newValue
        }
    }
    
    var isEditing: Bool = false {
        didSet {
            if isEditing {
                
                self.tintColor = UIColor.white
                self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                UIView.animate(withDuration: 0.3) {
                    self.setImage(#imageLiteral(resourceName: "icon_close"), for: .normal)
                    self.setTitle("", for: .normal)
                    self.backgroundColor = UIColor.red
                    self.layer.borderColor = UIColor.red.cgColor
                    
                }

            } else {
                let title = self.delegate.titleForRow(in: self, for: IndexPath(row: self.pickerView.selectedRow(inComponent: 0), section: 0))
                self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
                self.tintColor = Settings.getConferencePrimaryColour()
                
                UIView.animate(withDuration: 0.1) {
                    self.setTitle(title, for: .normal)
                self.backgroundColor = UIColor.white
                self.layer.borderColor = UIColor.white.cgColor
                self.setImage(#imageLiteral(resourceName: "icon_down_arrow"), for: .normal)
                
                
                }
            }
        }
    }
    
    var delegate: DropdownButtonDelegate!
     
    var datasource: DropdownButtonDatasource!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        pickerView = UIPickerView()
        pickerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = UIColor.white
        
        self.semanticContentAttribute = UIApplication.shared
            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        self.setImage(#imageLiteral(resourceName: "icon_down_arrow"), for: .normal)
        self.imageView?.tintColor = Settings.getConferencePrimaryColour()

        self.layer.cornerRadius = self.frame.height / 2
        self.layer.borderColor = pickerView.backgroundColor?.cgColor
        self.layer.borderWidth = CGFloat(1)
        //self.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10)
       
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 3
        
        self.inputView = pickerView
        self.adjustsImageWhenHighlighted = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isEditing {
            self.endEditing(true)
            isEditing = false
            self.isHighlighted = false
        } else {
            isEditing = true
            self.becomeFirstResponder()
            self.isHighlighted = false
        }
        
    }
    
    override var intrinsicContentSize: CGSize {
        if isEditing {
            let superSize = super.intrinsicContentSize
            let newWidth = superSize.width
            let newHeight = superSize.height
            let newSize = CGSize(width: newWidth, height: newHeight)
            return newSize
        } else {
            let superSize = super.intrinsicContentSize
            let newWidth = superSize.width + superSize.height
            let newHeight = superSize.height
            let newSize = CGSize(width: newWidth, height: newHeight)
            return newSize
        }

    }
}

extension DropdownButton: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let del = delegate else {
            return
        }
        
        var name = self.pickerView(self.pickerView, titleForRow: row, forComponent: component)
        self.setTitle(name, for: .normal)
        del.didSelectRow(in: self, at: IndexPath(item: row, section: component))
        if shouldDismissAfterSelection {
            isEditing = false
            self.endEditing(true)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let del = delegate else {
            return ""
        }
        return del.titleForRow(in: self, for: IndexPath(item: row, section: component))
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let ds = datasource else {
            return 0
        }
        return ds.numberOfRows(in: self, for: self)
    }
}
