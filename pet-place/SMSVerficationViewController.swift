//
//  SMSVerficationViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 10..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import SCLAlertView

class SMSVerficationViewController: UIViewController {

    // 회원가입한 유저 
    let user = Backendless.sharedInstance().userService.currentUser
    
    let url = "https://api.bluehouselab.com/smscenter/v1.0/sendsms"
    let appid = "petcity"
    let apikey = "8c8f208003ed11e7ba080cc47a1fcfae"
    
    // 인증 번호
    var generatedString = ""
    
    // 발송 횟수 - 최고 3회로 제한? 
    var sentCount = 0
    
    // 초기 설정 시간: 180초(3분)
    var timeLeft = 0
    var myTimer: Timer!
    
    // UIColor 변수
    let falseColor = UIColor(red: 255/255, green: 224/255, blue: 130/255, alpha: 0.9)
    let trueColor = UIColor(red: 240/255, green: 244/255, blue: 195/255, alpha: 0.9)
    
    // 핸드폰 번호 입력 필드
    @IBOutlet weak var phoneNumberField: UITextField!
    // 인증번호 입력 필드
    @IBOutlet weak var verificationField: UITextField!
    // 번호전송 버튼
    @IBOutlet weak var verificationButton: UIButton!
    
    // 남은 시간 라벨
    @IBOutlet weak var remainingTimeLabel: UILabel!
    // 시간 표시 라벨
    @IBOutlet weak var remainingTime: UILabel!
    // 휴대폰 번호 중복 경고 라벨
    @IBOutlet weak var overlapMessageLabel: UILabel!
    
    
    @IBAction func nextView(_ sender: Any) {
        // 인증했는지 물어보고 
        
        // 홈 뷰로 이동하기
        // 홈 화면으로 이동
        let vc = StoryboardManager.homeTabbarController()
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    // 번호 전송 요청
    @IBAction func verificationRequest(_ sender: Any) {
        
        if let phoneNumber = phoneNumberField.text {
            // 핸드폰 번호 Validation
            if validate(value: phoneNumber) {
                
                // 서버에 핸드폰 번호 중복 여부 체크 - 중복이면 중복 메세지 보여주기
                // 이 func안에서 데이터베이스 유효 및 발송까지 처리
                // 체크사항: 발송 횟수, 시간
                if sentCount > 3 {
                    SCLAlertView().showInfo("문자 발송", subTitle: "3회를 초과했습니다")
                } else {
                    checkPhoneNumber()
                }
                
            } else {
                SCLAlertView().showError("확인 필요", subTitle: "유효한 핸드폰 번호가 아닙니다")
            }
        } else {
            SCLAlertView().showError("확인 필요", subTitle: "핸드폰 번호 입력 필요")
        }
    }
    
    // 인증 요청
    @IBAction func verificationTry(_ sender: Any) {
        // 번호 매칭 & 시간 여부 확인
        if let input = verificationField.text {
            if timeLeft > 0 {
                // 데이터베이스에 확인
                let dataStore = Backendless.sharedInstance().data.of(SMSVerification.ofClass())
                
                let whereClause = "generatedString = '\(input)'"
                let dataQuery = BackendlessDataQuery()
                dataQuery.whereClause = whereClause
                
                dataStore?.find(dataQuery, response: { (response) in
                    
                    if response?.totalObjects == 0 {
                        // 만약에 데이터베이스에 인증 번호가 없을 때
                        print("This is response1: \(String(describing: response))")
                        SCLAlertView().showError("인증 실패", subTitle: "확인되지 않는 인증 번호")
                    } else {
                        // 데이터베이스에 인증 번호 확인
                        print("This is response2: \(String(describing: response))")
                        // 매칭 되면 핸드폰 번호 인증
                        SCLAlertView().showSuccess("인증 완료", subTitle: "감사합니다")
                        // 홈 화면으로 이동
                        let vc = StoryboardManager.homeTabbarController()
                        self.present(vc, animated: true, completion: nil)
                        // 유저 정보에 핸드폰 번호 저장
                        self.savePhoneNumber()
                        // 데이터베이스에서 인증 번호 삭제
                        self.deleteGenerateString(str: self.generatedString)
                        
                    }
                }, error: { (Fault) in
                    print("Server reported an error: \(String(describing: Fault?.description))")
                })
            } else {
                // 시간이 지났을 때
                SCLAlertView().showError("시간 초과", subTitle: "유효한 인증이 아닙니다")
            }
        } else {
            // 인증번호를 입력안했을 때
            SCLAlertView().showError("인증 번호", subTitle: "입력해주세요")
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("This is current user: \(String(describing: user))")
        
        // 아래 메세지 라벨들은 우선 숨김
        remainingTimeLabel.isHidden = true
        remainingTime.isHidden = true
        overlapMessageLabel.isHidden = true
    }
    
    // 핸드폰 번호 유효 체크
    func validate(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}\\d{3,4}\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        print("This is the result: \(result)")
        return result
    }

    // 데이터베이스에서 아직 유효한지 체크
    func checkSMS() -> Bool {
        // 인증번호 생성
        generate()
        
        // 데이터베이스 액세스
        let dataStore = Backendless.sharedInstance().data.of(SMSVerification.ofClass())
        
        let whereClause = "generatedString = '\(generatedString)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        dataStore?.find(dataQuery, response: { (response) in
            if response?.totalObjects == 0 {
                // 만약에 데이터베이스에 인증 번호가 안 겹칠 때
                // 데이터베이스에 인증번호 등록
                let newVerification = SMSVerification()
                newVerification.generatedString = self.generatedString
                dataStore?.save(newVerification, response: { (response) in
                    print("This is response on saving: \(String(describing: response))")
                }, error: { (Fault) in
                    print("Server reported an error to save: \(String(describing: Fault?.description))")
                })
                
            } else {
                // 데이터베이스에 겹치는 인증 번호가 있을 때
                // 반복 - 다시 인증 번호를 생성한다
                
                if self.checkSMS() {
                    self.sendSMS()
                }
            }
        }, error: { (Fault) in
            print("Server reported an error to make a query: \(String(describing: Fault?.description))")
        })
        
