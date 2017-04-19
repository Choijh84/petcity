//
//  storePhotoTableViewCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 20..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import SKPhotoBrowser

/// Custom tableViewCell to display photos of the store in the scrollView

class storePhotoTableViewCell: UITableViewCell {

    /// scrollview to display the imageView
    @IBOutlet weak var scrollView: UIScrollView!
    
    /// uiimageView to display the image
    @IBOutlet weak var storePhotoImage: LoadingImageView!
    
    /**
     Set the separator to be full width
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutMargins = UIEdgeInsets.zero
        separatorInset = UIEdgeInsets.zero
        // 우선 사용할 일이 없음 숨김
        storePhotoImage.isHidden = true
    }
    
    /**
     Set the separator to be full width as its frame changes
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = UIEdgeInsets.zero
    }

}
