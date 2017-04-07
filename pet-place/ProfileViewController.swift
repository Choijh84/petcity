//
//  ProfileViewController.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// A viewcontroller that displays the currently logged in user's information
/// After this work, should work on pet's information

class ProfileViewController: UIViewController {

    /// the title label for the logged in user
    @IBOutlet weak var loggedInEmailTitleLabel: UILabel!
    /// Label that show the email address of the user
    @IBOutlet weak var loggedInEmailLabel: UILabel!
    /// The logo imageView to show the company logo
    @IBOutlet weak var companyLogoImageView: UIImageView!
    //// The logout Button
    @IBOutlet weak var logoutButton: UIButton!
    
    /// Lazy loader for LoginViewController, cause we might not need to initialize it in the first place
    lazy var loginViewController: LoginViewController = {
        let loginViewController = StoryboardManager.loginViewController()
        return loginViewController
    }()
    
    /** 
    Called when user taps on logout button, present an alertview asking for confirmation 
    */
    @IBAction func logoutButtonPressed() {
        let alertView = UIAlertController(title: "Logout?", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alertView.addAction(UIAlertAction(title: "Log out", style: .default, handler: { (alertAction) -> Void in
            self.logoutUser()
        }))
        present(alertView, animated: true, completion: nil)
    }
    
    /**
     Log out the user and present the login viewcontroller
     */
    func logoutUser() {
        UserManager.logoutUser { (successful, errorMessage) -> () in
            if successful {
                self.presentLoginViewController()
            } else {
                // Present error
                self.displayAlertView(errorMessage!, title: "Error")
            }
        }
    }
    
    /**
     <#Description#>
     
     - parameter message: <#message description#>
     - parameter title:   <#title description#>
     */
    func displayAlertView(_ message: String, title: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertView, animated: true, completion: nil)
    }
    
    /**
     Here we can customise your view, I just assign the user's username to the label to show it
     */
    func customiseView() {
        if let email = UserManager.currentUser()?.email {
            loggedInEmailLabel.text = email as String
        } else {
            loggedInEmailLabel.text = UserManager.currentUser()?.name as String?
        }
        logoutButton.layer.cornerRadius = 4.0
    }
    
    /**
     Checks if the loginViewController is already presented, if not, it adds it as a subview to our view
     */
    func presentLoginViewController() {
        if loginViewController.view.superview == nil {
            loginViewController.view.frame = view.frame
            loginViewController.willMove(toParentViewController: self)
            view.addSubview(loginViewController.view)
            loginViewController.didMove(toParentViewController: self)
            addChildViewController(loginViewController)
        }
    }
    
    /**
     Dismisses the login viewController if it is visible
     */
    func dismissLoginViewController() {
        if loginViewController.view.superview != nil {
            loginViewController.dismissView()
        }
    }
    
    /**
     Check if the user is logged in or not. If yes, dismiss the login view if visible. If not present it
     
     - parameter animated: If true, the view is being added to the window using an animation.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserManager.isUserLoggedIn() {
            dismissLoginViewController()
        } else {
            loggedInEmailLabel.text = ""
            presentLoginViewController()
        }
    }
    
    /**
     Customises the view after it appeares
     
     - parameter animated: animated
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        customiseView()
    }
    
    /**
     Adds a special motion effect to the company logo, which means when you move around the iPhone on it's Y and X axis the logo will also move a bit
     around those axis. Just like the home screen.
     */
    func addMotionEffectToCompanyLogo() {
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -30
        horizontalMotionEffect.maximumRelativeValue = 30
        
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -20
        verticalMotionEffect.maximumRelativeValue = 20
        
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        companyLogoImageView.addMotionEffect(motionEffectGroup)
    }
    
    /**
     Use the default statusbar here (Black)
     
     - returns: the default statusbar
     */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    


}
