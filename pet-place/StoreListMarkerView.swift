//
//  StoreListMarkerView.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 4..
//  Copyright © 2017년 press.S. All rights reserved.
//
import UIKit

/**
*  A custom view to be able to display and differentiate better the stores on the mapView. 
*/

class StoreListMarkerView: UIView {

    /**
        Initialiser method, to set up the view.
    
        :param: frame frame of the view
    
        :returns: self
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    /**
        Initialiser method, called after the nib is loaded
    
        :param: aDecoder NSCoder object
    
        :returns: self
    */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    /**
        Set ups the view
    */
    func setupView() {
        backgroundColor = .clear
    }

    /**
        Draws the look of the view. In this case, the view should have a white background, with green stroke around it.
    
        :param: rect the rectangle to draw in
    */
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()

        context?.setLineWidth(2.0)
        context?.setStrokeColor(UIColor.globalTintColor().cgColor)
        context?.setFillColor(UIColor.white.cgColor)
        context?.fillEllipse(in: rect)
        context?.strokeEllipse(in: CGRect(x: 1.0, y: 1.0, width: rect.size.width-2.0, height: rect.size.height-2.0))
    }
}
