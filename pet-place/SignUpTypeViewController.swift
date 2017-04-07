//
//  SignUpTypeViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 28..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class SignUpTypeViewController: UIViewController {

    // 메세지 뷰 
    @IBOutlet weak var messageView: UIView!
    
    // 메세지 라벨
    @IBOutlet weak var messageLabel: UILabel!
    
    // 각 버튼
    @IBOutlet weak var facebookSignup: UIButton!
    @IBOutlet weak var googleSignup: UIButton!
    @IBOutlet weak var kakaoSignup: UIButton!
    @IBOutlet weak var naverSignup: UIButton!
    
    // 스택뷰
    @IBOutlet weak var entireStackview: UIStackView!
    
    // 백그라운드 이미지뷰
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    let imageArray = [#imageLiteral(resourceName: "signupbg4"), #imageLiteral(resourceName: "signupbg1"), #imageLiteral(resourceName: "signupbg2"), #imageLiteral(resourceName: "signupbg3")]
    var imageCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animateImages()
    }
    
    // 이미지뷰를 5초 간격으로 변환시키는 함수
    func animateImages() {
        print("This is imageCount: \(imageCount)")
        let image = imageArray[imageCount]
        UIView.transition(with: backgroundImageView, duration: 2.5, options: .transitionCrossDissolve, animations: {
            self.backgroundImageView.image = image
        }) { (finished) in
            var timer = Timer()
            timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(self.animateImages), userInfo: nil, repeats: false)
            if self.imageCount == self.imageArray.count - 1  {
                self.imageCount = 0
            } else {
                self.imageCount = self.imageCount + 1
            }
        }
    }
    
}
