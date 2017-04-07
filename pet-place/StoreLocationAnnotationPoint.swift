//
//  StoreLocationAnnotationPoint.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 3..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import MapKit

/**
*  A custom MKAnnotationPoint to be able to assign our StoreObjects to it, for later use.
*/

class StoreLocationAnnotationPoint: MKPointAnnotation {

    /// The storeObject that is assigned to this point annotation
    var storeObject: Store?
    
}
