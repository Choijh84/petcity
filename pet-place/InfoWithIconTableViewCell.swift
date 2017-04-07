//
//  InfoWithIconTableViewCell.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 4..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// Custom tableViewCell to display an icon on the left and a textLabel next to it

class InfoWithIconTableViewCell: UITableViewCell {

    /// ImageView for the icon
    @IBOutlet weak var iconImageView: UIImageView!
    /// label to display
    @IBOutlet weak var infoLabel: UILabel!
    
    /**
     Set the separator to be full width
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutMargins = UIEdgeInsets.zero
        separatorInset = UIEdgeInsets.zero
    }
    
    /**
     Set the separator to be full width as its frame changes
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = UIEdgeInsets.zero
    }

}
