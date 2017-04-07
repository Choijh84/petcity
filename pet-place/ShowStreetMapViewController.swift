//
//  ShowStreetMapViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 19..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import GoogleMaps

class ShowStreetMapViewController: UIViewController, GMSMapViewDelegate {

    override func viewDidLoad() {
        let panoView = GMSPanoramaView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self.view = panoView
        
        panoView.moveNearCoordinate(CLLocationCoordinate2DMake(-33.732, 150.312))
    }


}
