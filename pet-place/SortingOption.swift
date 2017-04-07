//
//  SortingOption.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//

import Foundation

enum SortingKey: String {
    case name = "name"
    case distance = "distance"
}

enum SortingKey1: String {
    case name = "name"
    case dog = "강아지"
    case cat = "고양이"
    // case reptiles = "파충류"
    // case bird = "조류"
}

enum SortingKey2: String {
    case name = "name"
    case small = "소형"
    case middle = "중형"
    case big = "대형"
}

/// Sorting option object - BASIC
class SortingOption: NSObject {
    
    /// Name of the sorting option
    var name: String?
    /// Key for the sorting
    var sortingKey: SortingKey?
    
    /**
     Initialises a new SortingOption with name and sortingKey
     
     - parameter name: name of the sorting
     - parameter sortingKey: key of the sorting
     
     - returns: SortingObject
     */
    init(name: String, sortingKey: SortingKey) {
        self.name = name
        self.sortingKey = sortingKey
        super.init()
    }
}


/// Sorting option object - Service Pet
class SortingOption1: NSObject {
    
    /// Name of the sorting option
    var name: String?
    /// Key for the sorting
    var sortingKey: SortingKey1?
    
    /**
     Initialises a new SortingOption with name and sortingKey
     
     - parameter name: name of the sorting
     - parameter sortingKey: key of the sorting
     
     - returns: SortingObject
     */
    init(name: String, sortingKey: SortingKey1) {
        self.name = name
        self.sortingKey = sortingKey
        super.init()
    }
    
}

/// Sorting option object - Size of Pet
class SortingOption2: NSObject {
    
    /// Name of the sorting option
    var name: String?
    /// Key for the sorting
    var sortingKey: SortingKey2?
    
    /**
     Initialises a new SortingOption with name and sortingKey
     
     - parameter name: name of the sorting
     - parameter sortingKey: key of the sorting
     
     - returns: SortingObject
     */
    init(name: String, sortingKey: SortingKey2) {
        self.name = name
        self.sortingKey = sortingKey
        super.init()
    }
    
}
