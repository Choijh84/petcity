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
            })
        } else {
            // 메뉴를 보이자
            UIView.animate(withDuration: 0.5, animations: { 
                self.menuLeading.constant = 0
                self.stackLeading.constant = 130
                self.stackTrailing.constant = -110
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
    

    /**
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var announcementButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var envSettingButton: UIButton!
    
    var announcementButtonCenter: CGPoint!
    var eventButtonCenter: CGPoint!
    var envSettingButtonCenter: CGPoint!
    
    @IBAction func announcementButtonPressed(_ sender: UIButton) {
        toggleButton(button: sender, onImage: #imageLiteral(resourceName: "more-black"), offImage: #imageLiteral(resourceName: "more"))
    }
    
    @IBAction func eventButtonPressed(_ sender: UIButton) {
        toggleButton(button: sender, onImage: #imageLiteral(resourceName: "more-black"), offImage: #imageLiteral(resourceName: "more"))
    }
    
    @IBAction func envButtonPressed(_ sender: UIButton) {
        toggleButton(button: sender, onImage: #imageLiteral(resourceName: "more-black"), offImage: #imageLiteral(resourceName: "more"))
    }
    
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        if moreButton.currentImage == #imageLiteral(resourceName: "more") {
            UIView.animate(withDuration: 0.3, animations: { 
                self.announcementButton.alpha = 1
                self.eventButton.alpha = 1
                self.envSettingButton.alpha = 1
                
                self.announcementButton.center = self.announcementButtonCenter
                self.eventButton.center = self.eventButtonCenter
                self.envSettingButton.center = self.envSettingButtonCenter
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.announcementButton.alpha = 0
                self.eventButton.alpha = 0
                self.envSettingButton.alpha = 0
                
                self.announcementButton.center = self.moreButton.center
                self.eventButton.center = self.moreButton.center
                self.envSettingButton.center = self.moreButton.center
            })
        }
        toggleButton(button: sender, onImage: #imageLiteral(resourceName: "more-black"), offImage: #imageLiteral(resourceName: "more"))
    }
    
    func toggleButton(button: UIButton, onImage: UIImage, offImage: UIImage) {
        if button.currentImage == offImage {
            button.setImage(onImage, for: .normal)
        } else {
            button.setImage(offImage, for: .normal)
        }
    }
     */
    
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
            
            if isProfilePictureChanged == false {
                DispatchQueue.main.async(execute: {
                    if let profile = UserManager.currentUser()?.getProperty("profileURL") {
                        if let url = profile as? String {
                            if url == "<null>" {
                                print("there is no profile pic")
                            } else {
                                self.profilePicture.hnk_setImage(from: URL(string: url))
                                print("This is profileURL1: \(url)")
                            }
                        }
                        
                    }
                })
            } else {
                print("profile picture has changed")
            }
            
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
        
        // 메뉴뷰 레이어 세팅
        menuView.layer.shadowOpacity = 1
        menuView.layer.shadowRadius = 10
    }
    
    /**
     Checks if the loginViewController is already presented, if not, it adds it as a subview to our view
     */
    func presentLoginViewController() {
        if loginViewController.view.superview == nil {
            loginViewController.view.frame = self.view.bounds
            loginViewController.willMove(toParentViewController: self)
            view.addSubview(loginViewController.view)
            loginViewController.didMove(toParentViewController: self)
            addChildViewController(loginViewController)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    /**
     Dismisses the login viewController if it is visible
     */
    func dismissLoginViewController() {
        if loginViewController.view.superview != nil {
            loginViewController.dismissView()
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "내 프로필"
        
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
        /// Start the image upload
        DispatchQueue.main.async { 
            self.imageUploadAsync(image: compressed)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imageUploadAsync(image: UIImage!) {
        print("\n============ Uploading image with the ASYNC API ============")
    
        if let selectedImage = image {
            let fileName = String(format: "%0.0f.jpeg", Date().timeIntervalSince1970)
            let filePath = "profileImages/\(fileName)"
            let content = UIImageJPEGRepresentation(selectedImage, 1.0)
            
            Backendless.sharedInstance().fileService.saveFile(filePath, content: content, response: { (uploadedFile) in
                let fileURL = uploadedFile?.fileURL
                print(fileURL!)
                self.profilePicture.hnk_setImage(from: URL(string: fileURL!))
                print("This is profileURL2: \(fileURL!)")
                
                let user = Backendless.sharedInstance().userService.currentUser
                _ = user?.setProperty("profileURL", object: fileURL)
                Backendless.sharedInstance().userService.update(user, response: { (updateUser) in
                    print("Change the profile Image")
                    self.isProfilePictureChanged = false
                }, error: { (fault) in
                    print("Server reported an error (2): \(fault!)")
                })
            }, error: { (fault) in
                print(fault.debugDescription)
            })
        } else {
            print("There is no data")
        }
    }

}
