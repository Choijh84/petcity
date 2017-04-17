//
//  CustomizeAppearance.swift
//  pet-place
//
//  Created by Owner on 2016. 12. 31..
//  Copyright © 2016년 press.S. All rights reserved.
//

import UIKit

 /// UI customisation class

class CustomizeAppearance: NSObject {

    /**
    Customize the global UI elements, such as UINavigationBar and UITabBar
    */
    class func globalCustomization () {
        UINavigationBar.appearance().tintColor = UIColor.navigationTitleColor()
        UINavigationBar.appearance().barTintColor = UIColor.navigationBarColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.navigationTitleColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!]    

        UITabBar.appearance().tintColor = .globalTintColor()
        UITabBar.appearance().barTintColor = .white

        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.tabBarTitleNormalColor(), NSFontAttributeName: UIFont.systemFont(ofSize: 10.0)], for: UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.globalTintColor()], for: .selected)
    }
}

