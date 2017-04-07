//
//  BusinessInfoRow.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 2..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class BusinessInfoRow: UITableViewCell {

    @IBOutlet weak var businessInfoShowButton: UIButton!
    
    @IBOutlet weak var businessInfoStack: UIStackView!
    
    @IBOutlet weak var userAgreementButton: UIButton!
    
    @IBOutlet weak var privacyAgreementButton: UIButton!
    
    @IBOutlet weak var businessInfoButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        
    }


}
