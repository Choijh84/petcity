//
//  UsrManager.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 2..
//  Copyright © 2017년 press.S. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

/// Custom manager object that handles all user related actions
class UserManager: NSObject {
    
    /** 
    Logs in a user with the given properties
 
    - parameter email: email to user
    - parameter password: password
    - parameter completionBlock: black to call after the request finished 
    */
    
    class func loginUser(withEmail email: String, password: String, completionBlock: @escaping (_ successful: Bool, _ errorMessage: String?) -> ()) {
        Backendless.sharedInstance().userService.setStayLoggedIn(true)
        Backendless.sharedInstance().userService.login(email, password: password, response: { (user) in
            print("User has been logged in (ASYNC): \(user)")
            completionBlock(true, nil)
        }) { (fault) in
            print("Server reported an error: \(fault)")
            completionBlock(false, fault?.description)
        }
    }
    
    /**
     Registers a user with the given values
     
     - parameter email:           email
     - parameter password:        password
     - parameter completionBlock: block to call after the request finished
     */
    class func registerUser(withEmail email: String, password: String, completionBlock: @escaping (_ successful: Bool, _ errorMessage: String?) -> ()) {
        let user = BackendlessUser(properties: ["email": email, "password": "password"])
        Backendless.sharedInstance().userService.setStayLoggedIn(true)
        Backendless.sharedInstance().userService.registering(user, response: { (user) in
            completionBlock(true, nil)
        }) { (fault) in
            completionBlock(false, fault?.description)
        }
    }
    
    class func updateUser(phoneNumber: String, completionBlock: @escaping (_ successful: Bool, _ errorMessage: String?) -> ()) {
        let user = self.currentUser()
        if (user != nil) {
            user?.setProperty(phoneNumber, object: nil)
        } else {
            print("User hasn't been logged")
        }
    }
    
    /**
    Launches facebook login
    - parameter completionBlock: black to call after the request finished
    */
    class func loginViaFacebook(withViewController viewController: UIViewController, completionBlock: @escaping (_ successful: Bool, _ errorMessage: String?) -> ()) {
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["email", "public_profile"], from: viewController) { (result, error) in
            if error != nil {
                print("Process error")
                completionBlock(false, error?.localizedDescription)
            } else if (result?.isCancelled)! {
                print("Cancelled")
                completionBlock(false, nil)
            } else {
                print("Logged in")
                self.loginWithFacebookAccessToken((result?.token)!, completionBlock: completionBlock)
            }
        }
    }
    
    /** 
    Logs in to Backendless using Facebook access token
     - parameter token: token to use
     - parameter completionBlock: block to call after the request finished
    */
    fileprivate class func loginWithFacebookAccessToken(_ token: FBSDKAccessToken, completionBlock: @escaping (_ successfule: Bool, _ errorMessage: String?) -> ()) {
        Backendless.sharedInstance().userService.setStayLoggedIn(true)
        Backendless.sharedInstance().userService.login(withFacebookSDK: token, fieldsMapping: ["email": "email"], response: { (user) in
            print("Result: \(user)")
            completionBlock(true, nil)
        }) { (fault) in
            print("Server reported an error: \(fault)")
            completionBlock(false, fault?.description)
        }
    }
    
    /** 
    Log out the current user from the app
 
    - parameter completionBlock: true if it was successful and errormessage if any 
    */
    class func logoutUser(_ completionBlock: @escaping (_ successful: Bool, _ errorMessage: String?) -> ()) {
        Backendless.sharedInstance().userService.logout({ (user) in
            print("User logged out")
            completionBlock(true, nil)
        }) { (fault) in
            print("Server reported an error: \(fault)")
            completionBlock(false, fault?.description)
        }
    }
    
    /** 
    Checks if the user is logged in 
    - returns: true if the user is logged in 
    */
    class func isUserLoggedIn() -> Bool {
        return Backendless.sharedInstance().userService.currentUser != nil
    }
    
    /**
     Returns the currently logged in User, if any
     
     - returns: user, if there is a logged in user
     */
    class func currentUser() -> BackendlessUser? {
        return Backendless.sharedInstance().userService.currentUser
    }
    
    /**
        Download all user's pet profiles 
     */

}
