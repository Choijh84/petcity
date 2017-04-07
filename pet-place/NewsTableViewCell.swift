//
//  NewsTableViewCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 28..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    /// Title label
    @IBOutlet weak var titleLabel: UILabel!
    /// Date label
    @IBOutlet weak var dateLabel: UILabel!
    /// ImageView to display the image of the news object
    @IBOutlet weak var thumbnailView: LoadingImageView!
    /// A wrapper view to be able to have the parallax effect when scrolling
    @IBOutlet weak var thumbnailWrapperView: UIView!
    /// Label to display the text of the news object
    @IBOutlet weak var descriptionTextLabel: UILabel!
    
    /**
     Called when the user scrolls the listView to achieve the parallax effect
     
     :param: offset the value which the imageView's frame should be offsetted
     */
    func offsetImageView(_ offset: CGPoint) {
        thumbnailView.frame = thumbnailView.bounds.offsetBy(dx: offset.x, dy: offset.y)
    }
    
    /**
     Prepare the cell for reuse, reset the imageView's image so it doesn't show a wrong image
     */
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailView.image = nil
    }

}
