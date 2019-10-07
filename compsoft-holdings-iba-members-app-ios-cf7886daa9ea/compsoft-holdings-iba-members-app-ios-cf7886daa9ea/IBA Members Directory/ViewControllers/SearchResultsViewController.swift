//
//  DirectoryViewController.swift
//  IBA Members Directory
//
//  Created by Jacob King on 13/05/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SearchResultsViewController: DirectoryViewController, UIGestureRecognizerDelegate, SearchDelegate, SearchClearDelegate {
    
    @IBOutlet var searchFavSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchContainerViewHeightConstraint: NSLayoutConstraint!
    var cachedSearchResult:[MemberProfile]?
    var cachedSearchParameters: (firstName: String?, lastName: String?, firmName: NSString?, city: String?, country: String?, committee: NSNumber?, areaOfPractice: NSNumber?)?
    var stillMoreProfilesToGet: Bool! = true
    var wasSearchOpenBeforeTabChange = true

    @IBOutlet var tableViewTopConstraint: NSLayoutConstraint!
    
    @IBAction func segmentedControlChange(_ sender: UISegmentedControl) {
        switch searchFavSegmentedControl.selectedSegmentIndex {
        case 0:
            print("First")
             isInFavourites = false
            tableViewTopConstraint.constant = 44
            if wasSearchOpenBeforeTabChange {
                self.searchContainerViewHeightConstraint.constant = self.currentSearchMaxHeight
            } else
            {
                self.searchContainerViewHeightConstraint.constant = 44
                self.view.layoutIfNeeded()
            }
            membersArray = cachedSearchResult
            tableView.reloadData()
            self.view.layoutIfNeeded()
            
        case 1:
            print("second")
            wasSearchOpenBeforeTabChange = self.searchContainerViewHeightConstraint.constant != 44
            isInFavourites = true
            self.searchContainerViewHeightConstraint.constant = 0
            tableViewTopConstraint.constant = 0
            self.view.layoutIfNeeded()
            cachedSearchResult = membersArray
            membersArray = MemberProfile.getAllFavoritedProfiles()
            tableView.reloadData()

        default:
            break
        }
    }
    
    var embeddedSearch: SearchViewController!
    
    var currentSearchMaxHeight : CGFloat!
    var shouldOpenSearch = true
    var searchIsAnimating = false
    var tableTopConstraintOriginalValue: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                membersArray = [MemberProfile]()
        embeddedSearch.delegate = self
        
        let appDel = UIApplication.shared.delegate! as! AppDelegate
        appDel.searchClearDelegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let searchGR = UIPanGestureRecognizer(target: self, action: #selector(SearchResultsViewController.searchButtonMoved(_:)))
        searchGR.delegate = self
        embeddedSearch.searchButton.addGestureRecognizer(searchGR)
        isLoading = false
        
        if shouldOpenSearch && !isInFavourites
        {
            currentSearchMaxHeight = view.frame.height
            searchContainerViewHeightConstraint.constant = currentSearchMaxHeight
            shouldOpenSearch = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchResultsViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchResultsViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        switch searchFavSegmentedControl.selectedSegmentIndex {
            case 0:
            membersArray = cachedSearchResult
            tableViewTopConstraint.constant = 44
            tableView.reloadData()
            
        case 1:
            membersArray = MemberProfile.getAllFavoritedProfiles()
            tableViewTopConstraint.constant = 0
            tableView.reloadData()
            
        default:
            break
        }
        
        tableTopConstraintOriginalValue = tableViewTopConstraint.constant
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cachedSearchResult = membersArray
        NotificationCenter.default.removeObserver(self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if membersArray != nil {
            if indexPath.row == membersArray!.count - 1 && !isInFavourites && !isLoading && stillMoreProfilesToGet{
                //NOTE: Enable this for paging. Removed as surplus to requirements for V3.
                //bringInMoreResults()
            }
        }
        
        return cell
    }
    
    //MARK: Keyboard notification methods
    @objc func keyboardWillShow(_ notification: Notification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        var keyboardHeight : CGFloat!
        if !UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) && (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)
        {
            keyboardHeight = keyboardFrame.width
        }
        else
        {
            keyboardHeight = keyboardFrame.height
        }
        
        let visibileAreaHeight = view.frame.height - keyboardHeight
        var tabBarHeight = 49
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)
        {
            tabBarHeight = 56
        }
        currentSearchMaxHeight = visibileAreaHeight + CGFloat(tabBarHeight)
        
        if searchContainerViewHeightConstraint.constant > visibileAreaHeight
        {
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.searchContainerViewHeightConstraint.constant = self.currentSearchMaxHeight
                self.view.layoutIfNeeded()
                self.view.updateConstraints()
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let previousSearchMaxHeight = currentSearchMaxHeight
        currentSearchMaxHeight = view.frame.height
        
        if !searchIsAnimating && searchContainerViewHeightConstraint.constant == previousSearchMaxHeight
        {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.searchContainerViewHeightConstraint.constant = self.currentSearchMaxHeight
                self.view.layoutIfNeeded()
                self.view.updateConstraints()
            })
        }
    }
    
    //MARK: Search view methods
    @objc func searchButtonMoved(_ gestureRecognizer: UIPanGestureRecognizer)   {

        embeddedSearch.view.endEditing(true)

        if gestureRecognizer.state == UIGestureRecognizerState.began
        {
            embeddedSearch.searchScrollView.isScrollEnabled = false
        }
        else if gestureRecognizer.state == UIGestureRecognizerState.ended
        {
            embeddedSearch.searchScrollView.isScrollEnabled = true
        }
        let velocity = gestureRecognizer.velocity(in: self.view)
        if(velocity.y > 0)
        {
            searchIsAnimating = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.searchContainerViewHeightConstraint.constant = self.currentSearchMaxHeight
                self.view.layoutIfNeeded()
                }, completion: { (completed) -> Void in
                    self.searchIsAnimating = false
                    self.shouldOpenSearch = false
            })
        }
        else
        {
            if isLoading
            {
                return
            }
            if self.membersArray?.count > 0
            {
                searchIsAnimating = true
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.searchContainerViewHeightConstraint.constant = 44
                    self.view.layoutIfNeeded()
                    }, completion: { (completed) -> Void in
                        self.searchIsAnimating = false
                        //self.shouldOpenSearch = true
                })
            }
            else
            {
                if gestureRecognizer.state == UIGestureRecognizerState.began
                {
                    self.embeddedSearch.touchUpSearch(self.embeddedSearch.searchButton)
                }
            }
        }
    }
    
    
    func encryptCountryString(_ countryString: String?) -> String? {
        
        let path = Bundle.main.path(forResource: "Countries", ofType: "plist")
        let countriesDict = NSDictionary(contentsOfFile: path!)!
        
        for key in countriesDict.allKeys {
            
            if countriesDict[key as! String] as? String == countryString {
                
                return key as? String
            }
        }
        return nil
    }
    
    
    //MARK: search button delegate
    func searchButtonPressed(_ firstName:String?, lastName: String?, firmName: NSString?, city: String?, country: String?, committee: NSNumber?, areaOfPractice: NSNumber?,conference: Bool)
    {
        stillMoreProfilesToGet = true
        if self.searchContainerViewHeightConstraint.constant == 44
        {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.searchContainerViewHeightConstraint.constant = self.currentSearchMaxHeight
                self.view.layoutIfNeeded()
                self.shouldOpenSearch = false
            })
            return
        }
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.embeddedSearch.searchButton.backgroundColor = self.embeddedSearch.searchType.searchButtonActiveColor
            self.searchContainerViewHeightConstraint.constant = 44
            //self.shouldOpenSearch = true
            self.view.layoutIfNeeded()
        })
        
        isLoading = true
        clearResultView()
        Networking.getProfilesWithSearchParameters(firstName, lastName: lastName, firmName: firmName, city: city, country: encryptCountryString(country), committee: committee, areaOfPractice: areaOfPractice, conference: conference,take:10,skip:0, completion:reloadViewWithSearchResults)
        cachedSearchParameters = (firstName, lastName, firmName, city, country, committee, areaOfPractice)
    }
    
    func bringInMoreResults() {
        let offset = membersArray?.count
        guard !self.endOfDataset else {
            return
        }
        
        Networking.getProfilesWithSearchParameters(cachedSearchParameters!.firstName, lastName: cachedSearchParameters!.lastName, firmName: cachedSearchParameters!.firmName, city: self.cachedSearchParameters!.city, country: self.encryptCountryString(self.cachedSearchParameters!.country), committee: self.cachedSearchParameters!.committee, areaOfPractice: self.cachedSearchParameters!.areaOfPractice, conference: false,take:10,skip:offset! as NSNumber, completion:reloadViewWithSearchResults)
    }
    
    func clearResultView()  {
        
        membersArray?.removeAll(keepingCapacity: false)
        tableView.reloadData()
        //Show blank view whilst loading data
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            performSegue(withIdentifier: "showNoMembersView", sender: self)
        }
        
    }
    

    func reloadViewWithSearchResults(_ updatedMemberArray: [MemberProfile]?, successful:Bool, isExtraResults: Bool, conference: Bool)
    {
        if isExtraResults {
            if successful {
                if updatedMemberArray?.count < 10 || conference == true {
                    stillMoreProfilesToGet = false
                } else {
                    stillMoreProfilesToGet = true
                }
                membersArray?.append(contentsOf: updatedMemberArray!)
                tableView.reloadData()
            }
            
        } else {
            isLoading = false
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.embeddedSearch.searchButton.backgroundColor = self.embeddedSearch.searchType.searchButtonColour
                
            })
            
            if updatedMemberArray?.count  == 0  || updatedMemberArray == nil    {
                noResults = true
            }
            if updatedMemberArray?.count < 10 || conference == true {
                stillMoreProfilesToGet = false
            } else {
                stillMoreProfilesToGet = true
            }
            if isInFavourites {
                cachedSearchResult = updatedMemberArray
            } else {
                membersArray = updatedMemberArray
            }
            
            tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.fade)
            selectFirstCellIfDetailViewShowing()
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "embeddedSearch" {
            embeddedSearch = segue.destination as! SearchViewController
        }
        else
        {
            super.prepare(for: segue, sender: sender)
        }
    }
    
}