        return true
    }
    
    // 인증번호 생성
    func generate() {
        // 인증번호 초기화
        generatedString.removeAll()
        
        // 랜덤번호 6자리 생성
        for _ in 0...5 {
            let randomNum : UInt32 = arc4random_uniform(10) // range to 0 to 9
            let someString = String(randomNum)
            generatedString.append(someString)
        }
        print("This is 인증번호 생성: \(generatedString)")
    }
    
    // 유저 중 핸드폰 번호 중복 체크
    func checkPhoneNumber() {
        let dataStore = Backendless.sharedInstance().data.of(Users.ofClass())
        
        if let phoneNumber = phoneNumberField.text {
            let whereClause = "phoneNumber = '\(phoneNumber)'"
            let dataQuery = BackendlessDataQuery()
            dataQuery.whereClause = whereClause
            
            dataStore?.find(dataQuery, response: { (response) in
                
                if response?.totalObjects == 0 {
                    // 만약에 데이터베이스에 핸드폰 번호가 안 겹칠 때
                    print("This is response1: \(String(describing: response))")
                    self.overlapMessageLabel.isHidden = true
                    if self.checkSMS() {
                        self.sendSMS()
                        self.timerRunning()
                        self.remainingTimeLabel.isHidden = false
                        self.remainingTime.isHidden = false
                    }
                } else {
                    // 데이터베이스에 겹칠 때
                    print("This is response2: \(String(describing: response))")
                    self.overlapMessageLabel.isHidden = false
                    self.phoneNumberField.becomeFirstResponder()
                }
                
            }, error: { (Fault) in
                print("Server reported an error: \(String(describing: Fault?.description))")
            })
        }
    }
    
    
    // 문자 발송 함수
    func sendSMS() {
        var json: [String : Any] = [:]
        
        // appid와 apikey 인코딩
        let basic = "\(appid):\(apikey)"
        let data = basic.data(using: .utf8)
        let encoded = "Basic " + (data?.base64EncodedString())!
        print("This is encoded: \(encoded)")
        
        // 문자에 들어갈 내용 작성
        let content = "[펫시티] 인증번호는 [\(generatedString)]입니다."
        
        // JSON 생성 - 향후 sender 수정 필요
        if let phoneNumber = phoneNumberField.text {
            json = ["sender" : "01044934983", "receivers" : ["\(phoneNumber)"], "content" : content] as [String : Any]
        }
        
        // 헤더 생성, 설정
        let headers  = [
            "Authorization" : "\(encoded)",
            "Content-Type" : "application/json; charset=utf-8"
        ]
        
        // 전송 세팅
        let url = URL(string: self.url)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }
        
        task.resume()
        
        // 발송 여부 알람창 표시
        SCLAlertView().showSuccess("성공", subTitle: "인증 번호를 발송하였습니다")
        timeLeft = 30
        myTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SMSVerficationViewController.timerRunning), userInfo: nil, repeats: true)
        self.timerRunning()
        
        // 카운트 추가
        sentCount = sentCount + 1
    }
    
    // 유저 정보에 핸드폰 번호 저장
    func savePhoneNumber() {
        let dataStore = Backendless.sharedInstance().data.of(Users.ofClass())
        
        let loggedUser = Backendless.sharedInstance().userService.currentUser
        
        if let phoneNumber = phoneNumberField.text {
            loggedUser?.setProperty("phoneNumber", object: phoneNumber)
            
            dataStore?.save(loggedUser, response: { (response) in
                print("데이터베이스에 핸드폰 번호 저장 완료")
            }, error: { (Fault) in
                print("Server reported an error to save user Phone number: \(String(describing: Fault?.description))")
            })
            
        }
    }
    
    // 데이터베이스에서 인증 번호 삭제
    func deleteGenerateString(str: String) {
        let dataStore = Backendless.sharedInstance().data.of(SMSVerification.ofClass())
        
        let whereClause = "generatedString = '\(str)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        dataStore?.removeAll(dataQuery, response: { (response) in
            print("인증번호가 데이터베이스에서 삭제되었습니다")
        }, error: { (Fault) in
            print("Server reported an error to delete: \(String(describing: Fault?.description))")
        })
    }
    
    // 시간 함수
    func timerRunning() {
        if timeLeft > 0 {
            if timeLeft == 0 {
                // 타이머 무효
                myTimer.invalidate() // invalidate를 쓰면 다시 reuse가 안됨
                // 시간 대신 '시간 초과'로
                remainingTime.text = "시간 초과"
                // 버튼 텍스트를 재전송으로 변경
                verificationButton.setTitle("재전송", for: .normal)
                verificationButton.backgroundColor = falseColor
                // 데이터베이스에서 인증 번호 삭제
                self.deleteGenerateString(str: generatedString)
            }
            timeLeft -= 1
            _ = secondsToMsSs(timeLeft) { (minute, second) in
                self.remainingTime.text = "\(String(format: "%01d", minute)):\(String(format: "%02d", second))"
            }
        } else if timeLeft == 0 {
            // 타이머 무효
            myTimer.invalidate() // invalidate를 쓰면 다시 reuse가 안됨
            // 시간 대신 '시간 초과'로
            remainingTime.text = "시간 초과"
            // 버튼 텍스트를 재전송으로 변경
            verificationButton.setTitle("재전송", for: .normal)
            // 데이터베이스에서 인증 번호 삭제
            self.deleteGenerateString(str: generatedString)
        }
    }
    
    // 시간 형식 return
    func secondsToMsSs(_ seconds : Int, result: @escaping (Int, Int)->()) {
        result((seconds % 3600) / 60, (seconds % 3600) % 60)
    }

}
