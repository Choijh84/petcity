//
//  LoadingImageView.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 2..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// This class is intended to be used when you want to display a loading indicator inside the UIImageView, while the content is being loaded in the background

class LoadingImageView: UIImageView {

    /// the custom loading indicator
    fileprivate var loadingIndicator: UIImageView = UIImageView(image: UIImage(named: "loadingIndicator"))
    
    /// hides the loading indicator if the image was set
    override var image: UIImage? {
        didSet {
            hideLoadingIndicator()
        }
        willSet {
            UIView.animate(withDuration: 0.2) { 
                self.backgroundColor = UIColor.clear
            }
        }
    }

    /**
     Starts to animate the loading indicator
     */
    func showLoadingIndicator() {
        startLoading()
    }
    
    /**
     Stops to animate the loading indicator
     */
    func hideLoadingIndicator() {
        stopLoading()
        loadingIndicator.alpha = 0.0
    }
    
    public init() {
        super.init(image: #imageLiteral(resourceName: "imageplaceholder"))
    }
    
    public override init(image: UIImage?) {
        super.init(image: image)
        setupLoadingIndicator()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLoadingIndicator()
    }
    
    // MARK: private methods
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLoadingIndicator()
        
        if image == nil {
            showLoadingIndicator()
        }
    }
    
    /**
    Method to setup the loading indicator
    */
    fileprivate func setupLoadingIndicator() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        if !loadingIndicator.isDescendant(of: self) {
            addSubview(loadingIndicator)
        }
    }
    
    /**
     Start the rotating animation
     */
    fileprivate func startLoading() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.isRemovedOnCompletion = false
        animation.toValue = .pi * 2.0
        animation.duration = 0.8
        animation.isCumulative = true
        animation.repeatCount = Float.infinity
        loadingIndicator.layer.add(animation, forKey: "rotationAnimation")
    }
    
    /**
     Stops the rotating animation
     */
    fileprivate func stopLoading() {
        loadingIndicator.layer.removeAllAnimations()
    }
    
    /**
     Add the missing constraint to place the loading indicator in the middle of the UIImageView
     */
    override func updateConstraints() {
        super.updateConstraints()
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: loadingIndicator, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: loadingIndicator, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }
}
