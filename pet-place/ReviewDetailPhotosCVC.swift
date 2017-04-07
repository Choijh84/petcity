//
//  ReviewDetailPhotosCVC.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 16..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class ReviewDetailPhotosCVC: UICollectionViewCell {
    
    @IBOutlet weak var reviewPhotos: LoadingImageView!
    
    override func awakeFromNib() {
        reviewPhotos.layer.cornerRadius = 4.5
    }
    
}
