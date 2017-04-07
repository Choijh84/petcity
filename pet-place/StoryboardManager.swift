//
//  StoryboardManager.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// Manager class to handle viewController instantiations
class StoryboardManager: NSObject {
    
    /**
     Return an OnboardingViewController instance
     
     - returns: OnboardingViewController
     */
    class func onboardingViewController() -> OnboardingViewController {
        return UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController() as! OnboardingViewController
    }
    
    /**
     Returns a MainTabbarViewController instance
     
     - returns: MainTabbarViewController
     */
    class func homeTabbarController() -> MainTabbarViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! MainTabbarViewController
    }
    
    class func firstViewController() -> FirstViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! FirstViewController
    }
    
    /**
     Returns a LoginViewController instance
     
     - returns: LoginViewController
     */
    class func loginViewController() -> LoginViewController {
        return UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
    }
    
    class func newsNavigationController() -> NewsNavigationController {
        return UIStoryboard(name: "News", bundle: nil).instantiateViewController(withIdentifier: "NewsNavigationController") as! NewsNavigationController
    }
    
    class func accountNavigationController() -> UINavigationController {
        return UIStoryboard(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "myprofileNavigationController") as! UINavigationController
    }
    
    class func storyAndReviewController() -> UINavigationController {
        return UIStoryboard(name: "StoryAndReview", bundle: nil).instantiateViewController(withIdentifier: "StoryAndReviewNavigationController") as! UINavigationController
    }
    
    /**
     Returns a ReviewsViewController from Reviews Storyboard
     
     - returns: ReviewsViewController
     */
    class func reviewsViewController() -> ReviewsViewController {
       return UIStoryboard(name: "Reviews", bundle: nil).instantiateInitialViewController() as! ReviewsViewController
    }
    
}
