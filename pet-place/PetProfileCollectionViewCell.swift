//
//  PetProfileCollectionViewCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 25..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class PetProfileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var petProfileImageView: LoadingImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var speciesLabel: UILabel!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    
    @IBOutlet weak var birthdayLabel: UILabel!
    
    @IBOutlet weak var registrationLabel: UILabel!
    
    @IBOutlet weak var neutralizedLabel: UILabel!
    
    @IBOutlet weak var vaccinationStackView: UIStackView!
    @IBOutlet weak var vaccinationLabel: UILabel!
    
    @IBOutlet weak var historyStackView: UIStackView!
    @IBOutlet weak var historyLabel: UILabel!
    
    /// Button to click to show or hide the information of Vaccination
    @IBOutlet weak var vaccinationShowHideButton: MyButton!
    /// Button to click to edit the pet's information
    @IBOutlet weak var editButton: MyButton!
    /// Button to click to delete the pet profile
    @IBOutlet weak var deleteButton: MyButton!
    
    /// Button to click to show or hide the history
    @IBOutlet weak var historyShowHideButton: MyButton!
    
    // @IBOutlet weak var pageNumber: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    override func awakeFromNib() {
        pageControl.layer.cornerRadius = 7.5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        editButton.removeTarget(nil, action: nil, for: .allEvents)
    }
}
