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
        // 네비게이션바 색 및 폰트 조절
        UINavigationBar.appearance().tintColor = UIColor.navigationTitleColor()
        UINavigationBar.appearance().barTintColor = UIColor.navigationBarColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.navigationTitleColor(), NSFontAttributeName: UIFont(name: "YiSunShinDotumM", size: 18)!]

        UITabBar.appearance().tintColor = .globalTintColor()
        UITabBar.appearance().barTintColor = .white

        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.tabBarTitleNormalColor(), NSFontAttributeName: UIFont(name: "YiSunShinDotumM", size: 10)!], for: UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.globalTintColor()], for: .selected)
        
        // 바버튼 타이틀 폰트 및 크기
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName : UIFont(name: "YiSunShinDotumM", size: 12)!], for: .normal)

        
    }
}

