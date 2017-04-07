//
//  GlobalApplicationKeys.swift
//  pet-place
//
//  Created by Owner on 2016. 12. 31..
//  Copyright © 2016년 press.S. All rights reserved.
//

import UIKit

/// An extension class for UIColor to be able to use own colors in this app, and be able to manage all of them from one class.

extension UIColor {

    class func rgbColor(red r: Float, green g: Float, blue b: Float) -> UIColor {
        return UIColor(red: CGFloat(r/255.0), green: CGFloat(g/255.0), blue: CGFloat(b/255.0), alpha: 1.0)
    }

    class func grayScaleColor(_ gray: Float) -> UIColor {
        return UIColor.rgbColor(red: gray, green: gray, blue: gray)
    }

    // global colors
    class func globalTintColor() -> UIColor {
        return UIColor.rgbColor(red: 54.0, green: 54.0, blue: 54.0)
    }

    class func navigationBarColor() -> UIColor {
        return UIColor.globalTintColor().withAlphaComponent(0.6)
    }

    class func navigationTitleColor() -> UIColor {
        return .white
    }

    class func separatorLineColor() -> UIColor {
        return .grayScaleColor(232.0)
    }
    
    class func tabBarTitleNormalColor() -> UIColor {
        return rgbColor(red: 92.0, green: 92.0, blue: 92.0)
    }

    class func hotelDetailActionButtonColor() -> UIColor {
        return rgbColor(red: 47.0, green: 52.0, blue: 61.0)
    }

}
