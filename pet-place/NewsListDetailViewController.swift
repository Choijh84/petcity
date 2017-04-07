//
//  NewsListDetailViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 28..
//  Copyright © 2017년 press.S. All rights reserved.
//
import Foundation
import UIKit

/**
*  A viewController to display additional information about the selected news object
*/

class NewsListDetailViewController: UIViewController, UINavigationControllerDelegate {

    /// The news object that we want to display information of
    var newsObjectToDisplay: News!

    /// Back button to dismiss the view
    @IBOutlet var backButton: UIButton!
    /// An imageView to display the image of the news object
    @IBOutlet var newsImageView: LoadingImageView!
    /// Label for the title of the NewsObject
    @IBOutlet var titleLabel: UILabel!
    /// Label for the creation date
    @IBOutlet var creationDateLabel: UILabel!
    /// Textview to display the description
    @IBOutlet var descriptionLabel: UILabel!
    /// The view that holds the description label
    @IBOutlet weak var containerView: UIView!
    /// The content view for the Scrollview
    @IBOutlet weak var scrollViewContentView: UIView!
    /// ScrollView to be able to have a large content
    @IBOutlet weak var scrollView: UIScrollView!

    /// interactive transition object to be able to dismiss the controller while keeping the custom transition
    fileprivate var interactivePopTransition: UIPercentDrivenInteractiveTransition!

    /**
        Called when the back button is pressed, dismiss the view
    */
    @IBAction func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    /**
        Show view elements with animation, meaning set the alpha value to 1.0 from 0.0
    */
    func showViewElementsWithAnimation() {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.backButton.alpha = 1.0
            self.titleLabel.alpha = 1.0
            self.descriptionLabel.alpha = 1.0
        })
    }

    /**
        Sets the tabBar visible or hides it
    
        :param: visible YES, if tabBar needs to be visible
    */
    func setTabbarVisibleWithAnimation(_ visible: Bool) {
        var tabBarFrame = navigationController?.tabBarController?.tabBar.frame
        if visible {
            tabBarFrame?.origin.y = view.frame.height - tabBarFrame!.height
        }
        else {
            tabBarFrame?.origin.y = view.frame.height
        }

        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.navigationController?.tabBarController?.tabBar.frame = tabBarFrame!
        })
    }

    // MARK: animation handling
    /**
    Called to allow the delegate to return a noninteractive animator object for use during view controller transitions.
    
    :param: navigationController The navigation controller whose navigation stack is changing.
    :param: operation            The type of transition operation that is occurring.
    :param: fromVC               The currently visible view controller.
    :param: toVC                 The view controller that should be visible at the end of the transition.
    
    :returns: The animator object responsible for managing the transition animations, or nil if you want to use the standard navigation controller transitions.
    */
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC == self && toVC.isKind(of: NewsListViewController.self) {
            return NewsTransitionDismissalAnimator()
        } else {
            return nil
        }
    }
    
    /**
    Called to allow the delegate to return an interactive animator object for use during view controller transitions.
    
    :param: navigationController The navigation controller whose navigation stack is changing.
    :param: animationController The noninteractive animator object provided by the delegate’s navigationController:animationControllerForOperation:fromViewController:toViewController: method.
    
    :returns: The animator object responsible for managing the transition animations, or nil if you want to use the standard navigation controller transitions.
    */
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if animationController.isKind(of: NewsTransitionDismissalAnimator.self) {
            return interactivePopTransition
        } else {
            return nil
        }
    }
    
    /**
    Called just after the navigation controller displays a view controller’s view and navigation item properties. Show the view elements
    
    :param: navigationController The navigation controller that is showing the view and properties of a view controller.
    :param: viewController       The view controller whose view and navigation item properties are being shown.
    :param: animated             YES/true to animate the transition; otherwise, NOfalse.
    */
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController.isKind(of: NewsListDetailViewController.self) {
            showViewElementsWithAnimation()
        }
    }
    
    /**
    Handles the screenPopRecognizer's gestures, when certain value reached, either finish the transition, or pop the viewcontroller
    
    :param: screenPopRecognizer the recognizer
    */
    func handlePopRecognizer(_ screenPopRecognizer: UIScreenEdgePanGestureRecognizer) {
        var progress = screenPopRecognizer.translation(in: view).x / view.frame.width
        progress = min(1.0, max(0.0, progress))
        
        switch screenPopRecognizer.state {
        
            case .began:
                interactivePopTransition = UIPercentDrivenInteractiveTransition()
                navigationController?.popViewController(animated: true)
            case .changed:
                interactivePopTransition.update(progress)
            case .cancelled, .ended, .failed:
                if progress > 0.5 {
                    interactivePopTransition.finish()
                }
                else {
                    interactivePopTransition.cancel()
                }
                interactivePopTransition = nil
            default:
                navigationController?.popViewController(animated: true)
        }
    }
        
    // MARK: view methods
    /**
        Called after the view has been loaded. Load the properties from the NewsObject
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        if let imageURL = newsObjectToDisplay.imageURL() {
            newsImageView.hnk_setImage(from: imageURL)
        }

        titleLabel.text = newsObjectToDisplay.title
        descriptionLabel.text = newsObjectToDisplay.descriptionText

        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        backButton.layer.shadowOpacity = 0.6
        backButton.layer.shadowRadius = 4.0

        // format the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        creationDateLabel.text = dateFormatter.string(from: newsObjectToDisplay.created! as Date)

        /// add an edge recognizer to be able to pop the view, when the user swipes from the left side of the screen
        let screenEdgePopRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(NewsListDetailViewController.handlePopRecognizer(_:)))
        screenEdgePopRecognizer.edges = .left
        view.addGestureRecognizer(screenEdgePopRecognizer)
    }

    /**
    Need to adjust the max layout width for the label to get the proper sizing
    */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        descriptionLabel.preferredMaxLayoutWidth = view.frame.width - 20.0
        view.layoutIfNeeded()
    }
    
    /**
    Show the view elements with animation when the view will appear
    
    :param: animated yes, if animated
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showViewElementsWithAnimation()
        self.navigationController?.setToolbarHidden(true, animated: false)
    }

    /**
        Hide the tabBar and set the navigation controller's delegate to this view
    
        :param: animated yes, if animated
    */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
        setTabbarVisibleWithAnimation(false)
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    /**
    Show the tabBar when the view is about to disappear
    
    :param: animated yes, if animated
    */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.delegate = nil
        setTabbarVisibleWithAnimation(true)
    }

    /**
    Prefers to hide the status bar

    :returns: true to hide it
    */
    override var prefersStatusBarHidden : Bool {
        return true
    }

    /**
    The preferred status bar style for the view controller.

    :returns: A UIStatusBarStyle key indicating your preferred status bar style for the view controller.
    */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
