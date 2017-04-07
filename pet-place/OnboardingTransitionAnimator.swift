//
//  OnboardingTransitionAnimator.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class OnboardingTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    var isPresenting = false

    /**
     The duration of the animation.

     :param: transitionContext the transition context object

     :returns: the duration
     */
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    /**
     The main animation happens here. This is called when the user selects a cell at the tableView

     :param: transitionContext the transition context object
     */
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        /// Get all the related controllers and containers
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView
        let animationDuration = transitionDuration(using: transitionContext)

        if isPresenting == true
        {
            // move it off screen
            toViewController.view.transform = CGAffineTransform(translationX: (containerView.frame).width, y: 0.0)
            containerView.addSubview(toViewController.view)

            UIView.animate(withDuration: animationDuration, animations: { () -> Void in
                    fromViewController.view.transform = CGAffineTransform(translationX: -(containerView.frame).width, y: 0.0)
                    toViewController.view.transform = CGAffineTransform.identity
                }, completion: { (finished) -> Void in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
        else
        {
            // we shouldn't care about dismissal, because we only want to display the home view and then forget about the OnboardingViewController.
            // Next time the user opens the app, the home view will be his rootViewController
        }
    }
}
