//
//  MainTabbarViewController.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// The tabbar controller that hold the tabBar of the app.

class MainTabbarViewController: UITabBarController {

    /**
     Adds new tabbar items to the tabbar
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Adds the news navigation controller to the tabbar
        // let newsNavigationController = StoryboardManager.newsNavigationController()
        // addChildViewController(newsNavigationController)
        
        /// Adds the Story navigation controller to the tabbar
        let storyAndReviewController = StoryboardManager.storyAndReviewController()
        addChildViewController(storyAndReviewController)
        
        /// Adds the account viewController to the tabbar
        let accountNavigationController = StoryboardManager.accountNavigationController()
        addChildViewController(accountNavigationController)
        
        
    }


}
