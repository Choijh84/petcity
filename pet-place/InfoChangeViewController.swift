//
//  InfoChangeViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 28..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import M13Checkbox
import SCLAlertView

class InfoChangeViewController: UIViewController {

    var user = Backendless.sharedInstance().userService.currentUser
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var nameTextfield: UITextField!
    
    @IBOutlet weak var nicknameTextField: UITextField!
    
    @IBOutlet weak var mobileTextfield: UITextField!
    
    @IBOutlet weak var emailSubscribe: M13Checkbox!
    
    // 변경 버튼들
    @IBOutlet weak var passwordChangeButton: UIButton!
    @IBOutlet weak var nicknameChangeButton: UIButton!
    @IBOutlet weak var nameChangeButton: UIButton!
    @IBOutlet weak var mobileReAuthButton: UIButton!
    // 회원탈퇴 버튼
    @IBOutlet weak var leaveButton: UIButton!
    
    
    // UIColor 변수 - 체크박스 변경
    let falseColor = UIColor(red: 255/255, green: 224/255, blue: 130/255, alpha: 0.9)
    let trueColor = UIColor(red: 240/255, green: 244/255, blue: 195/255, alpha: 0.9)
    
    // 이메일 수신 동의
    var isEmailReceive = false
    
    // 입력된 값을 바탕으로 모두 저장
    @IBAction func allSave(_ sender: Any) {
        
    }
    

    // 이메일 수신 동의 버튼 클릭할 때 액션
    @IBAction func emailSubscribe(_ sender: Any) {
        changeEmailReceived()
    }
    
    // 비밀번호 변경 - 현재는 이메일을 발송하게 되어 있음
    @IBAction func passwordChange(_ sender: Any) {
        SCLAlertView().showWait("비밀번호 변경", subTitle: "등록된 주소로 이메일을 보냅니다")
        Backendless.sharedInstance().userService.restorePassword(user?.email! as String!, response: { (response) in
            SCLAlertView().showSuccess("이메일 확인", subTitle: "발송 완료")
            _ = self.navigationController?.popViewController(animated: true)
        }) { (Fault) in
            // 발송에 문제가 생긴 경우
            SCLAlertView().showError("이메일 발송 오류", subTitle: (Fault?.description)!)
        }
    }
    
    // 이름 변경
    @IBAction func nameChange(_ sender: Any) {
        let name = nameTextfield.text
        user?.setProperty("name", object: name)
        _ = Backendless.sharedInstance().userService.update(user)
        SCLAlertView().showSuccess("이름 변경", subTitle: "완료되었습니다")
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    // 닉네임 변경
    @IBAction func nicknameChange(_ sender: Any) {
        let nickname = nicknameTextField.text
        user?.setProperty("nickname", object: nickname)
        _ = Backendless.sharedInstance().userService.update(user)
        SCLAlertView().showSuccess("닉네임 변경", subTitle: "완료되었습니다")
    }
    
    // 전화 번호 변경 - 재인증 구현 필요, 현재는 그냥 변경되게 해둠
    @IBAction func phoneChange(_ sender: Any) {
        let phoneNumber = mobileTextfield.text
        print("this is phoneNumber: \(String(describing: phoneNumber))")
        user?.setProperty("phoneNumber", object: phoneNumber)
        _ = Backendless.sharedInstance().userService.update(user)
        SCLAlertView().showSuccess("전화번호 변경", subTitle: "완료되었습니다")
    }

    // 회원 탈퇴
    @IBAction func deleteUser(_ sender: Any) {
        // 먼저 물어보자 
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("확인") {
            /// How to delete User? Just change the ACL first?
            let dataStore = Backendless.sharedInstance().data.of(Users.ofClass())
            _ = dataStore?.remove(self.user)
            SCLAlertView().showSuccess("사용자 탈퇴", subTitle: "완료되었습니다")
            _ = self.navigationController?.popViewController(animated: true)
        }
        alertView.addButton("취소") {
            print("취소")
        }
        alertView.showWarning("확인 필요", subTitle: "정말 탈퇴하시겠습니까?")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이메일 수신 동의 버튼 세팅
        emailSubscribe.setCheckState(.unchecked, animated: true)
        emailSubscribe.animationDuration = 0.3
        emailSubscribe.stateChangeAnimation = .stroke
        emailSubscribe.backgroundColor = falseColor
        
        fetchUserInfo()
        setupInitialView()
    }
    
    /// 초기 화면 설정
    func setupInitialView() {
        // 이메일 라벨에 사용자 이메일 배당
        emailLabel.text = user?.email as String?
        
        // 변경 버튼, 탈퇴 버튼에 cornerRadius
        passwordChangeButton.layer.cornerRadius = 5.0
        nicknameChangeButton.layer.cornerRadius = 5.0
        nameChangeButton.layer.cornerRadius = 5.0
        mobileReAuthButton.layer.cornerRadius = 5.0
        leaveButton.layer.cornerRadius = 5.0
    }
    
    /// 유저 정보 읽어오기
    func fetchUserInfo() {
        if (user != nil) {
            if let name = user?.getProperty("name") {
                nameTextfield.text = name as? String
            }
            if let nickname = user?.getProperty("nickname") {
                nicknameTextField.text = nickname as? String
            }
            if let phoneNumber = user?.getProperty("phoneNumber") {
                print("this is phoneNumber: \(phoneNumber)")
                mobileTextfield.text = phoneNumber as? String
                mobileReAuthButton.setTitle("재인증", for: .normal)
            }
        } else {
            print("user has not logged in")
        }
    }
    
    /// 이메일 체크박스 상태에 따라서 상태값 변화
    func changeEmailReceived() {
        if isEmailReceive == true {
            self.emailSubscribe.backgroundColor = self.falseColor
            isEmailReceive = false
        } else {
            self.emailSubscribe.backgroundColor = self.trueColor
            isEmailReceive = true
        }
    }
    
    func describeUserAsync() {
        
        Backendless.sharedInstance().userService.describeUserClass({ (property) in
            print("This is user property: \(String(describing: property))")
        }) { (Fault) in
            print("This is fault: \(String(describing: Fault?.description))")
        }

    }
}




