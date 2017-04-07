//
//  MyStoryCollectionViewCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 4. 4..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// 내스토리에 들어가는 콜렉션뷰
class MyStoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var storyImage: LoadingImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        
        storyImage.layer.cornerRadius = 5.0
        timeLabel.layer.cornerRadius = 3.5
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        storyImage.image = #imageLiteral(resourceName: "imageplaceholder")
        timeLabel.text = ""
    }
}
