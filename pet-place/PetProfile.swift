//
//  PetProfile.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 24..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// Pet Profile object related with User's pets

class PetProfile: NSObject {
    
    var objectId: String!
    /// Pet's birthday
    var birthday = Date()
    /// breed of the pet: 예: 말티즈, 세베리안 허스키 등
    var breed: String!
    /// gender of the pet
    var gender: String!
    /// Image url of the pet
    var imagePic: String?
    /// name of the pet 
    var name: String!
    /// whether to be neutrazlied or not: True - neutralized
    var neutralized: Bool = false
    /// registration number
    var registration: String = ""
    /// sick History 
    var sickHistory: String?
    /// species of the pet: Dog, Cat, Bird or sth else
    var species: String!
    /// weight of the pet
    var weight: Double = 0.0
    /// Vaccincation history 
    var vaccination: String?
    
    /// time when the Pet Profile was created
    var created: Date!
    
    /// time when the Pet Profile was updated
    var updated: Date?
    
}
