//
//  SearchViewController.swift
//  IBA Members Directory
//
//  Created by Jacob King on 15/05/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import UIKit


protocol SearchDelegate
{
    func searchButtonPressed(_ firstName:String?, lastName: String?, firmName: NSString?, city: String?, country: String?, committee: NSNumber?, areaOfPractice: NSNumber?,conference: Bool)
}

protocol SearchClearDelegate    {
    func clearResultView();
}

enum SearchType {
    case conferenceProfile
    case profile
    
    var searchButtonColour:UIColor {
        get {
            switch self {
            case .conferenceProfile:
                return Settings.getConferencePrimaryColour()
            default:
                return UIColor(hex: "007AFF")
            }
            
        }
    }
    
    var searchButtonActiveColor: UIColor {
        get {
            switch self {
            case .conferenceProfile:
                return Settings.getSelectedEventColour()
            default:
                return UIColor.darkGreenColor()
            }
            
        }
    }
}

class SearchViewController: IBABaseUIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, UITextViewDelegate, UIPopoverControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, SearchPickerDelegate {
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firmNameLabel: UILabel!
    @IBOutlet weak var firmNameTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var comitteeLabel: UILabel!
    @IBOutlet weak var committeeTextView: UITextView!
    @IBOutlet weak var areaOfPracticeTextView: UITextView!
    @IBOutlet weak var conferenceTextField: UITextField?
    
    @IBOutlet weak var areasOfPracticeLabel: UILabel!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchScrollView: UIScrollView!
    
    @IBOutlet weak var searchButton: UIButton!
    var delegate: SearchDelegate!
    var committeesSearchPicker : SearchPickerTableViewController!
    var areaOfPracticeSearchPicker : SearchPickerTableViewController!

    var committeesPopover : UIPopoverController!
    var areaOfPracticePopover : UIPopoverController!
    
    var selectedCommittee : Committee?
    var selectedAreaOfPractice : AreaOfPractice?
    
    var countryNames = [String]()
    var conferenceNames = [""]
    
    var searchType: SearchType! = .profile
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateCountryArrays()
        
        setUpLocalisedLabels()
        
        if UIDevice.current.userInterfaceIdiom == .pad    {
            prepareSearchPickerPopovers()
        }
        
        //make the textviews look like textfields
        let textFieldBorderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        committeeTextView.layer.borderColor = textFieldBorderColor
        committeeTextView.layer.borderWidth = 1.0
        committeeTextView.textColor = UIColor.lightGray
        areaOfPracticeTextView.layer.borderColor = textFieldBorderColor
        areaOfPracticeTextView.layer.borderWidth = 1.0
        areaOfPracticeTextView.textColor = UIColor.lightGray
        
        searchButton.backgroundColor = searchType.searchButtonColour
        if searchType! == .conferenceProfile {
            searchButton.layer.addBorder(edge: UIRectEdge.top, color: UIColor(hex: "D8E4C8"), thickness: 0.5)
            searchButton.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor(hex: "D8E4C8"), thickness: 0.5)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    @IBAction func clearAllButtonPressed(_ sender: AnyObject) {
        self.view.endEditing(true)
        firstNameTextField.text = ""
        lastNameTextField.text = ""
        firmNameTextField.text = ""
        cityTextField.text = ""
        countryTextField.text = ""
        conferenceTextField?.text = ""
        selectedCommittee = nil
        selectedAreaOfPractice = nil
        committeeTextView.text = "-"
        areaOfPracticeTextView.text = "-"
        committeeTextView.textColor = UIColor.lightGray
        areaOfPracticeTextView.textColor = UIColor.lightGray
    }
    
