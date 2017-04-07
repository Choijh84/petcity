//
//  StoreCategory.swift
//  Pet-Hotels
//
//  Created by Owner on 2016. 12. 25..
//  Copyright © 2016년 TwistWorld. All rights reserved.
//


import Foundation

 /// The category object for the Stores

class StoreCategory: NSObject {

    /// name of the category
    /// Example: hotel(동반호텔), pension(펜션), cafe(카페), restaurant(동반식당), hospital(동물병원), shop(용품샵), petBeauty(미용), petHoteling(맡기는 호텔), petDayCare(잠깐 맡기는 장소)
    var name: String?
    /// ID of the category
    var objectId: String?
    /// List of store Objects
    var stores =  [Store]()
    
    /**
     Checks if the 2 objects have the same objectId, if so, they are equal

     - parameter object: object to compare self with

     - returns: true if their objectId is equal
     */
    override func isEqual(_ object: Any?) -> Bool {
        if let rhs = object as? StoreCategory {
            return objectId == rhs.objectId
        }
        return false
    }

}
