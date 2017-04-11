//
//  StoryAndReviewViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 15..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import SCLAlertView
import XLPagerTabStrip

class StoryAndReviewViewController: ButtonBarPagerTabStripViewController {

    @IBAction func addNewStory(_ sender: Any) {
        performSegue(withIdentifier: "newStory", sender: nil)
    }
    
    let blueInstagramColor = UIColor(red: 37/255.0, green: 111/255.0, blue: 206/255.0, alpha: 1.0)
    
    /// Lazy loader for LoginViewController, cause we might not need to initialize it in the first place
    lazy var loginViewController: LoginViewController = {
        let loginViewController = StoryboardManager.loginViewController()
        return loginViewController
    }()
    
    override func viewDidLoad() {

        // change selected bar color
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = blueInstagramColor
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0

        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = self?.blueInstagramColor
            
            if animated {
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    oldCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                })
            }
            else {
                newCell?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                oldCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        }
        
        let user = Backendless.sharedInstance().userService.currentUser
        
        // 유저 로그인이 안 되어있으면 버튼바 높이를 조절
        if user == nil {
            settings.style.buttonBarHeight = 0
        }
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let storyboard = UIStoryboard(name: "StoryAndReview", bundle: nil)
        let child_1 = storyboard.instantiateViewController(withIdentifier: "StoryViewController")
        let child_2 = storyboard.instantiateViewController(withIdentifier: "ReviewViewController")
        return [child_1, child_2]
    }
    
}
