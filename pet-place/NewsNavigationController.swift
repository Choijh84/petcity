//
//  NewsNavigationController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 28..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/**
 *  Navigation controller for the News section to provide customization.
 */

class NewsNavigationController: UINavigationController {

    /**
     Customize the look of the status bar
     
     :returns: return the statusbar style of the topViewController
     */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return topViewController!.preferredStatusBarStyle
    }

}
