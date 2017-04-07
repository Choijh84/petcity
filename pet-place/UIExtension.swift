//
//  UIExtension.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 2..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

extension UIView {
    
    func createBorder() {
        
        self.layer.borderWidth = 2
    }
    
    func createBorder(color: UIColor, width: CGFloat) {
        
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }

    func createRoundCorner(radius: CGFloat) {
        
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
    
    func createRoundCorner() {
        
        createRoundCorner(radius: 4)
    }
    
    func createBorderCorner() {
        
        createBorder()
        createRoundCorner()
    }
    
    func createCircleShape() {
        
        createRoundCorner(radius: self.frame.size.width / 2)
    }
    
    func commaInPriceIntoWon(price: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return "KRW " + numberFormatter.string(from: NSNumber(value: price))!
    }
    
}
