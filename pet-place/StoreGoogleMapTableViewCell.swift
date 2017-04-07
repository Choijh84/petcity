//
//  StoreGoogleMapTableViewCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 12..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import GoogleMaps
import SCLAlertView

class StoreGoogleMapTableViewCell: UITableViewCell, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        layoutMargins = UIEdgeInsets.zero
        separatorInset = UIEdgeInsets.zero
        
        // 스크롤 제스처, 확대/축소 제스처 비활성화
        mapView.settings.scrollGestures = false
        mapView.settings.zoomGestures = false
        
    }
    
    /**
     Prepares for reusing the cell, removing all annotations
     */
    override func prepareForReuse() {
        super.prepareForReuse()
        mapView.clear()
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
    func zoomMapToStoreLocation(_ store: Store) {
        
        let lat = store.location?.latitude as! Double
        let long = store.location?.longitude as! Double
        let storeLocation = CLLocationCoordinate2DMake(lat, long)
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude:long, zoom:13)
        mapView?.animate(to: camera)
        
        let marker = GMSMarker(position: storeLocation)
        marker.title = store.name
        marker.icon = UIImage(named: "pin")
        marker.map = mapView        
    }
    
    // 마커를 탭하면 전체맵으로 이동? 
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.open(URL(string:
                "comgooglemaps://?saddr=&daddr=\(Float(marker.position.latitude)),\(Float(marker.position.longitude))&directionsmode=driving")!, options: [:], completionHandler: nil)
            
        } else {
           print("Can't use comgooglemaps://");
        }
    }
}
