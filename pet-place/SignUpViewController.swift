//
//  SignUpViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 10..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import M13Checkbox
import SCLAlertView
import Branch

class SignUpViewController: UIViewController, UITextFieldDelegate {

    // 이메일 입력 필드
    @IBOutlet weak var emailTextField: UITextField!
    // 패스워드 입력 필드
    @IBOutlet weak var passwordTextField: UITextField!
    // 이메일 수신 동의 체크 버튼
    @IBOutlet weak var emailSubscribeButton: M13Checkbox!
    // 닉네임 입력 필드
    @IBOutlet weak var nicknameTextfield: UITextField!
    // 닉네임 중복 체크 버튼
    @IBOutlet weak var nickOverlapCheckButton: BounceAndRoundButton!
    // 전체 동의 버튼
    @IBOutlet weak var allAgreeButton: M13Checkbox!
    // 이용약관 동의 버튼
    @IBOutlet weak var agreementButton: BounceAndRoundButton!
    // 개인정보 수집이용 버튼
    @IBOutlet weak var privacyButton: BounceAndRoundButton!
    // 위치정보 서비스 동의 버튼
    @IBOutlet weak var locationButton: BounceAndRoundButton!
    // 마케팅 약관 동의 버튼
    @IBOutlet weak var marketingButton: BounceAndRoundButton!
    
    // 이메일 수신 동의
    var isEmailReceive = false
    // 문자 수신 동의
    var isSMSReceive = false
    
    // 닉네임 
    var isNickChecked = false
    
    // 약관 동의 변수 저장
    var isAgreement = false
    var isPrivacy = false
    var isLocation = false
    var isMarketing = false
    
    // UIColor 변수
    let falseColor = UIColor(red: 255/255, green: 224/255, blue: 130/255, alpha: 0.9)
    let trueColor = UIColor(red: 240/255, green: 244/255, blue: 195/255, alpha: 0.9)
    
