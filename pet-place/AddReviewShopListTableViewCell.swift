//
//  AddReviewShopListTableViewCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 5. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

// 리뷰를 스토리탭에서 추가할 때 주변 샵 리스트를 보여주는 테이블뷰 구성 셀
class AddReviewShopListTableViewCell: UITableViewCell {

    @IBOutlet weak var storeNameLabel: UILabel!
    
    @IBOutlet weak var storeServiceCategory: UILabel!
    
    @IBOutlet weak var storeDistanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
