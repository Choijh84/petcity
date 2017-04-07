//
//  StoreListAnnotationView.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 4..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import MapKit

/**
 *  A custom MKAnnotationView to be able to present it on the mapView.
 */

class StoreListAnnotationView: MKAnnotationView {

    /// Custom view that helps identifying the Store object better
    fileprivate var markerView: StoreListMarkerView!
    
    /**
        Initializer method, Set the fram for the view, and add the markerView as a subview
 
        :parameter: annotation the annotation
        :parameter: reuseIdentifier the identifier
     
        :returns: self
    */
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        frame = CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)
        markerView = StoreListMarkerView(frame: frame)
        markerView.isUserInteractionEnabled = true
        addSubview(markerView)
    }
    
    /**
     Initialiser method
     
     :param: aDecoder NSCoder object
     
     :returns: self
     */
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    /**
     Initialiser method
     
     :param: frame frame to use
     
     :returns: self
     */
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }

}
