//
//  ReviewOptionsTableViewCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 19..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

// Custom tableviewCell to display a button that allows the user to read more reviews.
class ReviewOptionsTableViewCell: UITableViewCell {

    /// The button to read more reviews or login depending upon user state
    @IBOutlet weak var readMoreReviews: UIButton!
    
    /**
     Adds a target method  to the read more button 
        - parameter target: target
        - parameter action: action
        - parameter controlEvents: event
     */
    func addButtonTarget(_ target: AnyObject?, action: Selector, forControlEvents controlEvents: UIControlEvents) {
        readMoreReviews.addTarget(target, action: action, for: controlEvents)
    }
    
    /**
     Remove a target method from the button
     
     - parameter target: target
     - parameter action: action
     */
    func removeButtonTargets(_ target: AnyObject?, action: Selector) {
        readMoreReviews.removeTarget(target, action: action, for: .touchUpInside)
    }
    
    /**
     Change the title of the read more button.
     
     - parameter title:        title to set for the readMore button. It can also be used to display "Login"
     */
    func changeButtonTitle(_ title: String) {
        readMoreReviews.setTitle(title, for: UIControlState())
    }

}
