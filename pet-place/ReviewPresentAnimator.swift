//
//  ReviewPresentAnimator.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//


import UIKit

/// Custom animator object that presents a Review
class ReviewPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    /// Boolean value that indicates if the manager is displaying the view or dismissing it
    var isPresenting: Bool = false

    /**
     Duration of the transition

     - parameter transitionContext: The context object containing information to use during the transition.

     - returns: The duration, in seconds, of your custom transition animation.
     */
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    /**
     Tells your animator object to perform the transition animations.

     - parameter transitionContext: The context object containing information about the transition.
     */
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        /// Get all the related controllers and containers
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView
        let animationDuration = transitionDuration(using: transitionContext)

        if isPresenting == true {
            let fromViewController = fromViewController as! UITabBarController

            // presenting the new viewController
            let snapShotImage = snapShotView(fromViewController.view)
            let fromViewSnapshotImage = UIImageView(image: snapShotImage.applyLightEffect())
            containerView.addSubview(fromViewSnapshotImage)

            let toViewSnapshot = toViewController.view.resizableSnapshotView(from: toViewController.view.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)
            toViewSnapshot?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

            containerView.addSubview(toViewSnapshot!)

            UIView.animate(withDuration: animationDuration, animations: { () -> Void in
                    toViewSnapshot?.transform = CGAffineTransform.identity
                }, completion: { (finished) -> Void in
                    toViewSnapshot?.removeFromSuperview()
                    containerView.addSubview(toViewController.view)
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        } else {
            // presenting the new viewController
            let fromViewSnapshot = fromViewController.view.resizableSnapshotView(from: fromViewController.view.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)
            containerView.addSubview(fromViewSnapshot!)
            fromViewController.view.alpha = 0.0
            toViewController.view.alpha = 0.0

            UIView.animate(withDuration: animationDuration, animations: { () -> Void in
                    fromViewSnapshot?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    toViewController.view.alpha = 1.0
                }, completion: { (finished) -> Void in
                    fromViewSnapshot?.removeFromSuperview()
                    fromViewController.view.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }

    /**
     Creates a snapshot of a given view and creates an UIImage

     - parameter view: view to snapshot

     - returns: image
     */
    func snapShotView(_ view: UIView) -> UIImage {
        //Create the UIImage
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }

}
