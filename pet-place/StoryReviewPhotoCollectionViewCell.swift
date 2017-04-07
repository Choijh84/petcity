//
//  StoryReviewPhotoCollectionViewCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 22..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class StoryReviewPhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: LoadingImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = #imageLiteral(resourceName: "imageplaceholder")
    }
}
