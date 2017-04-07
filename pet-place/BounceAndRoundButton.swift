//
//  BounceAndRoundButton.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 10..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

@IBDesignable
class BounceAndRoundButton: UIButton {

    @IBInspectable var cornerRadiusValue: CGFloat = 3.0 {
        didSet {
            setUpView()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpView()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpView()
    }
    func setUpView() {
        self.layer.cornerRadius = self.cornerRadiusValue
        self.clipsToBounds = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 6, options: .allowUserInteraction, animations: {
            self.transform = CGAffineTransform.identity
            
        }, completion: nil)
        
        super.touchesBegan(touches, with: event)
        
    }

}
