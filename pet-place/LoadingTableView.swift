//
//  LoadingTableView.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 2..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// Custom UITableView to be able to display custom empty states, or loading indicators inside a tableView anywhere in the app
// Read more about it at: http://zappdesigntemplates.com/create-a-custom-uitableview-with-loading-indicator/

class LoadingTableView: UITableView {

    /// A reference to the image that we are usign
    let loadingImage = UIImage(named: "loadingIndicator")
    /// The imageView that holds the loading indicator image
    var loadingImageView: UIImageView

    /**
    Called after loading from a nib or Storyboard file. Creating the loading indicator view and adding it as a subview.

    :param: aDecoder self

    :returns: self
    */
    required init(coder aDecoder: NSCoder) {
        loadingImageView = UIImageView(image: loadingImage)
        super.init(coder: aDecoder)!
        adjustSizeOfLoadingIndicator()
        addSubview(loadingImageView)
        
    }
    
    override func reloadData() {
        super.reloadData()
        self.bringSubview(toFront: loadingImageView)
    }

    /**
    Shows the loading indicator and starts the animation for it
    */
    func showLoadingIndicator() {
        loadingImageView.isHidden = false
        self.bringSubview(toFront: loadingImageView)

        startRefreshing()
    }

    /**
    Hides the loading indicator
    */
    func hideLoadingIndicator() {
        loadingImageView.isHidden = true

        stopRefreshing()
    }

    /**
    Adjust the size so that the indicator is always in the middle of the screen
    */
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustSizeOfLoadingIndicator()
    }

    /**
    The method to adjust the size of the indicator
    */
    fileprivate func adjustSizeOfLoadingIndicator() {
        let loadingImageSize = loadingImage?.size
        
        let width = loadingImageSize!.width
        let height = loadingImageSize!.height
        loadingImageView.frame = CGRect(x: (frame.width-width)/2, y: (frame.height-height)/2, width: width, height: height)
        
    }

    /**
    Start the rotating animation
    */
    fileprivate func startRefreshing() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.isRemovedOnCompletion = false
        animation.toValue = .pi * 2.0
        animation.duration = 0.8
        animation.isCumulative = true
        animation.repeatCount = Float.infinity
        loadingImageView.layer.add(animation, forKey: "rotationAnimation")
    }

    /**
    Stops the rotating animation
    */
    fileprivate func stopRefreshing() {
        loadingImageView.layer.removeAllAnimations()
    }

}
