
//
//  DirectoryViewController.swift
//  IBA Members Directory
//
//  Created by Louisa Mousley on 27/05/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import Foundation
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
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class DirectoryViewController : IBABaseUIViewController, UITableViewDataSource,UITableViewDelegate
{

    @IBOutlet weak var tableView: UITableView!
    var membersArray : [MemberProfile]?
    var isLoading = false
    var noResults = false
    var isInFavourites = false
    var nextBatchAccount = 20

    var endOfDataset = false
    
    
    
    //MARK: UITableView datasource and delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading || noResults
        {
            return 1
        }
        if membersArray != nil
        {
            return membersArray!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ListCell {
            if (UIDevice.current.userInterfaceIdiom == .pad && UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation))
            {
                performSegue(withIdentifier: "showProfileSegue", sender: cell)
            }
            else
            {
                performSegue(withIdentifier: "showProfileSegue-iPhone", sender: cell)
            }

        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((isLoading || noResults) && !isInFavourites)
        {
            noResults = false
            return 44
        }
        return 109
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isLoading && !isInFavourites
        {
            let cell : LoadingCell = tableView.dequeueReusableCell(withIdentifier: "LoadingTableViewCell") as! LoadingCell
            cell.loadingActivityIndicator.startAnimating()
            return cell
        }
        
        if membersArray?.count >= 1 {
            
          let cell : ListCell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! ListCell
        let memberProfile = membersArray![indexPath.row]
          
        return cell.initialiseCell(memberProfile)  
            
        } else {
            
            let cell : InformationErrorCell = tableView.dequeueReusableCell(withIdentifier: "InformationErrorCell") as! InformationErrorCell
            return cell
 
        }
        
    }

    func selectFirstCellIfDetailViewShowing()
    {
        //only perform segue if both views on screen
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            return
        }
        if membersArray != nil && membersArray!.count > 0
        {
            let firstIndexPath = IndexPath(row: 0, section: 0)
            tableView.selectRow(at: firstIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
            let cell = tableView.cellForRow(at: firstIndexPath) as! ListCell
            
            if (UIDevice.current.userInterfaceIdiom == .pad && UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation))
            {
                performSegue(withIdentifier: "showProfileSegue", sender: cell)
            }
            else
            {
                performSegue(withIdentifier: "showProfileSegue-iPhone", sender: cell)
            }
        }
        else
        {
            performSegue(withIdentifier: "showNoMembersView", sender: self)
        }
    }
    
    
    
    //MARK: Navigation methods
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        //if iphone/ipad portrait then show iphone view
        
        if identifier == "showProfileSegue" && ((UIDevice.current.userInterfaceIdiom == .pad && UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation)) || UIDevice.current.userInterfaceIdiom == .phone)
        {
            performSegue(withIdentifier: "showProfileSegue-iPhone", sender: sender)
            return false
        }   else    {
            return true
        }
    }
    
    
    //MARK: Navigation methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showProfileSegue" || segue.identifier == "showProfileSegue-iPhone"
        {
            //the destinationViewController is a UINavigationController for iOS 8 and is the ProfileViewController for iOS7 - so check class before using to prevent crash.
            let destinationViewController: UIViewController = segue.destination 
            var profileViewController : ProfileViewController!
            
            if destinationViewController.isKind(of: UINavigationController.self)
            {
                profileViewController = (destinationViewController as! UINavigationController).viewControllers[0] as! ProfileViewController
                profileViewController.profileDisplayType = .directoryProfile
            }
            else if destinationViewController.isKind(of: ProfileViewController.self)
            {
                profileViewController = destinationViewController as! ProfileViewController
                profileViewController.profileDisplayType = .directoryProfile
            }

            
            if profileViewController != nil
            {
                let cell : UITableViewCell = (sender as? UITableViewCell)!
                let indexPath = tableView.indexPath(for: cell)
                let memberProfile : MemberProfile = membersArray![indexPath!.row] as MemberProfile
                profileViewController.currentProfile = memberProfile
                
                //pass the master view button for when we segue to new detail view in portrait iPad
                if UIDevice.current.userInterfaceIdiom == .pad
                {
                    let navigationController = splitViewController!.viewControllers[1] as! UINavigationController
                    let previousViewController = navigationController.viewControllers[0] as? UIViewController
                    profileViewController.navigationItem.leftBarButtonItem = previousViewController!.navigationItem.leftBarButtonItem
                }
            }
        }
        else if segue.identifier == "showNoMembersView"
        {
            var newViewController : UIViewController!
            let destinationViewController: UIViewController = segue.destination 
            if destinationViewController.isKind(of: UINavigationController.self)
            {
                newViewController = (destinationViewController as! UINavigationController).viewControllers[0] 
            }
            else
            {
                newViewController = destinationViewController as UIViewController
            }

            if newViewController != nil
            {
                if UIDevice.current.userInterfaceIdiom == .pad
                {
                    let navigationController = splitViewController!.viewControllers[1] as! UINavigationController
                    let previousViewController = navigationController.viewControllers[0] as? UIViewController
                    newViewController.navigationItem.leftBarButtonItem = previousViewController!.navigationItem.leftBarButtonItem
                }
            }

        }
    }
    
    
    func reloadDetailViewOnRotation(_ orientation:UIInterfaceOrientation)
    {
        if let selectedIndexPath = tableView?.indexPathForSelectedRow
        {
            let cell = tableView.cellForRow(at: selectedIndexPath)
            if (UIDevice.current.userInterfaceIdiom == .pad && UIInterfaceOrientationIsLandscape(orientation))
            {
                performSegue(withIdentifier: "showProfileSegue", sender: cell)
            }
            else
            {
                performSegue(withIdentifier: "showProfileSegue-iPhone", sender: cell)
            }
        }
    }
    //MARK: Rotation methods
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            if size.height > UIScreen.main.bounds.size.height
            {
                reloadDetailViewOnRotation(UIInterfaceOrientation.portrait)
            }
            else
            {
                reloadDetailViewOnRotation(UIInterfaceOrientation.landscapeLeft)
            }
        }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)
        {
            reloadDetailViewOnRotation(toInterfaceOrientation)
        }
    }
    
}
