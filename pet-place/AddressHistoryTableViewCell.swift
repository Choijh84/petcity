//
//  AddressHistoryTableViewCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 14..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class AddressHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var placeNameLabel: UILabel!
    
    @IBOutlet weak var placeAddressLabel: UILabel!
    
    var placeCoordinate: CLLocationCoordinate2D!
    
    @IBAction func deleteThisRow(_ sender: Any) {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
