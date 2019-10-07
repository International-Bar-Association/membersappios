//
//  TabBarController.swift
//  IBA Members Directory
//
//  Created by Jacob King on 14/05/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import UIKit


class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var shouldShowLoginView = true
    let barImageNames = ["search", "tab_bar_messages","tab_bar_content", "profile"]
    var nameStartIndex = 0
    var messageIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.becomeBubbleDelegate(delegate: self)
        self.delegate = self
        var profileNavController: UINavigationController!
        
        switch UIDevice.current.userInterfaceIdiom  {
            
        case .phone:
            profileNavController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "navPro-iPhone") as! UINavigationController
        case .pad:
            profileNavController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "navPro") as! UINavigationController
            
        default: return
            
        }
        
        if let myProf = MemberProfile.getMyProfile() {
            if myProf.canSearchDirectory == false {
                viewControllers?.remove(at: 0)
                nameStartIndex = 1
                messageIndex = 0
            }
        }
        
        viewControllers?.append(profileNavController)

        
        let nc = viewControllers?[(viewControllers?.count)! - 1] as! UINavigationController
        let pc = nc.viewControllers.first as! ProfileViewController
        
        pc.profileDisplayType = ProfileDisplayType.myProfile

        self.selectedIndex = (viewControllers?.count)! - 2
        
        if let conference = Conference.getConferenceIfRunning() {
            debugPrint(conference)
            if conference.isOnNow {
                DispatchQueue.main.async {
                    let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.bubbleContainerView.showBubble()
                }
            }
        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Need to present the modal view in the next run loop to prevent the error: 'Unbalanced calls to begin/end appearance transitions'
        let email = Settings.getUserEmail()

        if shouldShowLoginView && email == nil
        {
            showLoginView()
        }
    }
    

    
    func updateBadgeOnMessageTab() {
        let numberOfUnread = DataProvider.getNumberOfUnreadMessages()
        tabBar.items![messageIndex].badgeValue = "\(numberOfUnread)"
    }
    
    func showLoginView()
    {
        var topViewController : UIViewController = self as UIViewController
        if self.presentedViewController != nil
        {
            topViewController = presentedViewController!
        }
        else
        {
            topViewController = self
        }
        
        while (topViewController.presentedViewController != nil)
        {
            topViewController = topViewController.presentedViewController!
        }
        topViewController.dismiss(animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(0.1))) {
            
            var loginViewController : LoginViewController!
            if UIDevice.current.userInterfaceIdiom == .phone
            {
                loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController-iPhone") as? LoginViewController
            }
            else
            {
                loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
            }
            self.present(loginViewController!, animated: false, completion: nil)
        }
        shouldShowLoginView = false
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        if UIDevice.current.userInterfaceIdiom != .phone
        {
            //if on iPad then we dont need to pop to rootviewcontroller
            return true
        }
        
        for (index, tabBarViewController) in (tabBarController.viewControllers!).enumerated()
        {
            if viewController == tabBarViewController 
            {
                if index == tabBarController.selectedIndex && (index == 0 || index == 2 || index == 3)
                {
                    //we tapped the same tab as currently seleceted.
                    //if only detail view showing then pop back to master
                    
                    if let splitViewController = viewController as? SplitViewController
                    {
                        if let navController = splitViewController.viewControllers[0] as? UINavigationController{
                            navController.popViewController(animated: true)
                        }
                        else
                        {
                            viewController.navigationController!.popViewController(animated: true)
                        }
                    }
                }

                break
            }
        }
        return true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        let index = self.selectedIndex
        let title = barImageNames[index]
        //GAEventManager.sendTabSelectedEvent(title)
    }
}

extension TabBarController: ConferenceBubbleDelegate {
    
    func didTapBubble() {
        let confStoryboard = UIStoryboard.init(name: "Conference", bundle: Bundle.main)
        let vc = confStoryboard.instantiateViewController(withIdentifier: "ConferenceMenuViewController") as! ConferenceMenuViewController
        vc.transitioningDelegate = vc
        let appDel = UIApplication.shared.delegate as! AppDelegate
        if let bubble = appDel.bubbleContainerView {
            bubble.hideBubble()
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func openFromPush(id: Int) {
        
        let confStoryboard = UIStoryboard.init(name: "Conference", bundle: Bundle.main)
        let vc = confStoryboard.instantiateViewController(withIdentifier: "ConferenceMenuViewController") as! ConferenceMenuViewController
        vc.transitioningDelegate = vc
        debugPrint("ID: \(id)")
        self.present(vc, animated: true, completion: {
            vc.showChatWithMessage(id: id)
        })
    }
    
    func openCalenderEvent(id: String) {
        let confStoryboard = UIStoryboard.init(name: "Conference", bundle: Bundle.main)
        let vc = confStoryboard.instantiateViewController(withIdentifier: "ConferenceMenuViewController") as! ConferenceMenuViewController
        vc.transitioningDelegate = vc
        debugPrint("ID: \(id)")
        self.present(vc, animated: true, completion: {
            vc.showSchedule(id)
        })
    }
}
