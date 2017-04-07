//
//  ReviewLocationCollectionViewCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 23..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class ReviewLocationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 7.5
        locationLabel.layer.cornerRadius = 7.5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        locationLabel.text = ""
    }
}
