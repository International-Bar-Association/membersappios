//
//  AppDelegate.swift
//  IBA Members Directory
//
//  Created by Jacob King on 13/05/2015.
//  Copyright (c) 2015 Compsoft plc. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import AirshipKit
import Firebase

let CONTENT_IMAGE_LOCATION = Environment().baseURL + "images/contentlibrary/"
let PROFILE_IMAGE_LOCATION = "http://www.int-bar.org/Officers/Images/"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SRKDelegate {
    
    var window: UIWindow?
    
    let APN_MESSAGE_TYPE = "Type"
    let APN_MESSAGE_ID = "Id"
    
    var searchClearDelegate: SearchClearDelegate!
    var bubbleContainerView:ConferenceBubbleContainingView!
    var bubbleIsVisible: Bool = false
    var statusBarNotification: CWStatusBarNotification!
    var conferenceMenuViewsOpen: Bool {
        get {
            if window != nil {
                if let _  = self.window!.rootViewController?.presentedViewController as? ConferenceMenuViewController {
                    return true
                }
            }
            return false
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Fabric.with([Crashlytics.self])
        Settings.initialise()
        var needsReLogin = false
        
        if !Settings.getHasPreviouslyLaunched()! {
            clearDatabaseAfterUpdate()
            needsReLogin = true
            Settings.setHasPreviouslyLaunched(true)
        }
        
        SharkORM.setDelegate(self)
        SharkORM.setApplicationDomain("IBA_Directory")
        SharkORM.openDatabaseNamed("IBAMembersv3")
        
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        UAirship.takeOff(Environment().urbanAirshipConfig)
        UAirship.push().pushNotificationDelegate = self
        statusBarNotification = CWStatusBarNotification()
        self.statusBarNotification.notificationLabel?.backgroundColor = UIColor.white
        self.statusBarNotification.notificationLabelTextColor = UIColor(red:0.11, green:0.17, blue:0.47, alpha:1.0)
        
        
        bubbleContainerView = ConferenceBubbleContainingView(frame: window!.frame)
        let startPos = CGPoint(x: window!.frame.size.width - 70, y: window!.frame.size.height - 70)
        bubbleContainerView.setUpView(UIImage(named: "btn_conference_rome")!, startPos: startPos, radius: 40, animationType: .grow)
        NotificationCenter.default.addObserver(self, selector: #selector(didRotate), name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
        
        let email = Settings.getUserEmail()
        if  email == nil || needsReLogin
        {
            showLoginView(needsReLogin)
        } else {
            Crashlytics.sharedInstance().setUserEmail(email)
            Networking.refreshDictionariesAndCheckForConference()
            UAirship.namedUser().identifier = "\(Settings.getUserId())"
            
            UAirship.push().updateRegistration()
        }
        
        UAirship.push().userPushNotificationsEnabled = true
        UAirship.push().defaultPresentationOptions = [.alert, .badge, .sound]
        if let options = Environment().firebaseConfig {
            FirebaseApp.configure(options: options)
        }
        
        return true
        
    }
    
    @objc func didRotate() {
        self.bubbleContainerView.viewDidRotate((self.window?.frame)!)
    }
    
    func clearDatabaseAfterUpdate() {
        
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let finalDatabaseaString = documentDirectory.appendingPathComponent("IBAMembers.db")
        
        if FileManager.default.fileExists(atPath: finalDatabaseaString)
        {
            do {
                try FileManager.default.removeItem(atPath: finalDatabaseaString)
                print("Removed directory ")
                
            }
            catch let error as NSError
            {
                print("Failed to delete directory:  \(error.localizedDescription)")
            }
        }
        else
        {
            print("No directory to remove - v2 install not update.")
            
        }
    }
    
    func logUserOut(_ shouldClearLoginDetails:Bool)
    {
        //Only remove login details and remove profile if the user manually logs out
        if shouldClearLoginDetails
        {
            Settings.setUserEmail(nil)
            Settings.setUserPassword(nil)
            Settings.setIsLoggedIn(false)
            Settings.setBadgeAmount(0)
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            if let myProfile = MemberProfile.getMyProfile()
            {
                //need to clear my profile as next user might be different
                myProfile.remove()
                P2PMessageThread.query().fetch().removeAll()
                P2PMessage.query().fetch().removeAll()
                Message.query().fetch().removeAll()
            }
        }
        Settings.setUserAPISessionKey(nil)
        
        showLoginView()
        
        if searchClearDelegate != nil   {
            searchClearDelegate.clearResultView()
        }
    }
    
    func showLoginView(_ justUpdated: Bool = false)
    {
        
        var loginViewController : LoginViewController!
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController-iPhone") as? LoginViewController
        }
        else
        {
            loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        }
        loginViewController.hasJustUpdated = true
        self.window?.rootViewController = loginViewController
        self.window?.makeKeyAndVisible()
        self.window?.bringSubview(toFront: bubbleContainerView)
        bubbleContainerView.hideBubble()
        
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if let email = Settings.getUserEmail()
        {
            Networking.refreshDictionariesAndCheckForConference()
        }
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func databaseError(_ error: SRKError!) {
        print(error)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("APNs device token: \(deviceTokenString)")
        print("Successfuly registered for APN with device token \(deviceToken)")
        
        
        Settings.setPushDeviceToken(deviceTokenString)
        
        if Settings.getIsLoggedIn()
        {
            Networking.configurePushDeviceToken(nil)
        }
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if UIApplication.shared.applicationState == UIApplicationState.active
        {
            print("Received APN in foreground: \(userInfo)")
            
            self.handleRemoteNotification(userInfo as NSDictionary, openView:false)
            
        }
        else if UIApplication.shared.applicationState == UIApplicationState.inactive
            
        {
            print("Received APN in background but coming into foreground: \(userInfo)")
            self.handleRemoteNotification(userInfo as NSDictionary, openView:true)
            
        }
        else
        {
            print("Received APN in background: \(userInfo)")
            //self.handleRemoteNotification(userInfo as NSDictionary, openView:false)
            
            if let type = userInfo[APN_MESSAGE_TYPE] as? String {
                if type == "P2P_MESSAGE" {
                    var current = Settings.getBadgeP2PAmount()
                    current += 1
                    Settings.setBadgeP2PAmount(current)
                } else {
                    var current = Settings.getBadgeAmount()
                    current += 1
                    Settings.setBadgeAmount(current)
                }
                let total = Settings.getBadgeAmount() + Settings.getBadgeP2PAmount()
                
                UIApplication.shared.applicationIconBadgeNumber = total
            }
        }
        completionHandler(UIBackgroundFetchResult.newData);
        
    }
    
    
    func handleRemoteNotification(_ remoteNotification: NSDictionary, openView:Bool)
    {
        print("Received APN")
        
        if let type = remoteNotification[APN_MESSAGE_TYPE] as? String {
            
            if type == "P2P_MESSAGE" {
                var current = Settings.getBadgeP2PAmount()
                current += 1
                Settings.setBadgeP2PAmount(current)
                self.didReceiveP2PMessageInBackground(openView: openView,notification: remoteNotification)
                return
            }
            
            if let idStr = remoteNotification[APN_MESSAGE_ID] as? String {
                guard window != nil else {
                    let error = NSError(domain: "", code: 0, userInfo: ["message":"Tried to open view on uninit window."])
                    Crashlytics.sharedInstance().recordError(error)
                    
                    return
                }
                
                if openView {
                    let reachability = Reachability.forInternetConnection()
                    let networkStatus = reachability?.currentReachabilityStatus().rawValue
                    if networkStatus == 0
                    {
                        //don't present any modals if no internet.
                        return
                    }
                    
                    if let tabBarController = self.window?.rootViewController as? TabBarController {
                        tabBarController.selectedIndex = 1
                        if let splitViewController = tabBarController.selectedViewController as? SplitViewController {
                            guard splitViewController.viewControllers.count > 0 else {
                                return
                            }
                            if let messageNavController = splitViewController.viewControllers[0] as? UINavigationController {
                                guard messageNavController.childViewControllers.count > 0 else {
                                    return
                                }
                                if let messagesViewController = messageNavController.childViewControllers[0] as? MessageListViewController {
                                    messagesViewController.arrivedFromPush = true
                                    messagesViewController.messageIdFromPush = Int(idStr)!
                                    messagesViewController.viewAppearFromPush(isP2P: type == "P2P_MESSAGE")
                                }
                            }
                        }
                    }
                    print("Opening message with id of \(idStr)")
                } else {
                    //showNewMessageReceievedStatusBar("New Message Received!")
                    if let tabBarController = self.window?.rootViewController as? TabBarController {
                        tabBarController.selectedIndex = 1
                        if let splitViewController = tabBarController.selectedViewController as? SplitViewController {
                            if let messageNavController = splitViewController.viewControllers[0] as? UINavigationController {
                                if let contentNavController = messageNavController.childViewControllers[1] as? ContentNavController {
                                    if let p2pMessageController = contentNavController.childViewControllers[0] as? P2PMessagesContainingViewController {
                                        p2pMessageController.recievedPushInBackground()
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension AppDelegate: UAPushNotificationDelegate {
    
    func receivedForegroundNotification(_ notificationContent: UANotificationContent, completionHandler: @escaping () -> Void) {
        debugPrint(notificationContent)
    }
    
    func receivedNotificationResponse(_ notificationResponse: UANotificationResponse, completionHandler: @escaping () -> Void) {
        debugPrint(notificationResponse)
        handleRemoteNotification(notificationResponse.notificationContent.notificationInfo as NSDictionary , openView: true)
        
    }
}

extension AppDelegate {
    func didReceiveP2PMessageInForeground() {
        
    }
    
    func didReceiveP2PMessageInBackground(openView: Bool,notification: NSDictionary) {
        
        if self.bubbleIsVisible {
            bubbleContainerView.hideBubble()
        }
        
        if let tabBarController = self.window?.rootViewController as? TabBarController {
            
            guard let idStr = notification[APN_MESSAGE_ID] as? String, let id = Int(idStr) else  {
                return
            }
            
            if openView {
                if let confMenu = self.window?.rootViewController?.presentedViewController as? ConferenceMenuViewController {
                    debugPrint(confMenu.presentedViewController)
                    if let schedNav = confMenu.presentedViewController as? UINavigationController {
                        schedNav.dismiss(animated: true) {
                            confMenu.showChatWithMessage(id: id)
                        }
                    } else if let schedSplit = confMenu.presentedViewController as? ConferenceSplitViewController  {
                        schedSplit.dismiss(animated: true) {
                            confMenu.showChatWithMessage(id: id)
                        }
                    } else {
                        confMenu.showChatWithMessage(id: id)
                    }
                } else {
                    tabBarController.openFromPush(id: id)
                }
                
            } else {
                //NOTE: Lets raise a notification to say we have recieved a p2p message whilst in the app.
                NotificationCenter.default.post(name: NSNotification.Name("P2PMessageReceived"), object: self)
            }
            
        }
    }
}

extension AppDelegate {
    func becomeBubbleDelegate(delegate: ConferenceBubbleDelegate) {
        bubbleContainerView.delegate = delegate
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL,
            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
            let path = components.path,
            let params = components.queryItems else {
                return false
        }
        
        print("path = \(path)")
        switch path {
        case "/Applinks/ViewEvent":
            if let id = params.first, let idValue = id.value {
                debugPrint("Open event with id \(idValue)")
                openSelectedEvent(id: idValue)
            }
            return true
        default:
            return false
        }
    }
    
    func openSelectedEvent(id: String) {
        
        if self.bubbleIsVisible {
            bubbleContainerView.hideBubble()
        }
        
        var tabBarController = self.window?.rootViewController as? TabBarController
        var confMenu = self.window?.rootViewController?.presentedViewController as? ConferenceMenuViewController
        if tabBarController == nil {
            if let loginVc = self.window?.rootViewController as? LoginViewController {
                tabBarController = loginVc.presentedViewController as? TabBarController
                confMenu = tabBarController?.presentedViewController as? ConferenceMenuViewController
            }
        }
        
        if tabBarController != nil {
            if confMenu != nil {
                
                if let schedNav = confMenu!.presentedViewController as? UINavigationController {
                    
                    if let mapVc = schedNav.childViewControllers[0] as? ConferenceMapViewController {
                        if  let event = Event.getEventById(id: id) {
                            mapVc.selectEventFromCalender(event: event)
                        }
                    }
                } else if let schedSplit = confMenu!.presentedViewController as? ConferenceSplitViewController  {
                    
                    let navVc = schedSplit.viewControllers.first as! UINavigationController
                    let scheduleVC = navVc.viewControllers.first as! ConferenceScheduleTableViewController
                    let mapNavVc = schedSplit.viewControllers.last as! UINavigationController
                    let mapVc = mapNavVc.childViewControllers.first as! ConferenceMapViewController
                    
                    
                    if  let event = Event.getEventById(id: id) {
                        mapVc.selectEventFromCalender(event: event)
                        scheduleVC.selectEvent(event: event)
                    }
                    
                    
                } else if let schedMessSplit = confMenu!.presentedViewController as? ConferenceMessageSplitViewController  {
                    debugPrint("In messages")
                    schedMessSplit.dismiss(animated: true) {
                        confMenu!.showSchedule(id)
                    }
                }
                else {
                    confMenu!.showSchedule(id)
                }
            } else {
                tabBarController!.openCalenderEvent(id: id)
            }
        }
    }
    
}
