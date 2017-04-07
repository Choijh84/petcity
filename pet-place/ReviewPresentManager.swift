//
//  ReviewPresentManager.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//


import UIKit

/// Manager object that tells the viewController what objects to use to present and dismiss the view
class ReviewPresentManager: NSObject, UIViewControllerTransitioningDelegate {

    /**
     Asks your delegate for the transition animator object to use when presenting a view controller.

     - parameter presented:  The view controller object that is about to be presented onscreen.
     - parameter presenting: The view controller that is presenting the view controller in the presented parameter. The object in this parameter could be the root view controller of the window, a parent view controller that is marked as defining the current context, or the last view controller that was presented. This view controller may or may not be the same as the one in the source parameter.
     - parameter source:     The view controller whose presentViewController:animated:completion: method was called.

     - returns: The animator object to use when presenting the view controller or nil if you do not want to present the view controller using a custom transition.
     */
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = ReviewPresentAnimator()
        animator.isPresenting = true
        return animator
    }

    /**
     Asks your delegate for the transition animator object to use when dismissing a view controller.

     - parameter dismissed: The view controller object that is about to be dismissed.

     - returns: The animator object to use when dismissing the view controller or nil if you do not want to dismiss the view controller using a custom transition.
     */
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = ReviewPresentAnimator()
        animator.isPresenting = false
        return animator
    }

}
