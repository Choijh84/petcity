//
//  OnboardingViewController.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController, LocationHandlerProtocol {

    /// Button to enable gps location
    @IBOutlet weak var gpsButton: OnboardingButton!
    
    /// Location handler to get the current location of the user 
    let locationHandler: LocationHandler = LocationHandler()
    
    /// Transition manager object that helps transition from this view to the home viewController
    let transitionManager = OnboardingTransitionManager()
    
    /**
     Called after the user pressed the gps button, starts the location handler to get new location
     */
    @IBAction func gpsButtonPressed() {
        gpsButton.startLoadingAnimation()
        locationHandler.startLocationTracking()
    }
    
    // MARK: location handler protocol methods
    /**
     Called when a valid location is found
     
     - parameter location: user's location
     */
    func locationHandlerDidUpdateLocation(_ location: CLLocation) {
        locationHandler.stopLocationTracking()
        transitionToHomeView()
    }
    
    /**
     Open the home view after user allowed location sharing
     */
    func transitionToHomeView() {
        GeneralSettings.saveOnboardingFinished()
        
        let homeTabbarController = StoryboardManager.homeTabbarController()
        // homeViewController.transitioningDelegate = transitionManager
        // homeViewController.modalPresentationStyle = .custom
        present(homeTabbarController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationHandler.locationHandlerProtocol = self
    }

    /**
     Show white statusbar
     - returns: White statusbar
     */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    

}
