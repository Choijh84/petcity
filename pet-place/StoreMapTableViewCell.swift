//
//  StoreMapTableViewCell.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 4..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import MapKit

/// Custom tableViewCell that displays a mapView inside it
class StoreMapTableViewCell: UITableViewCell, MKMapViewDelegate  {

    
    /// Map to display the store's location
    @IBOutlet weak var mapView: MKMapView!
    
    /**
     Set the separator to be full width
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layoutMargins = UIEdgeInsets.zero
        separatorInset = UIEdgeInsets.zero
    }

    /**
     Prepares for reusing the cell, removing all annotations
     */
    override func prepareForReuse() {
        super.prepareForReuse()
        mapView.removeAnnotations(mapView.annotations)
    }
    
    /** 
    Set the separator to be full width as frame changes
    */
    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = UIEdgeInsets.zero
    }

    /**
     Adds the store's location to the map and zooms to that location
     
     - parameter storeObject: store object to use
     */
    func zoomMapToStoreLocation(_ storeObject: Store) {
        
        let annotationPoint = StoreLocationAnnotationPoint()
        annotationPoint.coordinate = storeObject.coordinate()
        mapView.addAnnotation(annotationPoint)
        
        mapView.setCenter(storeObject.coordinate(), animated: false)
        mapView.showAnnotations(mapView.annotations, animated: false)
        mapView.setRegion(MKCoordinateRegionMake(annotationPoint.coordinate, MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)), animated: false)
    }
    
    /**
     Return what annotation views should be used for each annotation
     
     :param: mapView    The map view that requested the annotation view.
     :param: annotation The object representing the annotation that is about to be displayed.
     
     :returns: The annotation view to display for the specified annotation or nil if you want to display a standard annotation view.
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        } else {
            let annotationView = StoreListAnnotationView(annotation: annotation, reuseIdentifier: "Store")
            if (annotation is StoreLocationAnnotationPoint) {
                let annotationPoint = annotation as! StoreLocationAnnotationPoint
                annotationView.canShowCallout = false
                annotationView.annotation = annotationPoint
            }
            return annotationView
        }
    }
    
}
