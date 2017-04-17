//
//  FirstViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 20..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

struct MyFirstViewState {
    static var isLoaded = false
}

/// 처음에 앱 실행할 때 애니메이션 보여주는, 향후에는 유저 설정 체크해서 바로 메인으로 보내준다
class FirstViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var bodyLabel: UILabel!
    
    var isAlreadySeen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bodyLabel.alpha = 0.0
        titleLabel.alpha = 0.5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if MyFirstViewState.isLoaded == false {
            self.animateView()
        }
    }
    
    func animateView() {
        UIView.animate(withDuration: 3.0, delay: 0.5, options: .curveEaseIn, animations: {
            self.titleLabel.alpha = 1.0
            self.bodyLabel.alpha = 1.0
        }) { (true) in
            self.goNext()
            MyFirstViewState.isLoaded = true
        }
    }
    
    func goNext() {
        UIView.animateKeyframes(withDuration: 0, delay: 1, options: .calculationModeCubicPaced, animations: { 
            // self.performSegue(withIdentifier: "goToMain", sender: nil)
            // self.dismiss(animated: true, completion: nil)
            let homeTabbarController = StoryboardManager.homeTabbarController()
            self.present(homeTabbarController, animated: true, completion: nil)
        }, completion: nil)
    }
    
    func newText() {
        UIView.animate(withDuration: 1.5) { 
            self.bodyLabel.alpha = 1.0
        }
    }

}
