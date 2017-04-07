//
//  StoresListNavigationController.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 2..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class StoresListNavigationController: UINavigationController {

    /**
     Customize the statusbar for the navigation stack
     
     :returns: light statusbar style
     */
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController!.preferredStatusBarStyle
    }

}
