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

enum SortingKey3: String {
    case name = "name"
    case Distance5km = "5km"
    case Distance10km = "10km"
    case Distance15km = "15km"
    case Distance20km = "20km"
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


/// Sorting option object - 서비스하는 반려동물의 종류
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

/// Sorting option object - 가능한 반려동물의 크기
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

/// Sorting option object - 장소의 반경
class SortingOption3: NSObject {
    
    /// Name of the sorting option
    var name: String?
    /// Key for the sorting
    var sortingKey: SortingKey3?
    
    /**
     Initialises a new SortingOption with name and sortingKey
     
     - parameter name: name of the sorting
     - parameter sortingKey: key of the sorting
     
     - returns: SortingObject
     */
    init(name: String, sortingKey: SortingKey3) {
        self.name = name
        self.sortingKey = sortingKey
        super.init()
    }
}

