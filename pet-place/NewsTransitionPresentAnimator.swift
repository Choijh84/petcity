//
//  NewsTransitionPresentAnimator.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 28..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// Animator object that is used when we display the news object detail viewController with a custom transition. The main idea is that we want to display a smooth animation, by taking the selected cell, take the image of the cell, add a white background behind it, move it to the desired position, than load the rest of the UI elements of the destination viewController.

class NewsTransitionPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    /**
        The duration of the animation.
    
        :param: transitionContext the transition context object
    
        :returns: the duration
    */
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    /**
        The main animation happens here. This is called when the user selects a cell at the tableView
    
        :param: transitionContext the transition context object
    */
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        /// Get all the related controllers and containers
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)! as! NewsListViewController
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)! as! NewsListDetailViewController
        let containerView = transitionContext.containerView

        let selectedIndexPath: IndexPath = fromViewController.tableView.indexPathForSelectedRow!
        let selectedCell = fromViewController.tableView.cellForRow(at: selectedIndexPath) as! NewsTableViewCell

        let cellImageSnapshot = selectedCell.thumbnailView.snapshotView(afterScreenUpdates: false)
        selectedCell.thumbnailView.isHidden = true
        
        /// adjust the frame of the detail viewController's view
        toViewController.view.alpha = 0.0
        toViewController.newsImageView.isHidden = true
        toViewController.newsImageView.image = selectedCell.thumbnailView.image
        
        /// Add it to the containerView
        containerView.addSubview(toViewController.view)
        
        // needed to get a nice transition between the cell and the view, since the thumbnailView is not fully visible in the tableView
        // create a new view that adds the cellImageSnapshot view as a subview
        let imageViewWrapperView = UIView(frame: containerView.convert(selectedCell.thumbnailWrapperView.frame, from: selectedCell.thumbnailWrapperView.superview))
        imageViewWrapperView.clipsToBounds = true
        imageViewWrapperView.addSubview(cellImageSnapshot!)
        containerView.addSubview(imageViewWrapperView)

        /// Insert a white view behind the moving imageView to hide all the UI elements
        let whiteView = UIView(frame: fromViewController.view.frame)
        whiteView.backgroundColor = .white
        containerView.insertSubview(whiteView, belowSubview: imageViewWrapperView)
        
        /**
        *  Start the animation
        */
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
            toViewController.view.alpha = 1.0

            // set the frame of the wrapperView to be the frame of destination viewControllers imageView (newsImageView), so it aligns perfectly
            let frame = containerView.convert(CGRect(x: 0.0, y: 0.0, width: toViewController.view.frame.width, height: toViewController.newsImageView.frame.height), from: toViewController.view)
            imageViewWrapperView.frame.origin.y = 0.0
            imageViewWrapperView.frame = frame
        }, completion: { (finished) -> Void in
            // finish the animation by removing all the temporary views
            toViewController.newsImageView.isHidden = false
            selectedCell.isHidden = false
            whiteView.removeFromSuperview()
            imageViewWrapperView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }

}
