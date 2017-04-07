//
//  LocationHandler.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// Custom protocol to share the location, speed and heading information with other classes that implements this protocol

@objc protocol LocationHandlerProtocol {
    /**
     Returns the current location object
     
     :param: location current location of the user
     */
    func locationHandlerDidUpdateLocation(_ location: CLLocation)
}

/// Custom object to handle location and heading events

class LocationHandler: NSObject, CLLocationManagerDelegate {
    
    /// protocol object to be able to communicate with classes that implements it
    var locationHandlerProtocol: LocationHandlerProtocol?
    
    
    /// location manager to read GPS value 
    var locationManager: CLLocationManager = CLLocationManager()
    
    /// current location of the user
    var currentUserLocation: CLLocation?
    
    lazy var geocoder: CLGeocoder = {
        let geocoder = CLGeocoder()
        return geocoder
    }()
    
    /**
        Initializer of the class
    */
    override init() {
        super.init()
        setupLocationHandler()
    }
    
    /**
     Sets up the location manager and its properties
     */
    fileprivate func setupLocationHandler() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100
    }
    
    /**
     Starts the location tracking
     */
    func startLocationTracking() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    /**
     Stops the location tracking
     */
    func stopLocationTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    /** 
     Tells the delegate that new location data is available. If the speed is bigger than zero, call the protocol method to let
     other classes know of the new data available
     
     :param: manager The location manager object that generated the update event.
     :param: locations An array of CLLocation objects containing the location data
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let firstLocation = locations.first
        {
            locationHandlerProtocol?.locationHandlerDidUpdateLocation(firstLocation)
        }
        currentUserLocation = locations.first
    }
    
    // Geocoding
    /** 
    Returns a geocoded version of the passed in location, e.g.: New York, USA
    
    - parameter location: location to geocode
    - parameter completionBlock: block to call after completion
    - parameter placeMark : placeMark object if any 
    - parameter error: error if any 
    */
    
    func geocodeLocation(_ location: CLLocation, completionBlock: @escaping (_ geocodedName: String?, _ placeMark: CLPlacemark?, _ error: NSError?) -> ()) {
        geocoder.reverseGeocodeLocation(location) { (placeMarks, error) in
            if error == nil {
                var geocodedName = ""
                // Check if there is any placemark objects found
                if (placeMarks?.count)! > 0 {
                    let placeMark = placeMarks!.first
                    // check first for Locality = city (e.g. Seoul)
                    if let cityName = placeMark?.locality {
                        geocodedName = cityName
                        // Then search if we have country name
                        if let country = placeMark?.country {
                            geocodedName += ", " + country
                        }
                        
                        completionBlock(geocodedName, placeMark, nil)
                    } else {
                        completionBlock(nil, nil, nil)
                    }
                }
            } else {
                completionBlock(nil, nil, nil)
            }
        }
    }

}