    func populateCountryArrays() {
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
            
            var countries = [String]()
            let path = Bundle.main.path(forResource: "Countries", ofType: "plist")
            let countriesDict = NSDictionary(contentsOfFile: path!)!
        
            for key in countriesDict.allKeys {
            
                let countryName = countriesDict[key as! String] as! String
                countries.append(countryName)
            }
            countries = countries.sorted { String($0) < String($1) }
        
            DispatchQueue.main.async(execute: { () -> Void in
                self.countryNames = countries
            })
        })
    }
    
    @IBAction func didTapSearchView(_ sender: AnyObject) {
        self.view.endEditing(true)

    }
    
    //MARK: Button pressed methods
    @IBAction func touchUpSearch(_ sender: AnyObject) {
        self.view.endEditing(true)
        var selectedAreaOfPracticeId : Int?
        var selectedCommitteeId : Int?
        
        if selectedCommittee != nil
        {
            selectedCommitteeId = selectedCommittee!.committeeId.intValue
        }
        
        if selectedAreaOfPractice != nil
        {
            selectedAreaOfPracticeId = selectedAreaOfPractice!.areaOfPracticeId.intValue
        }
        switch self.searchType! {
        case .profile:
            if firstNameTextField.text == "" && lastNameTextField.text == "" && cityTextField.text == "" && countryTextField.text == "" && firmNameTextField.text == "" && selectedCommittee == nil && selectedAreaOfPractice == nil
            {
                let alert = UIAlertView(title: ERROR_TEXT, message: NO_SEARCH_CRITERIA_TEXT, delegate: nil, cancelButtonTitle: OK_TEXT)
                alert.show()
                return
            }
            
            
            let isConference:Bool = !(conferenceTextField?.text ?? String()).isEmpty
            
            delegate.searchButtonPressed(firstNameTextField.text, lastName: lastNameTextField.text, firmName: firmNameTextField.text as NSString?, city: cityTextField.text, country: countryTextField.text, committee: selectedCommitteeId as NSNumber?, areaOfPractice: selectedAreaOfPracticeId as NSNumber?,conference: isConference)
            return
        case .conferenceProfile:
            delegate.searchButtonPressed(firstNameTextField.text, lastName: lastNameTextField.text, firmName: firmNameTextField.text as NSString?, city: cityTextField.text, country: countryTextField.text, committee: selectedCommitteeId as NSNumber?, areaOfPractice: selectedAreaOfPracticeId as NSNumber?,conference: true)
            return
        }
    }
    
    @IBAction func touchDownSearch(_ sender: AnyObject) {
        
    }
    
    func setUpLocalisedLabels()
    {
        firstNameLabel.text = FIRST_NAME_LABEL
        lastNameLabel.text = SURNAME_LABEL
        firmNameLabel.text = FIRM_NAME_LABEL
        cityLabel.text = CITY_LABEL
        countryLabel.text = COUNTRY_LABEL
        comitteeLabel.text = COMMITTEE_LABEL
        areasOfPracticeLabel.text = AREA_OF_PRACTICE_LABEL
    }
    
    //MARK: Search picker setup methods
    func prepareSearchPickerPopovers()
    {
        committeesSearchPicker = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchPickerTable") as! SearchPickerTableViewController
        committeesPopover = UIPopoverController(contentViewController: committeesSearchPicker)
        committeesPopover.delegate = self
        committeesSearchPicker.searchPickerMode = .committee
        committeesSearchPicker.searchPickerDelegate = self
        committeesSearchPicker.getArrayAndPopulateTable()
        
        areaOfPracticeSearchPicker = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchPickerTable") as! SearchPickerTableViewController
        areaOfPracticePopover = UIPopoverController(contentViewController: areaOfPracticeSearchPicker)
        areaOfPracticePopover.delegate = self
        areaOfPracticeSearchPicker.searchPickerMode = .areaOfPractice
        areaOfPracticeSearchPicker.getArrayAndPopulateTable()
        areaOfPracticeSearchPicker.searchPickerDelegate = self
    }
    
    func prepareSearchPicker(_ senderTextView : UITextView, searchpicker: SearchPickerTableViewController)
    {
        searchpicker.searchPickerDelegate = self
        if senderTextView == committeeTextView
        {
            searchpicker.searchPickerMode = .committee
            searchpicker.selectedItem = selectedCommittee
        }
        else if senderTextView == areaOfPracticeTextView
        {
            searchpicker.searchPickerMode = .areaOfPractice
            searchpicker.selectedItem = selectedAreaOfPractice
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.view.endEditing(true)
        
        
        if UIDevice.current.userInterfaceIdiom == .pad   {
            
            let popoverSize = CGSize(width: UIScreen.main.bounds.size.width - 75, height: UIScreen.main.bounds.size.height)
            if textView == committeeTextView
            {
                committeesPopover.contentSize = popoverSize
                committeesSearchPicker.selectedItem = selectedCommittee
                committeesPopover.present(from: textView.frame, in: view, permittedArrowDirections: .left, animated: true)
                
            }
            else if textView == areaOfPracticeTextView
            {
                areaOfPracticeSearchPicker.selectedItem = selectedAreaOfPractice
                areaOfPracticePopover.contentSize = popoverSize
                areaOfPracticePopover.present(from: textView.frame, in: view, permittedArrowDirections: .left, animated: true)
            }
            
        }   else    {
            self.performSegue(withIdentifier: "ShowSearchPicker", sender: textView)
        }
        
        return false
    }
    
    
    //MARK: TextfieldDelegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if let nextTextField = view.viewWithTag(textField.tag + 1) as? UITextField
        {
            nextTextField.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
//        if textField == committeeTextField
//        {
//            selectedCommitteesArray.removeAll(keepCapacity: false)
//        }
//        else if textField == areasOfPracticeTextField
//        {
//            selectedAreasOfPracticeArray.removeAll(keepCapacity: false)
//        }
        textField.text = ""
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == countryTextField {
            
            let picker = UIPickerView()
            picker.tag = 0
            picker.dataSource = self
            picker.delegate = self
            textField.inputView = picker
        } else if textField == conferenceTextField {
            let picker = UIPickerView()
            picker.tag = 1
            picker.dataSource = self
            picker.delegate = self
            textField.inputView = picker
        }
    }
    
    //MARK: SearchPickerDelegate method
    func updateSearchForMode(_ searchPickerMode: SearchPickerMode, selectedItem: AnyObject?)
    {
        switch searchPickerMode    {
        case .committee:
            
            if selectedItem != nil
            {
                selectedCommittee = selectedItem as? Committee
                committeeTextView.text = "\(selectedCommittee!.committeeName)"
                committeeTextView.textColor = UIColor.darkGray
            }
            else
            {
                selectedCommittee = nil
                committeeTextView.text = "-"
                committeeTextView.textColor = UIColor.lightGray
            }
        case .areaOfPractice:
            if selectedItem != nil
            {
                selectedAreaOfPractice = selectedItem as? AreaOfPractice
                areaOfPracticeTextView.text = "\(selectedAreaOfPractice!.areaOfPracticeName)"
                areaOfPracticeTextView.textColor = UIColor.darkGray
            }
            else
            {
                selectedAreaOfPractice = nil
                areaOfPracticeTextView.text = "-"
                areaOfPracticeTextView.textColor = UIColor.lightGray
            }
        default:break
        }
    }
    
    
    //MARK: UINavigation methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSearchPicker"
        {
            var searchPickerTableViewController : SearchPickerTableViewController!
            if segue.destination.isKind(of: UINavigationController.self)
            {
                let navigationController = segue.destination as! UINavigationController
                searchPickerTableViewController = navigationController.viewControllers[0] as! SearchPickerTableViewController
            }
            else
            {
                searchPickerTableViewController = segue.destination as! SearchPickerTableViewController
            }
            searchPickerTableViewController.searchPickerDelegate = self
            
            let senderTextView = sender as! UITextView
            prepareSearchPicker(senderTextView, searchpicker: searchPickerTableViewController)
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return countryNames.count
        } else {
            return conferenceNames.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView.tag == 0 {
            return countryNames[row]
        } else {
            return conferenceNames[row]
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            countryTextField.text = countryNames[row]
        } else {
            conferenceTextField?.text = conferenceNames[row]
        }
        
    }
    
}
