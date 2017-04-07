//
//  StoreNaverMapTableViewCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 4. 7..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class StoreNaverMapTableViewCell: UITableViewCell {

    @IBOutlet weak var mapView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    /**
     Prepares for reusing the cell, removing all annotations
     */
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }


}
