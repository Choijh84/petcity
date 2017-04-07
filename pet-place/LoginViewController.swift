//
//  LoginViewController.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import M13Checkbox

 /// ViewController that allows a user to login or signup using either Facebook or credentials

class LoginViewController: UIViewController {

    /// Email field
    @IBOutlet weak var emailField: AccountTextField!
    /// Password field
    @IBOutlet weak var passwordField: AccountTextField!
    
    /// Login button
    @IBOutlet weak var loginButton: UIButton!
    /// Sign up button
    @IBOutlet weak var signupButton: UIButton!
    
    // 자동 로그인 버튼
    @IBOutlet weak var autoLoginBox: M13Checkbox!
    var isAutoLogin = false
    @IBOutlet weak var autoLoginLabel: UILabel!
    
    // UIColor 변수 - 체크박스 변경
    let falseColor = UIColor(red: 255/255, green: 224/255, blue: 130/255, alpha: 0.9)
    let trueColor = UIColor(red: 240/255, green: 244/255, blue: 195/255, alpha: 0.9)
    
    /// Facebook login button
    @IBOutlet weak var facebookLoginButton: UIButton!
    /// 구글 로그인 버튼
    @IBOutlet weak var googleLoginButton: KenButton!
    /// 카카오 로그인 버튼
    @IBOutlet weak var kakaoLoginButton: KenButton!
    /// 네이버 로그인 버
    @IBOutlet weak var naverLoginButton: KenButton!
    
    /// UIImageView that displays the company's logo
    @IBOutlet weak var companyLogoImageView: UIImageView!
    
    /// Close button, that is only shown if the view is not presented at My Profile view, but presented modally/Full screen
    @IBOutlet weak var closeButton: UIButton!
    
    /// Default value of the facebookButtonBottomConstraint layout constraint
    var defaultFacebookButtonBottomConstraint: CGFloat!
    
    /// Whether to display the login button or not
    var displayCloseButton: Bool = false
    
    /// Lazy loader for LoginViewController, cause we might not need to initialize it in the first place
    lazy var loginViewController: LoginViewController = {
        let loginViewController = StoryboardManager.loginViewController()
        return loginViewController
    }()
    
    /**
     Dismiss the view when the close button is pressed
     */
    @IBAction func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func autoLoginButtonClicked(_ sender: Any) {
        if isAutoLogin == true {
            self.autoLoginBox.backgroundColor = self.falseColor
            Backendless.sharedInstance().userService.setStayLoggedIn(true)
            isAutoLogin = false
        } else {
            self.autoLoginBox.backgroundColor = self.trueColor
            Backendless.sharedInstance().userService.setStayLoggedIn(false)
            isAutoLogin = true
        }
    }
    
    @IBAction func facebookLoginButtonTapped(_ sender: Any) {
//        easyFacebookLogin()
    }
    
    /**
     Called after the view is loaded. Adds a shadow to the company logo and registers itself for keyboard notifications.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMotionEffectToCompanyLogo()
        
        // 버튼들 코너 세팅
        loginButton.layer.cornerRadius = 7.5
        facebookLoginButton.layer.cornerRadius = 10
        signupButton.layer.cornerRadius = 7.5
        
        // 텍스트필드들 뷰 세팅
        emailField.layer.cornerRadius = 15
        emailField.layer.borderColor = UIColor.lightGray.cgColor
        emailField.layer.borderWidth = 1
        
        passwordField.layer.cornerRadius = 15
        passwordField.layer.borderColor = UIColor.lightGray.cgColor
        passwordField.layer.borderWidth = 1
        
        
        // 로고 이미지 쉐도우 세팅
        companyLogoImageView.layer.shadowColor = UIColor(white: 0.0, alpha: 0.3).cgColor
        companyLogoImageView.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        companyLogoImageView.layer.shadowOpacity = 0.6
        companyLogoImageView.layer.shadowRadius = 10
        
        // 자동로그인 버튼 세팅
        autoLoginBox.setCheckState(.unchecked, animated: true)
        autoLoginBox.animationDuration = 0.3
        autoLoginBox.stateChangeAnimation = .stroke
        autoLoginBox.backgroundColor = falseColor
        
        // 자동로그인 관련 숨기기
        autoLoginBox.isHidden = true
        autoLoginLabel.isHidden = true
        
        // NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        // NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // tap 세팅
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.viewWasTapped(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
        
        closeButton.isHidden = !displayCloseButton
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        if Backendless.sharedInstance().userService.currentUser != nil {
            dismissView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func easyFacebookLogin() {
        
        let fieldsMapping = ["email": "email"]
        
        Backendless.sharedInstance().userService.easyLogin(withFacebookFieldsMapping: fieldsMapping, permissions: ["email", "public_profile"], response: { (result) in
            print ("Result: \(String(describing: result))")
        }) { (Fault) in
            print("Server reported an error: \(String(describing: Fault?.description))")
        }
    }
    
    /**
     Called when the user taps on the view. Hides the keyboard if visible
     
     - parameter recognizer: the tapRecognizer that listened to the touch event
     */
    func viewWasTapped(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    /**
     Adds a special motion effect to the company logo, which means when you move around the iPhone on it's Y and X axis the logo will also move a bit
     around those axis. Just like the home screen.
     */
    func addMotionEffectToCompanyLogo() {
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -30
        horizontalMotionEffect.maximumRelativeValue = 30
        
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -20
        verticalMotionEffect.maximumRelativeValue = 20
        
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        companyLogoImageView.addMotionEffect(motionEffectGroup)
    }
    
    // MARK: login methods
    /**
     Called when the user taps on Login button, checks if all the fields are edited and tries to log the user in.
     */
    @IBAction func loginUser() {
        if emailField.text == nil {
            self.showAlertViewWithErrorMessage("Email is missing")
            return
        }
        
        if passwordField.text == nil {
            self.showAlertViewWithErrorMessage("Password is missing")
            return
        }
        
        // at this point, we should have a valid email and password
        UserManager.loginUser(withEmail: emailField.text!, password: passwordField.text!) { (successful, errorMessage) -> () in
            if successful == true {
                self.dismissView()
            } else {
                self.showAlertViewWithErrorMessage(errorMessage!)
            }
        }
    }
    
    /**
     Called when the user taps on Login via Facebook
     */
    @IBAction func loginUserViaFacebook() {
        UserManager.loginViaFacebook(withViewController: self) { (successful, errorMessage) -> () in
            if successful == true {
                self.dismissView()
            } else {
                self.showAlertViewWithErrorMessage(errorMessage!)
            }
        }
    }

    
    /**
     Shows an alertView with a given errorMessage
     
     - parameter errorMessage: error message string to show
     */
    func showAlertViewWithErrorMessage(_ errorMessage: String) {
        let alertView = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertView, animated: true, completion: nil)
    }
    
    /**
     Dismisses the view
     */
    func dismissView() {
        if let parentViewController = parent {
            emailField.text = ""
            passwordField.text = ""
            
            parentViewController.viewDidAppear(true)
            willMove(toParentViewController: nil)
            view.removeFromSuperview()
            didMove(toParentViewController: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
}
