//
//  StoryPhotoCollectionVIewCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 15..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class StoryPhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: LoadingImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
