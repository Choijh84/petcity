//
//  PasswordRetrieveViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 29..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import SCLAlertView

/// 패스워드 문의하는 뷰
class PasswordRetrieveViewController: UIViewController {
    
    // 문의 버튼, 누르면 바로 문의하기로 이동
    @IBOutlet weak var inquiryButton: UIButton!
    
    // 임시 비밀번호 받는 버튼
    @IBOutlet weak var tempPasswordButton: UIButton!
    
    // 이메일 입력하는 텍스트 필드
    @IBOutlet weak var emailTextfield: UITextField!
    
    
    
    // 임시 비멀번호 받기 누름
    @IBAction func sendEmailPassword(_ sender: Any) {
        
        if let email = emailTextfield.text {
            Backendless.sharedInstance().userService.restorePassword(email, response: { (result) in
                if (result != nil) {
                    SCLAlertView().showSuccess("이메일 발송 성공", subTitle: "확인부탁드립니다")
                }
            }, error: { (Fault) in
                if Fault?.faultCode == "3020" {
                    SCLAlertView().showError("사용자 에러", subTitle: "사용자를 찾을 수 없습니다")
                } else if Fault?.faultCode == "2002" {
                    SCLAlertView().showError("버전 에러", subTitle: "앱을 업데이트 해주세요")
                } else {
                    SCLAlertView().showError("에러", subTitle: "문의부탁드립니다")
                }
            })
        } else {
            SCLAlertView().showError("이메일 확인", subTitle: "이메일을 입력해주세요")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "비밀번호 찾기"
        
        // 뷰 세팅
        inquiryButton.layer.cornerRadius = 3.0
        tempPasswordButton.layer.cornerRadius = 10.0
        
    }
    
}
