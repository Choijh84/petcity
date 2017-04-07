//
//  SettingsViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 29..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import SCLAlertView

// 환경설정 뷰 컨트롤러
class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var pushSetting: UISwitch!
    
    @IBOutlet weak var SMSSetting: UISwitch!
    
    @IBOutlet weak var emailSetting: UISwitch!
    
    @IBOutlet weak var autoLoginSetting: UISwitch!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    
    // 저장 변수
    var isPush = false
    var isSMS = false
    var isEmail = false
    var isAutoLogin = false
    
    // 앱 푸쉬 알람 설정 열어주기
    @IBAction func openSetting(_ sender: Any) {
        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    // 문자 수신 동의 변경
    @IBAction func smsSettingChange(_ sender: Any) {
        let user = Backendless.sharedInstance().userService.currentUser
        if SMSSetting.isOn {
            user?.setProperty("isSMSReceive", object: true)
            SCLAlertView().showSuccess("이메일 수신", subTitle: "설정 ON")
        } else {
            user?.setProperty("isSMSReceive", object: false)
            SCLAlertView().showSuccess("이메일 수신", subTitle: "설정 OFF")
        }
        updateUser()
    }
    
    // 이메일 수신 동의 변경
    @IBAction func emailSettingChange(_ sender: Any) {
        let user = Backendless.sharedInstance().userService.currentUser
        if emailSetting.isOn {
            user?.setProperty("isEmailReceive", object: true)
            SCLAlertView().showSuccess("이메일 수신", subTitle: "설정 ON")
        } else {
            user?.setProperty("isEmailReceive", object: false)
            SCLAlertView().showSuccess("이메일 수신", subTitle: "설정 OFF")
        }
        updateUser()
    }
    
    // 자동 로그인 풀기
    @IBAction func autoLoginSettingChange(_ sender: Any) {
        let backendless = Backendless.sharedInstance()
        if autoLoginSetting.isOn {
            backendless?.userService.setStayLoggedIn(true)
            _ = UserDefaults.standard.set(true, forKey: "AutoLogin")
            SCLAlertView().showSuccess("자동 로그인", subTitle: "설정 ON")
        } else {
            backendless?.userService.setStayLoggedIn(false)
            _ = UserDefaults.standard.set(false, forKey: "AutoLogin")
            SCLAlertView().showSuccess("자동 로그인", subTitle: "설정 OFF")
        }
    }
    
    
    // 뷰를 불러오면서 현재 설정만 체크해서 변수에 저장
    override func viewDidLoad() {
        super.viewDidLoad()

        // 유저 설정 불러오기
        let user = Backendless.sharedInstance().userService.currentUser
        
        // 로컬 설정 불러오기
        if let dict = UserDefaults.standard.value(forKey: "AutoLogin") {
            isAutoLogin = dict as! Bool
        } else {
            isAutoLogin = true
        }
        // 자동 로그인 설정
        autoLoginSetting.setOn(isAutoLogin, animated: false)
        
        // getproperty is not working 우아아아아 열받아 우아아아아아아
        isSMS = user?.getProperty("isSMSReceive") as! Bool
        isEmail = user?.getProperty("isEmailReceive") as! Bool
        
        SMSSetting.setOn(isSMS, animated: false)
        emailSetting.setOn(isEmail, animated: false)
        
        print("This is SMS: \(isSMS) and Email: \(isEmail) and AutoLogin: \(isAutoLogin)")
        
        // 아래 셀 지우기
        tableView.tableFooterView = UIView(frame: .zero)
        
    }
    
    // 뷰가 없어질 때 변경사항만 확인해서 저장시키자
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 변경사항 저장하는 함수
        let user = Backendless.sharedInstance().userService.currentUser
        print("this is user name: \(String(describing: user?.name))")
        Backendless.sharedInstance().userService.update(user, response: { (updatedUser) in
            print("Updated user: \(String(describing: updatedUser))")
        }) { (Fault) in
            print("Server reported an error (2): \(String(describing: Fault))")
        }
    }

    // 유저의 변경사항 저장
    func updateUser() {
        let user = Backendless.sharedInstance().userService.currentUser
        Backendless.sharedInstance().userService.update(user, response: { (updatedUser) in
            print("Updated user: \(String(describing: updatedUser))")
        }) { (Fault) in
            print("Server reported an error (2): \(String(describing: Fault))")
        }
    }

    /// MARK: - TableView Controller Methods
    
    // 테이블뷰 선택했을 때, 세부사항으로 이동하게 만들어주는 함수
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("This is indexPath: \(indexPath)")
        
        if indexPath == [2,0] {
            // 서비스 약관 선택
            
        } else if indexPath == [4,0] {
            // 개발 정보 선택
            
        }
    }
    
    // 테이블 헤더 섹션 높이 설정 함수
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    // 테이블 헤더 폰트 및 사이즈 설정 함수
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "YiSunShin Dotum M", size: 15.0)
        header.textLabel?.textColor = UIColor.lightGray
    }

}
