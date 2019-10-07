//
//  FavouritesTableViewController.swift
//  IBA Members Directory
//
//  Created by Jacob King on 13/05/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import UIKit

class FavouritesTableViewController: DirectoryViewController {
    
    var selectFirstCell = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        membersArray = MemberProfile.getAllFavoritedProfiles()
        navigationItem.title = FAVOURITES_TEXT
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        membersArray = MemberProfile.getAllFavoritedProfiles()
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectFirstCellIfDetailViewShowing()
    }

    
    func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete
        {
            let memberProfile : MemberProfile = membersArray![indexPath.row] as MemberProfile
            removeMemberFromFavouritesAndReloadView(memberProfile)
        }
    }
    
    
    func removeMemberFromFavouritesAndReloadView(_ memberProfile:MemberProfile)
    {
        memberProfile.memberType = MemberType.memberTypeNone.rawValue as NSNumber!
        let memberProfileDatabaseEntry = MemberProfile.getProfileForFavouriteMemberId(memberProfile.userId)
        memberProfileDatabaseEntry!.remove()
        reloadFavouritesView()
    }
    
    func reloadFavouritesView()
    {
        membersArray = MemberProfile.getAllFavoritedProfiles()
        tableView.reloadData()
        selectFirstCellIfDetailViewShowing()
    }

}
