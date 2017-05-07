//
//  AppDelegate.swift
//  pet-place
//
//  Created by Owner on 2016. 12. 31..
//  Copyright © 2016년 press.S. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import OneSignal
import Branch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let APP_ID = "6E11C098-5961-1872-FF85-2B0BD0AA0600"
    let SECRET_KEY = "582E29FF-AB79-01D4-FFB7-B22F163C0B00"
    let VERSION_NUM = "v1"

    var backendless = Backendless.sharedInstance()
    
    /**
     Load our customization here when the app starts, set up the Parse ID and set the global tintColor
     
     :param: application   applicadtion	The singleton app object.
     :param: launchOptions A dictionary indicating the reason the app was launched (if any).
     
     :returns: NO if the app cannot handle the URL resource or continue a user activity, otherwise return YES.
     */

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        CustomizeAppearance.globalCustomization()
        window?.tintColor = UIColor.globalTintColor()
        
        // 브랜치 세팅
        let branch = Branch.getInstance()
        
        branch?.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: { (params, error) in
            if error == nil {
                 print("params: \(String(describing: params?.description))")
            }
        })
        
        // 백엔드리스 관련 설정
        backendless?.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
        
        // 유저 자동 로그인 관련 세팅
        if (backendless?.userService.isStayLoggedIn)! {
            let result = backendless?.userService.isValidUserToken()
            print("isValidUserToken: \(String(describing: result?.boolValue))")
            backendless?.userService.setStayLoggedIn((result?.boolValue)!)
        }
        
        // 구글 맵 관련 설정
        GMSPlacesClient.provideAPIKey("AIzaSyBwzZ6Mx2_3cn0mCFS4I2guim4T2Mu1IFs")
        GMSServices.provideAPIKey("AIzaSyBwzZ6Mx2_3cn0mCFS4I2guim4T2Mu1IFs")
        IQKeyboardManager.sharedManager().enable = true
        
        // 위치 정보 설정 관련
        print("General Setting: \(GeneralSettings.isOnboardingFinished())")
        
        // 위치정보 동의하면 rootview가 바뀜, homeTabbar
        if GeneralSettings.isOnboardingFinished() == false {
            window?.rootViewController = StoryboardManager.onboardingViewController()
        } else {
            window?.rootViewController = StoryboardManager.homeTabbarController()
        }
        
        // 푸쉬 관련 설정 - OneSignal
        /*
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            print("Received Notification: \(notification!.payload.notificationID)")
        }
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload = result!.notification.payload
            
            var fullMessage = payload.body
            print("Message = \(String(describing: fullMessage))")
            
            if payload.additionalData != nil {
                if payload.title != nil {
                    let messageTitle = payload.title
                    print("Message Title = \(messageTitle!)")
                }
                
                let additionalData = payload.additionalData
                if additionalData?["actionSelected"] != nil {
                    fullMessage = fullMessage! + "\nPressed ButtonID: \(String(describing: additionalData!["actionSelected"]))"
                }
            }
        }
 
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: true,
                                     kOSSettingsKeyInAppLaunchURL: true]
        */
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "7a8dda70-2d90-475b-b707-4c980acf87c9"
                                        )
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        
        // 사용자 설정 편집
        let userDefaults = UserDefaults.standard
        
        // userSetting에서 저장되었는지 한 번 확인하고 그 값이 false이면 데이터베이스에 저장한다
        if !userDefaults.bool(forKey: "OneSignalIdSaved") {
            if let userID = status.subscriptionStatus.userId {
                if let user = UserManager.currentUser() {
                    user.setProperty("OneSignalID", object: userID)
                    _ = Backendless.sharedInstance().userService.update(user)
                    
                    userDefaults.set(true, forKey: "OneSignalIdSaved")
                    userDefaults.synchronize()
                    print("OneSignalID has saved: \(userID)")
                }
            }
        }
        
        // 원시그널 런칭옵션
        // OneSignal.initWithLaunchOptions(launchOptions, appId: "7a8dda70-2d90-475b-b707-4c980acf87c9")
        
        // Sync hashed email if you have a login system or collect it.
        // Will be used to reach the user at the most optimal time of day.
        // OneSignal.syncHashedEmail(userEmail)

        // 폰트 이름 체크
        /*
        for name in UIFont.familyNames {
            print(name)
            if let nameString = name as? String
            {
                print(UIFont.fontNames(forFamilyName: nameString))
            }
        }
        */
        
        return true
    }
    
    /**
     Asks the delegate to open a resource specified by a URL, and provides a dictionary of launch options.
     
     - parameter application:       Your singleton app object.
     - parameter url:               The URL resource to open. This resource can be a network resource or a file. For information about the Apple-registered URL schemes, see Apple URL Scheme Reference.
     - parameter options:           A dictionary of launch options
     
     - returns: the application
     */
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        print("AppDelegate -> application:openURL: \(String(describing: url.scheme))")
        
        // responds to URI Scheme links
        Branch.getInstance().application(application,
                                         open: url,
                                         sourceApplication: sourceApplication,
                                         annotation: annotation
        )
        
        let backendless = Backendless.sharedInstance()
        let user = backendless?.userService.handleOpen(url)
        if user != nil {
            print("AppDelegate -> application:openURL: user = \(String(describing: user))")
            
            // do something, call some ViewController method, for example
        }
        
        return true
        // return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    /// Resond to Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        // pass the url to the handle deep link call
        Branch.getInstance().continue(userActivity)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    /**
     Tells the delegate that the app has become active.
     
     - parameter application: Your singleton app object.
     */
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "pet_place")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

