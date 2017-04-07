//
//  OnboardingButton.swift
//  ZappShopFinder
//
//  Created by Sztanyi Szabolcs on 04/11/15.
//  Copyright © 2015 Szabolcs Sztányi. All rights reserved.
//

import UIKit

/// Custom UIButton that is displayed on the OnboardingViewController
class OnboardingButton: UIButton {

    /// Custom activity indicator
    let activitiyIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)

    /**
     Start the animation of the activity indicator
     */
    func startLoadingAnimation() {
        activitiyIndicatorView.alpha = 1.0
        activitiyIndicatorView.startAnimating()

        titleLabel?.alpha = 0.0
        backgroundColor = .clear
    }

    /**
     Stops the animation of the activity indicator
     */
    func stopLoadingAnimation() {
        activitiyIndicatorView.alpha = 0.0
        activitiyIndicatorView.stopAnimating()

        titleLabel?.alpha = 1.0
        setupView()
    }

    /**
     Customises the button, and adds an activity indicator
     */
    override func awakeFromNib() {
        super.awakeFromNib()

        setTitleColor(.white, for: UIControlState())
        setTitleColor(UIColor(white: 1.0, alpha: 0.6), for: .highlighted)
        layer.cornerRadius = 6
        setupView()

        activitiyIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activitiyIndicatorView.alpha = 0.0
        addSubview(activitiyIndicatorView)
    }

    /**
     Sets the background of the button
     */
    func setupView() {
        backgroundColor = .rgbColor(red: 224.0, green: 146.0, blue: 0.0)
    }

    /**
     Adds constraints for the activity indicator
     */
    override func updateConstraints() {
        super.updateConstraints()
        addConstraint(NSLayoutConstraint(item: activitiyIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: activitiyIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }

}