    // 백그라운드 이미지뷰
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    let imageArray = [#imageLiteral(resourceName: "signupbg4"), #imageLiteral(resourceName: "signupbg1"), #imageLiteral(resourceName: "signupbg2"), #imageLiteral(resourceName: "signupbg3")]
    var imageCount = 0
    
    // 다음 단계 진행 버튼
    @IBAction func nextProcess(_ sender: Any) {
        // 이메일 입력 체크
        if let testStr = emailTextField.text {
            print("This is test result: \(isValidEmail(testStr: testStr))")
            if !isValidEmail(testStr: testStr) {
                SCLAlertView().showError("이메일 에러", subTitle: "다시 입력해주세요")
            } else {
                // 패스워드 체크
                if let testStr = passwordTextField.text {
                    print("This is test result: \(isValidPassword(testStr: testStr))")
                    if isValidPassword(testStr: testStr) {
                        // 닉네임 중복 체크
                        print("This is nickname check result: \(isNickChecked)")
                        if isNickChecked {
                            // 약관 체크
                            if isAgreement && isPrivacy && isLocation {
                                // 회원가입 데이터베이스 처리
                                let newUser = BackendlessUser()
                                newUser.email = self.emailTextField.text as NSString!
                                // 패스워드는 가입하고 나서 retrieve가 불가능 
                                let tempPassword = self.passwordTextField.text as NSString!
                                newUser.password = tempPassword
                                
                                Backendless.sharedInstance().userService.registering(newUser, response: { (registeredUser) in
                                    
                                    // 마케팅 선택 약관에 오케이하면 이메일과 문자 동시 처리
                                    if self.isMarketing == true {
                                        registeredUser?.setProperty("isEmailReceive", object: true)
                                        registeredUser?.setProperty("isSMSReceive", object: true)
                                        
                                    } else if (self.isEmailReceive == true) {
                                        // 이메일만 오케이하면 이메일만 처리
                                        registeredUser?.setProperty("isEmailReceive", object: true)
                                    }
                                    // 닉네임 설정
                                    // 이름 동시 설정
                                    registeredUser?.setProperty("nickname", object: self.nicknameTextfield.text as NSString!)
                                    registeredUser?.setProperty("name", object: self.nicknameTextfield.text as NSString!)
                                
                                    // 위설정 내용으로 사용자 업데이트 진행 - 마케팅 및 닉네임 관련
                                    Backendless.sharedInstance().userService.update(registeredUser, response: { (updatedUser) in
                                        SCLAlertView().showSuccess("가입 완료", subTitle: "감사합니다")
                                        
                                        // Branch에 이벤트 track
                                        Branch.getInstance().userCompletedAction("signup")
                                        
                                        // 바로 로그인
                                        Backendless.sharedInstance().userService.login(newUser.email! as String!, password: tempPassword as String!, response: { (loggedUser) in
                                            print("Logged In")
                                        }, error: { (Fault) in
                                            print("Server reported an error logging in user: \(String(describing: Fault?.description))")
                                        })
                                        
                                    }, error: { (Fault) in
                                        print("Server reported an error updating user: \(String(describing: Fault?.description))")
                                        SCLAlertView().showError("가입 실패", subTitle: "Retry")
                                    })
                                
                                    self.performSegue(withIdentifier: "showNext", sender: nil)
                                    
                                }, error: { (Fault) in
                                    // 서버에서 가입처리 안됨
                                    print("Server reported error on registering user: \(String(describing: Fault?.description))")
                                })
                            } else {
                                // 약관 동의 안되어있을 때
                                SCLAlertView().showError("약관 동의 필요", subTitle: "동의해주세요")
                            }
                        } else {
                            // 닉네임 중복이 되었을 때
                            SCLAlertView().showError("닉네임 체크", subTitle: "중복 체크가 필요해요")
                        }
                    } else {
                        // 패스워드 에러
                        SCLAlertView().showError("패스워드 에러", subTitle: "패스워드가 짧아요...!")
                    }
                }
            }
        }
    }
    
    // 이메일 수신 동의 버튼 클릭할 때 액션
    @IBAction func emailSubscribe(_ sender: Any) {
        changeEmailReceived()
    }
    // 닉네임 중복 체크 동의 버튼 클릭할 때 액션
    @IBAction func nickOverlapCheck(_ sender: Any) {
        // 데이터베이스에 닉네임 query 필요
        let dataStore = Backendless.sharedInstance().data.of(Users.ofClass())
        
        if let nickname = nicknameTextfield.text {
            if nickname.length == 0 {
                SCLAlertView().showError("입력 필요", subTitle: "닉네임을 입력해주세요")
            } else {
                let whereClause = "nickname = '\(nickname)'"
                let dataQuery = BackendlessDataQuery()
                dataQuery.whereClause = whereClause
                
                dataStore?.find(dataQuery, response: { (response) in
                    if response?.totalObjects == 0 {
                        // 만약에 데이터베이스에 닉네임이 안 겹칠 때
                        print("This is response1: \(String(describing: response))")
                        self.changeNickCheck()
                    } else {
                        // 데이터베이스에 겹칠 때
                        print("This is response2: \(String(describing: response))")
                        SCLAlertView().showError("닉네임 중복", subTitle: "다른 닉네임을 선택해주세요")
                        UIView.animate(withDuration: 0.3, animations: {
                            self.nickOverlapCheckButton.backgroundColor = self.falseColor
                            self.nickOverlapCheckButton.setTitle("중복 체크", for: .normal)
                        })
                        self.nicknameTextfield.becomeFirstResponder()
                    }
                }, error: { (Fault) in
                    print("Server reported an error: \(String(describing: Fault?.description))")
                })
            }
        }

    }
    
    // 전체 동의 버튼 클릭할 때 액션
    @IBAction func allAgree(_ sender: Any) {
        // 하나라도 동의가 안된 변수가 있을 때
        if !isAgreement || !isPrivacy || !isLocation || !isMarketing {
            // 동의로 변경
            if !isAgreement {
                changeAgree()
            }
            if !isPrivacy {
                changePrivacy()
            }
            if !isLocation {
                changeLocation()
            }
            if !isMarketing {
                changeMarketing()
            }
            // 모두 동의로 변경일 때 - 색만 변경
            changeAllAgree()
            allAgreeButton.setCheckState(.checked, animated: true)
        } else {
            // 모두 동의했을 때 취소 - 색 변경
            changeAgree()
            changePrivacy()
            changeLocation()
            changeMarketing()
            changeAllAgree()
            allAgreeButton.setCheckState(.unchecked, animated: true)
        }
    }
    
    @IBAction func agreementButtonTapped(_ sender: Any) {
        changeAgree()
    }
    @IBAction func privacyButtonTapped(_ sender: Any) {
        changePrivacy()
    }
    @IBAction func locationButtonTapped(_ sender: Any) {
        changeLocation()
    }
    
    @IBAction func marketingButtonTapped(_ sender: Any) {
        changeMarketing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이메일 수신 동의 버튼 세팅
        emailSubscribeButton.setCheckState(.unchecked, animated: true)
        emailSubscribeButton.animationDuration = 0.3
        emailSubscribeButton.stateChangeAnimation = .stroke
        emailSubscribeButton.backgroundColor = falseColor
        
        // 전체 동의 버튼 세팅
        allAgreeButton.setCheckState(.unchecked, animated: true)
        allAgreeButton.animationDuration = 0.3
        allAgreeButton.stateChangeAnimation = .stroke
        allAgreeButton.backgroundColor = falseColor
        
        
        // Button Background color setting
        allAgreeButton.backgroundColor = falseColor
        nickOverlapCheckButton.backgroundColor = falseColor
        agreementButton.backgroundColor = falseColor
        privacyButton.backgroundColor = falseColor
        locationButton.backgroundColor = falseColor
        marketingButton.backgroundColor = falseColor
        
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

    // 이메일 체크 - validation
    func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    // 패스워드 체크 - validation
    func isValidPassword(testStr:String) -> Bool {
        // Minimum 8 characters (at least 1 Alphabet and 1 Number)
        if testStr.length >= 8 {
            return true
        } else {
            return false
        }
    }
    
    func changeEmailReceived() {
        if isEmailReceive == true {
            self.emailSubscribeButton.backgroundColor = self.falseColor
            isEmailReceive = false
        } else {
            self.emailSubscribeButton.backgroundColor = self.trueColor
            isEmailReceive = true
        }
    }
    
    func changeNickCheck() {
        if isNickChecked == true {
            self.nickOverlapCheckButton.backgroundColor = self.falseColor
            self.nickOverlapCheckButton.setTitle("중복 체크", for: .normal)
            isNickChecked = false
        } else {
            self.nickOverlapCheckButton.backgroundColor = self.trueColor
            self.nickOverlapCheckButton.setTitle("체크 완료", for: .normal)
            isNickChecked = true
        }
    }
    
    func changeAllAgree() {
        if isAgreement && isPrivacy && isLocation && isMarketing {
            self.allAgreeButton.backgroundColor = self.trueColor
        } else {
            self.allAgreeButton.backgroundColor = self.falseColor
        }
    }
    
    func changeAgree() {
        // 만약 동의한 상태라면
        if isAgreement == true {
            UIView.animate(withDuration: 0.3, animations: { 
                // 텍스트 세팅
                self.agreementButton.setTitle("동의 필요", for: .normal)
                // 칼라 세팅
                self.agreementButton.backgroundColor = self.falseColor
            })
            isAgreement = false
        } else {
            // 동의안한 상태라면
            UIView.animate(withDuration: 0.3, animations: {
                // 텍스트 세팅
                self.agreementButton.setTitle("동의 완료", for: .normal)
                // 칼라 세팅
                self.agreementButton.backgroundColor = self.trueColor
            })
            isAgreement = true
        }
    }
    
    func changePrivacy() {
        // 만약 동의한 상태라면
        if  isPrivacy == true {
            UIView.animate(withDuration: 0.3, animations: {
                // 텍스트 세팅
                self.privacyButton.setTitle("동의 필요", for: .normal)
                // 칼라 세팅
                self.privacyButton.backgroundColor = self.falseColor
            })
            isPrivacy = false
        } else {
            // 동의안한 상태라면
            UIView.animate(withDuration: 0.3, animations: {
                // 텍스트 세팅
                self.privacyButton.setTitle("동의 완료", for: .normal)
                // 칼라 세팅
                self.privacyButton.backgroundColor = self.trueColor
            })
            isPrivacy = true
        }
    }
    
    func changeLocation() {
        // 만약 동의한 상태라면
        if  isLocation == true {
            UIView.animate(withDuration: 0.3, animations: {
                // 텍스트 세팅
                self.locationButton.setTitle("동의 필요", for: .normal)
                // 칼라 세팅
                self.locationButton.backgroundColor = self.falseColor
            })
            isLocation = false
        } else {
            // 동의안한 상태라면
            UIView.animate(withDuration: 0.3, animations: {
                // 텍스트 세팅
                self.locationButton.setTitle("동의 완료", for: .normal)
                // 칼라 세팅
                self.locationButton.backgroundColor = self.trueColor
            })
            isLocation = true
        }
    }
    
    func changeMarketing() {
        // 만약 동의한 상태라면
        if  isMarketing == true {
            UIView.animate(withDuration: 0.3, animations: {
                // 텍스트 세팅
                self.marketingButton.setTitle("동의 필요", for: .normal)
                // 칼라 세팅
                self.marketingButton.backgroundColor = self.falseColor
            })
            isMarketing = false
        } else {
            // 동의안한 상태라면
            UIView.animate(withDuration: 0.3, animations: {
                // 텍스트 세팅
                self.marketingButton.setTitle("동의 완료", for: .normal)
                // 칼라 세팅
                self.marketingButton.backgroundColor = self.trueColor
            })
            isMarketing = true
        }
    }
    
}

extension String {
    var length: Int {
        return self.characters.count
    }
}
