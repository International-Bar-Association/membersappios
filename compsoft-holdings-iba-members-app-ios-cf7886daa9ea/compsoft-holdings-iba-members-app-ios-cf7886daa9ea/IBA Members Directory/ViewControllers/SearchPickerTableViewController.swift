//
//  SearchPickerTableViewController.swift
//  IBA Members Directory
//
//  Created by Jacob King on 21/05/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import UIKit

enum SearchPickerMode: Int  {
    case committee = 1
    case areaOfPractice = 2
}

protocol SearchPickerDelegate   {
    func updateSearchForMode(_ searchPickerMode: SearchPickerMode, selectedItem: AnyObject?)

}

class SearchPickerTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var objectArray : [AnyObject]!
    var objectDict : [String : [AnyObject]]!
    var searchPickerMode = SearchPickerMode.committee
    var searchPickerDelegate: SearchPickerDelegate!
    var selectedItem : AnyObject?
    var selectedIndexPath : IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //xcode bug where using UITableViewAutomaticDimension produced wrongly sized cells when they had accessory icons
        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1
        {
            tableView.estimatedRowHeight = 44.0
            tableView.rowHeight = UITableViewAutomaticDimension
        }
        
        if UIDevice.current.userInterfaceIdiom != .pad    {
            if searchPickerMode == .committee   {
                navigationItem.title = COMMITTEES_LABEL
            }
            else if searchPickerMode == .areaOfPractice {
                navigationItem.title = AREAS_OF_PRACTICE_LABEL
            }
            getArrayAndPopulateTable()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //ipad is in a popover so want to refresh data as view doesnt reload each time
        if UIDevice.current.userInterfaceIdiom == .pad    {
            tableView.reloadData()
        }
    }
    
    func getArrayAndPopulateTable()
    {
        if searchPickerMode == .committee   {
            objectArray = Committee.getAllCommittees()
            populateTableForCommittees()
        }
        else
        {
            objectArray = AreaOfPractice.getAllAreasOfPractice()
            populateTableForAreasOfPractice()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchPickerDelegate.updateSearchForMode(searchPickerMode, selectedItem:selectedItem)
    }
    
    func populateTableForCommittees()    {

        if objectArray != nil {
            
            var sortedObjects = [Committee]()
            objectDict = [String : [AnyObject]]()
            
            for item in objectArray {
                let committee = item as! Committee
                sortedObjects.append(committee)
            }
            
            sortedObjects = sortedObjects.sorted { String($0.committeeName) < String($1.committeeName) }
            objectArray = sortedObjects
            
            for object in objectArray {
                
                let committee = object as! Committee
                let objectName = String(committee.committeeName)
                let firstLetter = objectName.substring(to: objectName.characters.index(after: objectName.startIndex))
                
                if objectDict[firstLetter] == nil    {
                    
                    objectDict[firstLetter] = [Committee]()
                }
                var objectLetterArray = objectDict[firstLetter]!
                objectLetterArray.append(committee)
                objectDict[firstLetter] = objectLetterArray
            }
        }
        self.tableView.reloadData()
    }
    
    func populateTableForAreasOfPractice()    {

        if objectArray != nil {
            
            var sortedObjects = [AreaOfPractice]()
            objectDict = [String : [AnyObject]]()
            
            for item in objectArray {
                let areaOfPractice = item as! AreaOfPractice
                sortedObjects.append(areaOfPractice)
            }
            
            sortedObjects = sortedObjects.sorted { String($0.areaOfPracticeName) < String($1.areaOfPracticeName) }
            objectArray = sortedObjects
            
            for object in objectArray {
                
                let areaOfPractice = object as! AreaOfPractice
                let objectName = String(areaOfPractice.areaOfPracticeName)
                let firstLetter = objectName.substring(to: objectName.characters.index(after: objectName.startIndex))
                
                if objectDict[firstLetter] == nil    {
                    
                    objectDict[firstLetter] = [AreaOfPractice]()
                }
                
                var objectLetterArray = objectDict[firstLetter]!
                objectLetterArray.append(areaOfPractice)
                objectDict[firstLetter] = objectLetterArray
            }
        }
        self.tableView.reloadData()
    }
    
    
    func sortKeys(_ keys: [AnyObject]) -> [AnyObject]    {
        
        return keys.sorted { String($0 as! NSString) < String($1 as! NSString) }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if objectArray != nil && objectDict != nil {
            return objectDict.count
        }   else    {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 {
            return UITableViewAutomaticDimension
        }
        
        let keys = sortKeys(Array(objectDict.keys) as [AnyObject])
        let key = keys[indexPath.section] as! String
        let currentObjectArray = objectDict[key]!
        
        var currentName : String!
        if searchPickerMode == .committee   {
            
            let currentObject = currentObjectArray[indexPath.row] as! Committee
            currentName = String(currentObject.committeeName)
            
        } else if searchPickerMode == .areaOfPractice   {
            
            let currentObject = currentObjectArray[indexPath.row] as! AreaOfPractice
            currentName = String(currentObject.areaOfPracticeName)
        }
        //48 is size of tick and padding
        let rect = currentName.boundingRect(with: CGSize(width: tableView.frame.width - CGFloat(16) - 48, height: 90), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
        return rect.height + 16
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if objectArray != nil && objectDict != nil {
            
            let keys = sortKeys(Array(objectDict.keys) as [AnyObject])
            let key = keys[section] as! String
            let objectArray = objectDict[key]!
            return objectArray.count
            
        }   else    {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if objectArray != nil && objectDict != nil {
            
            let titles = sortKeys(Array(objectDict.keys) as [AnyObject])
            
            return (titles[section] as! String)
            
        }   else    {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : CommitteeCell = tableView.dequeueReusableCell(withIdentifier: "CommitteeCell") as! CommitteeCell
        
        if objectArray != nil && objectDict != nil {
            
            let keys = sortKeys(Array(objectDict.keys) as [AnyObject])
            let key = keys[indexPath.section] as! String
            let currentObjectArray = objectDict[key]!
            
            cell.selectedImageView.isHidden = true

            if searchPickerMode == .committee   {
                let currentObject = currentObjectArray[indexPath.row] as! Committee
                cell.titleLabel?.text = String(currentObject.committeeName)
                
                if selectedItem != nil
                {
                    let committee : Committee = selectedItem as! Committee
                    if committee.committeeId == currentObject.committeeId
                    {
                        cell.selectedImageView.isHidden = false
                        selectedIndexPath = indexPath
                    }
                }
                
            } else if searchPickerMode == .areaOfPractice   {
                let currentObject = currentObjectArray[indexPath.row] as! AreaOfPractice
                cell.titleLabel?.text = String(currentObject.areaOfPracticeName)
                
                if selectedItem != nil
                {
                    let areaOfPractice : AreaOfPractice = selectedItem as! AreaOfPractice
                    if areaOfPractice.areaOfPracticeId == currentObject.areaOfPracticeId
                    {
                        cell.selectedImageView.isHidden = false

                        selectedIndexPath = indexPath
                    }
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell : CommitteeCell = tableView.cellForRow(at: indexPath)! as! CommitteeCell

        //if there's a currently selected item
        if selectedItem != nil
        {
            if searchPickerMode == .committee   {
                let committee : Committee = selectedItem as! Committee
                if (committee.committeeName as String) == cell.titleLabel.text!
                {
                    //remove selectedItem
                    selectedItem = nil
                    selectedIndexPath = nil
                    cell.selectedImageView.isHidden = true

                    return
                }
            }
            else
            {
                let areaOfPractice : AreaOfPractice = selectedItem as! AreaOfPractice
                if (areaOfPractice.areaOfPracticeName as String) == cell.titleLabel.text!
                {
                    selectedItem = nil
                    selectedIndexPath = nil
                    cell.selectedImageView.isHidden = true

                    return
                }
            }
            //we only get here if we've selected a different cell to selectedIndexPath
            if let cell : CommitteeCell = tableView.cellForRow(at: selectedIndexPath!) as? CommitteeCell
            {
                cell.selectedImageView.isHidden = true

            }
        }
        
        //if we haven't deselected current selectedItem, then get the full object and set as selectedItem

        let keys = sortKeys(Array(objectDict.keys) as [AnyObject])
        let key = keys[indexPath.section] as! String
        let currentObjectArray = objectDict[key]!
        
        if searchPickerMode == .committee   {
            selectedItem = currentObjectArray[indexPath.row] as! Committee
            selectedIndexPath = indexPath
        } else if searchPickerMode == .areaOfPractice   {
            selectedItem = currentObjectArray[indexPath.row] as! AreaOfPractice
            selectedIndexPath = indexPath
        }
        cell.selectedImageView.isHidden = false

    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchPickerMode == .committee   {
            
            if searchText != "" {
                objectArray = Committee.getCommitteesWithNameIncluding(searchText)
            }   else    {
                objectArray = Committee.getAllCommittees()
            }
            
            populateTableForCommittees()
        } else if searchPickerMode == .areaOfPractice {
            
            if searchText != "" {
                objectArray = AreaOfPractice.getAreaOfPracticesWithNameIncluding(searchText)
            }   else    {
                objectArray = AreaOfPractice.getAllAreasOfPractice()
            }
            
            populateTableForAreasOfPractice()
        }
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.resignFirstResponder()
        return true
    }
    
}
