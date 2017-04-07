//
//  AccountTextField.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 2..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// TextField that is displayed on the Login viewController
@IBDesignable class AccountTextField: UITextField {

    /// Defines the color of the textField's border
    @IBInspectable var borderColor: UIColor = UIColor.lightGray {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    /// Defines the width of the border
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    /// Defines the corner radius of the field
    @IBInspectable var cornerRadius: CGFloat = 4.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    /// The distance from the left side of the field where the text should start
    @IBInspectable var inset: CGFloat = 0

    /**
     Returns the drawing rectangle for the text field’s text.

     - parameter bounds: The bounding rectangle of the receiver.

     - returns: The computed drawing rectangle for the label’s text.
     */
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: inset)
    }

    /**
     Returns the rectangle in which editable text can be displayed.

     - parameter bounds: The bounding rectangle of the receiver.

     - returns: The computed editing rectangle for the text.
     */
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

}
