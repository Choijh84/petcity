//
//  NewsTransitionDismissalAnimator.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 28..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

 /// Animator object that is used when we dismiss the news object's detail viewController with a custom transition.

class NewsTransitionDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    /**
        The duration of the animation.
    
        :param: transitionContext the transition context object
    
        :returns: the duration
    */
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    /**
        The main animation happens here. This is called when the user selects a dismisses the view.
    
        :param: transitionContext the transition context object
    */
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)! as! NewsListDetailViewController
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)! as! NewsListViewController
        let containerView = transitionContext.containerView

        // create a snapshot of the newsImageView
        let imageSnapshotView = fromViewController.newsImageView.snapshotView(afterScreenUpdates: false)
        imageSnapshotView?.frame = containerView.convert(fromViewController.newsImageView.frame, from: fromViewController.newsImageView.superview)
        fromViewController.newsImageView.isHidden = true
        
        let newsTableViewCell = toViewController.tableViewCellForNewsObject(fromViewController.newsObjectToDisplay!)
        if let newsTableViewCell = newsTableViewCell
        {
            newsTableViewCell.thumbnailView.isHidden = true
            
            toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
            containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)

            // create a wrapper view for the snapshotView to be able to displace the thumbnailView inside the wrapperView just like how the cells are set up
            let imageSnapshotViewWrapperView = UIView(frame: containerView.convert(fromViewController.newsImageView.frame, from: fromViewController.newsImageView.superview))
            imageSnapshotViewWrapperView.clipsToBounds = true
            imageSnapshotViewWrapperView.addSubview(imageSnapshotView!)
            
            containerView.addSubview(imageSnapshotViewWrapperView)

            // add a full view with white background to cover up the UI elements while the animation is going
            let whiteView = UIView(frame: fromViewController.view.frame)
            whiteView.backgroundColor = .white
            containerView.insertSubview(whiteView, belowSubview: imageSnapshotViewWrapperView)

            // start the animation
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
                fromViewController.view.alpha = 0.0
                // adjust the frame of the wrapperView
                imageSnapshotViewWrapperView.frame = containerView.convert(newsTableViewCell.thumbnailWrapperView.frame,
                                                                      from:newsTableViewCell.thumbnailWrapperView.superview)
                
                var newFrame = imageSnapshotView?.frame
                newFrame?.origin.y = newsTableViewCell.thumbnailView.frame.minY
                imageSnapshotView?.frame = newFrame!
            }, completion: { (finished) -> Void in
                // remove all the temporary views with a smooth animation
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    whiteView.removeFromSuperview()
                    imageSnapshotViewWrapperView.removeFromSuperview()
                    fromViewController.newsImageView.isHidden = false
                    newsTableViewCell.thumbnailView.isHidden = false
                })
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }) 
        }
    }
}
