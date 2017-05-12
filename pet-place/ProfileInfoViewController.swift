//
//  ProfileInfoViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import HCSStarRatingView
import SCLAlertView

/// A viewcontroller that displays the currently logged in user's information
/// After this work, should work on the next views

class ProfileInfoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    /// profile picure of the user
    @IBOutlet weak var profilePicture: UIImageView!
    /// the nickname label for the logged in user
    @IBOutlet weak var nicknameLabel: UILabel!
    /// Label that show the email address of the user
    @IBOutlet weak var loggedInEmailLabel: UILabel!
    //// The logout Button
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    /// 메뉴 보이는 버튼
    @IBOutlet weak var userMenu: UIBarButtonItem!
    
    // 메뉴가 보이는지 체크하는 변수
    var menuShowing = false
    
    /// Buttons for the next View
    @IBOutlet weak var favoriteListButton: UIButton!
    @IBOutlet weak var petProfileButton: UIButton!
    @IBOutlet weak var myInfoButton: UIButton!
    @IBOutlet weak var inquiryButton: UIButton!
    @IBOutlet weak var recommendButton: UIButton!
    @IBOutlet weak var myReviewButton: UIButton!
    
    /// 메뉴를 포함하고 있는 뷰
    @IBOutlet weak var menuView: UIView!
    
    /// 스택뷰 리딩 및 트레일링 변수
    @IBOutlet weak var stackLeading: NSLayoutConstraint!
    @IBOutlet weak var stackTrailing: NSLayoutConstraint!
    /// 메뉴뷰 리딩 변수 - 넓이는 120으로 설정해서 컨트롤
    @IBOutlet weak var menuLeading: NSLayoutConstraint!
    
    
    /// 메뉴 보이고 뷰를 조정하는
    @IBAction func showMenu(_ sender: Any) {
        if (menuShowing) {
            // 메뉴를 숨기자
            UIView.animate(withDuration: 0.5, animations: { 
                self.menuLeading.constant = -120
                self.stackLeading.constant = 0
                self.stackTrailing.constant = 0
                self.menuView.layer.shadowOpacity = 0
            })
        } else {
            // 메뉴를 보이자
            UIView.animate(withDuration: 0.5, animations: { 
                self.menuLeading.constant = 0
                self.stackLeading.constant = 130
                self.stackTrailing.constant = -110
                self.menuView.layer.shadowOpacity = 1
                self.menuView.layer.shadowRadius = 10
            })
        }
        menuShowing = !menuShowing
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func moveToNews(_ sender: Any) {
        let storyboard = UIStoryboard(name: "News", bundle: nil)
        let destination = storyboard.instantiateViewController(withIdentifier: "NewsListViewController") as! NewsListViewController
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    var isProfilePictureChanged = false
    
    /// Lazy loader for LoginViewController, cause we might not need to initialize it in the first place
    lazy var loginViewController: LoginViewController = {
        let loginViewController = StoryboardManager.loginViewController()
        return loginViewController
    }()
    
    /// Pet Profile Show, Done
    @IBAction func petProfileButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showPetProfile", sender: nil)
    }
    
    /// Favorite List Show, Done
    @IBAction func favoriteListButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showFavoriteList", sender: nil)
    }
    
    @IBAction func myReviewButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showMyReview", sender: nil)
    }
    
    /// Place Recommendation Show, Done
    @IBAction func recommendButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showPlaceRegister", sender: nil)
    }
    
    @IBAction func inquiryButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showInquiry", sender: nil)
    }
    
    @IBAction func myInfoButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showMyInfo", sender: nil)
    }
    
    /// Currently no use - bcs only use the current user information
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPetProfile" {
            print("This is Pet Profile Page")
        } else if segue.identifier == "showPlaceRegister" {
            print("This is place register page")
        }
    }
    
    /**
     Called when user taps on logout button, present an alertview asking for confirmation
     로그아웃 버튼 누르면 유저 로그인 체크, 의사를 다시 한 번 물어보고 로그아웃 실행
     */
    @IBAction func logoutButtonPressed() {
        if UserManager.isUserLoggedIn() {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("취소", action: { 
                print("취소되었습니다")
                self.dismiss(animated: true, completion: nil)
            })
            alertView.addButton("로그아웃") {
                self.logoutUser()
            }
            alertView.showInfo("로그아웃?", subTitle: "로그아웃하시겠습니까?")
            present(alertView, animated: true, completion: nil)
        } else {
            SCLAlertView().showWarning("사용자 정보", subTitle: "로그인이 되어 있지 않습니다")
        }
    }
    
    /**
     Log out the user and present the login viewcontroller
     로그아웃 실행
     */
    func logoutUser() {
        UserManager.logoutUser { (successful, errorMessage) -> () in
            if successful {
                self.presentLoginViewController()
                self.dismiss(animated: true, completion: nil)
                // self.navigationController?.popToRootViewController(animated: true)
            } else {
                // Present error
                self.displayAlertView(errorMessage!, title: "Error")
            }
        }
    }
    
    /**
     Display alert
     
     - parameter message: message to user
     - parameter title:   alert title
     */
    func displayAlertView(_ message: String, title: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertView, animated: true, completion: nil)
    }
    
    /**
     Here we can customise your view, I just assign the user's username to the label to show it
     */
    func customiseView() {
        
        // 프로필 사진 동그랗게 만들기
        profilePicture.layer.cornerRadius = profilePicture.layer.frame.width/2
        
        // 로그인 상태 체크에서 프로필 사진 및 이름 읽어오기
        if UserManager.isUserLoggedIn() == true {
            print("User has been logged")
            
            let userID = UserManager.currentUser()?.objectId
            let dataStore = Backendless.sharedInstance().data.of(Users.ofClass())
            
            dataStore?.findID(userID, response: { (responseUser) in
                if self.isProfilePictureChanged == false {
                    DispatchQueue.main.async(execute: {
                        if let profile = (responseUser as! BackendlessUser).getProperty("profileURL") {
                            if let url = profile as? String {
                                if url == "<null>" {
                                    print("there is no profile pic")
                                } else {
                                    if let url = URL(string: url) {
                                        // print("이게 프로필 url: \(url)")
                                        self.profilePicture.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imageLoadingHolder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
                                    }
                                }
                            }
                            
                        }
                    })
                } else {
                    print("profile picture has changed")
                }
            }, error: { (Fault) in
                print("에러: 유저 정보 가져오기 실패: \(String(describing: Fault?.description))")
            })
            
            // 이메일 체크
            if let email = UserManager.currentUser()?.email {
                loggedInEmailLabel.text = email as String
                print("This is email: \(email)")
                
            } else {
                loggedInEmailLabel.text = UserManager.currentUser()?.name as String?
            }
            
            // 닉네임 체크
            if let nickname = UserManager.currentUser()?.getProperty("nickname") {
                nicknameLabel.text = nickname as? String
                print("This is nickname: \(nickname)")
            } else {
                nicknameLabel.text = UserManager.currentUser()?.name as String?
            }
        } else {
            print("User hasn't been logged")
        }
    }
    
    /**
     Checks if the loginViewController is already presented, if not, it adds it as a subview to our view
     로그인뷰가 이미 뷰에 있는지 확인하고 없다면 로그인뷰를 현재뷰에 서브로 붙여서 보여준다 
     */
    func presentLoginViewController() {
        if loginViewController.view.superview == nil {
            loginViewController.view.frame = self.view.bounds
            loginViewController.willMove(toParentViewController: self)
            view.addSubview(loginViewController.view)
            loginViewController.didMove(toParentViewController: self)
            addChildViewController(loginViewController)
        }
    }
    
    /**
     Dismisses the login viewController if it is visible
     */
    func dismissLoginViewController() {
        // 만약에 현재 뷰 중에 로그인 뷰가 있다면 디스미스
        if loginViewController.view.superview != nil {
            loginViewController.dismissView()
        } else {
            // 없다면 아무 것도 안해도 됨
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("My Page", comment: "")
        
        // Do any additional setup after loading the view.
        /**
        announcementButtonCenter = announcementButton.center
        eventButtonCenter = eventButton.center
        envSettingButtonCenter = envSettingButton.center
        
        announcementButton.center = moreButton.center
        eventButton.center = moreButton.center
        envSettingButton.center = moreButton.center
        */
    }
    
    /**
     Check if the user is logged in or not. If yes, dismiss the login view if visible. If not present it
     
     - parameter animated: If true, the view is being added to the window using an animation.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserManager.isUserLoggedIn() {
            dismissLoginViewController()
            let currentUser = UserManager.currentUser()
            print("Current User: \(currentUser!)")
        } else {
            loggedInEmailLabel.text = ""
            presentLoginViewController()
        }
    }
    
    /**
     Customises the view after it appeares
     
     - parameter animated: animated
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        customiseView()
    }
    
    /**
     Use the default statusbar here (Black)
     
     - returns: the default statusbar
     */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }

    /// When the pencil, the button to change the profile picture clicked
    @IBAction func profilePictureChange(_ sender: Any) {
        let controller = UIImagePickerController()
        controller.delegate = self
        /// Need to change later
        controller.sourceType = .camera
        controller.sourceType = .photoLibrary
        
        present(controller, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = (info[UIImagePickerControllerOriginalImage] as! UIImage)
        let compressed = selectedImage.compressImage(selectedImage)
        
        /// First, change the view
        profilePicture.image = selectedImage
        isProfilePictureChanged = true
        
        /// 이미지 업로드
        DispatchQueue.main.async { 
            // 포토 매니저를 이용해 compress된 이미지를 profile-images 컨테이너에 저장
            PhotoManager().uploadBlobPhoto(selectedFile: compressed, container: "profile-image", completionBlock: { (success, fileURL, error) in
                let user = Backendless.sharedInstance().userService.currentUser
                _ = user?.setProperty("profileURL", object: fileURL)
                self.isProfilePictureChanged = false
                Backendless.sharedInstance().userService.update(user)
                self.displayAlertView("완료", title: "프로필 사진 변경")
            })
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
}
