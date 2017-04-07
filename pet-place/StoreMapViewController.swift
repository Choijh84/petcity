//
//  StoreMapViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 10..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import GoogleMaps

class StoreMapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    
    /// A handler object that responsible for getting the user's location
    var locationHandler: LocationHandler!
    
    var locationManager = CLLocationManager()
    
    /// Last saved location
    var lastLocation: CLLocation?
    
    /// Last saved coordinate
    var lastCoordinate: CLLocationCoordinate2D?
    
    /// Variable to check whether user picked a location or not
    var isConfirmedLocation = false
    
    /// Location download manager, that will download all the objects from the server
    let downloadManager: LocationsDownloadManager = LocationsDownloadManager()
    
    /// selected Store Category(Type) from the StoresListImageViewController
    var selectedStoreType : StoreCategory!
    
    /// Objects that needs to be displayed
    var objectsArray: [Store] = []
    
    /// Selected store on the map
    var selectedStore: Store?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MAPS"
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        lastCoordinate = mapView.camera.target
        print("This is camera center: \(lastCoordinate)")
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /**
        Function defines the map up to the authorization status
     */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            
            mapView.isMyLocationEnabled = true
            // 내 위치 버튼
            mapView.settings.myLocationButton = true
            // 나침반 기능 활성화
            mapView.settings.compassButton = true
            // 스크롤 기능
            mapView.settings.scrollGestures = true
            // 제스처 기능
            mapView.settings.zoomGestures = true
            
        }
    }
    
    /**
        When the user location changes, update the map into that location
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation?
        if isConfirmedLocation == false {
            location = locations.last
            print("This is location: \(location!)")
        } else {
            location = lastLocation
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:13)
        mapView?.animate(to: camera)
        
        self.locationManager.stopUpdatingLocation()
    }
    
    /**
        Mapview delegate function when the camera change
        - get the center coordinate
        - if user moves the center of the map more than 5000m, 
        - marker clear, coordinate reset, and store download
     */
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let lat = mapView.camera.target.latitude
        let long = mapView.camera.target.longitude
        let coor = CLLocationCoordinate2DMake(lat, long)
        
        print(CLLocation.distance(from: lastCoordinate!, to: coor))
        if CLLocation.distance(from: lastCoordinate!, to: coor) > 5000 {
            // clear the map and objectsArray
            mapView.clear()
            objectsArray.removeAll()
            
            downloadManager.userCoordinate = coor
            lastCoordinate = coor
            downloadStores()
        } else {
            print("This time not fetch stores on the map")
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        for object in objectsArray {
            if object.name == marker.title! {
                selectedStore = object
            }
        }
        performSegue(withIdentifier: "showStore", sender: selectedStore)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStore" {
            let detailViewController = segue.destination as! StoreDetailViewController
            detailViewController.storeToDisplay = selectedStore
        }
    }
    
    /**
        Fetch the store from the database, radius 5km
        - error: show alert
        - no error: display store object function call
     */
    func downloadStores() {
        if lastCoordinate != nil {
            // Store Category assignmenet
            downloadManager.selectedStoreCategory = selectedStoreType
            
            downloadManager.downloadStores(skippingNumberOfObjects: 0, limit: 10, selectedStoreCategory: selectedStoreType, radius: 5, completionBlock: { (storeObj, error) in
                if let error = error {
                    self.showAlertViewWithRedownloadOption(error)
                } else {
                    self.displayStoreObjects(storeObj)
                }
            })
        }
    }
    
    /**
        Display the downloaded Store Objects and mark on the map
     */
    func displayStoreObjects(_ stores: [Store]?) {
        if lastLocation != nil {
            let position = CLLocationCoordinate2DMake((lastLocation?.coordinate.latitude)!, (lastLocation?.coordinate.longitude)!)
            let marker = GMSMarker(position: position)
            marker.title = "Custom Location"
            marker.icon = UIImage(named: "pin")
            marker.map = mapView
        }
        
        if let stores = stores {
            objectsArray = stores
            for store in stores {
                let lat = store.location?.latitude as! Double
                let long = store.location?.longitude as! Double
                let storeLocation = CLLocationCoordinate2DMake(lat, long)
                let marker = GMSMarker(position: storeLocation)
                marker.title = store.name
                marker.icon = UIImage(named: "pin")
                marker.map = mapView
            }
        } else {
            
        }
    }
    
    /**
     Shows an alertView and offers an option to redownload the stores again
     
     :param: error error to display
     */
    func showAlertViewWithRedownloadOption(_ error: String) {
        let alertView = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        alertView.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (alertAction) -> Void in
            self.downloadStores()
        }))
        present(alertView, animated: true, completion: nil)
    }
}

extension CLLocation {
    // In meteres, calculate the distance between two coordinates
    class func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
}
