//
//  InquiryViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 28..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import SCLAlertView

// 문의하기 메뉴 뷰컨트롤러
class InquiryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // 문의 구분하기
    var inquiryType = ["로그인 문제", "장소 관련", "앱 이용 관련", "오류 발생 신고", "기타"]
    
    @IBOutlet weak var nameTextField: UITextField!
    var isName = false
    
    @IBOutlet weak var contactTextField: UITextField!
    var isContact = false
    
    @IBOutlet weak var inquiryTypeField: UITextField!
    var isType = false
    
    @IBOutlet weak var titleTextField: UITextField!
    var isTitle = false
    
    @IBOutlet weak var inquiryTextView: UITextView!
    var isInquiry = false
    
    // 사진 뷰
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    
    var imageArray = [UIImage]()
    
    @IBOutlet weak var agreeTermButton: UIButton!
    var agreed = false
    
    let pickerController1 = UIImagePickerController()
    let pickerController2 = UIImagePickerController()
    let pickerController3 = UIImagePickerController()
    
    // 사진 추가 버튼
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    
    // 개인정보 수집 관련 뷰
    @IBOutlet weak var individualInfoView: UIView!
    
    // 개인정보 수집 관련 뷰 닫기 버튼
    @IBAction func viewHide(_ sender: Any) {
        UIView.animate(withDuration: 0.5) { 
            self.individualInfoView.fadeOut()
        }
    }
    
    // 개인정보 수집 관련 뷰 내용 보기
    @IBAction func viewShow(_ sender: Any) {
        UIView.animate(withDuration: 0.5) {
            self.individualInfoView.fadeIn()
        }
    }
    
    @IBAction func pickImage1(_ sender: Any) {
        // imageView1에 이미지가 있는지 없는지 체크
        // 이미지가 없으면 고르고 있으면 삭제
        if imageView1.image == nil {
            pickPhoto(sender as! UIButton)
        } else {
            // 사진 삭제할지 안할지 물어보기
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("YES") {
                self.imageView1.image = nil
                self.button1.setTitle("추가", for: .normal)
            }
            alertView.addButton("NO") {
                print("사진 삭제 취소")
            }
            alertView.showInfo("삭제하시겠습니까?", subTitle: "사진 삭제")
        }
    }
    
    @IBAction func pickImage2(_ sender: Any) {
        // imageView2에 이미지가 있는지 없는지 체크
        // 이미지가 없으면 고르고 있으면 삭제
        if imageView2.image == nil {
            pickPhoto(sender as! UIButton)
        } else {
            // 사진 삭제할지 안할지 물어보기
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("YES") {
                self.imageView2.image = nil
                self.button2.setTitle("추가", for: .normal)
            }
            alertView.addButton("NO") {
                print("사진 삭제 취소")
            }
            alertView.showInfo("삭제하시겠습니까?", subTitle: "사진 삭제")
        }
    }
    
    @IBAction func pickImage3(_ sender: Any) {
        // imageView3에 이미지가 있는지 없는지 체크
        // 이미지가 없으면 고르고 있으면 삭제
        if imageView3.image == nil {
            pickPhoto(sender as! UIButton)
        } else {
            // 사진 삭제할지 안할지 물어보기
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("YES") {
                self.imageView3.image = nil
                self.button3.setTitle("추가", for: .normal)
            }
            alertView.addButton("NO") {
                print("사진 삭제 취소")
            }
            alertView.showInfo("삭제하시겠습니까?", subTitle: "사진 삭제")
        }
    }
    
    /// 사진 고르기 버튼을 눌렀을 때
    func pickPhoto(_ button: UIButton) {
        inquiryTextView.resignFirstResponder()
        
        var picker = UIImagePickerController()
        
        if button.tag == 1 {
            picker = pickerController1
        } else if button.tag == 2 {
            picker = pickerController2
        } else if button.tag == 3 {
            picker = pickerController3
        }
        
        let actionsheet = UIAlertController(title: "Choose source", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionsheet.addAction(UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            actionsheet.addAction(UIAlertAction(title: "Choose photo", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
            }))
        }
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionsheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // use the image
        if picker == pickerController1 {
            imageView1.image = chosenImage
            button1.setTitle("삭제", for: .normal)
            button1.setTitleColor(UIColor.white, for: .normal)
        } else if picker == pickerController2 {
            imageView2.image = chosenImage
            button2.setTitle("삭제", for: .normal)
            button2.setTitleColor(UIColor.white, for: .normal)
        } else if picker == pickerController3 {
            imageView3.image = chosenImage
            button3.setTitle("삭제", for: .normal)
            button3.setTitleColor(UIColor.white, for: .normal)
        }

        
        dismiss(animated: true, completion: nil)
    }
    
    // 입력값들이 비었는지 안 비었는지 체크
    func checkField() -> Bool {
        if let text = nameTextField.text, !text.isEmpty {
            isName = true
        }
        if let text = contactTextField.text, !text.isEmpty {
            isContact = true
        }
        if let text = inquiryTypeField.text, !text.isEmpty {
            isType = true
        }
        if let text = titleTextField.text, !text.isEmpty {
            isTitle = true
        }
        if let text = inquiryTypeField.text, !text.isEmpty {
            isInquiry = true
        }
        if isName == true && isContact == true && isType == true && isTitle == true && isInquiry == true && agreed == true {
            return true
        } else {
            return false
        }
    }
    
    // 개인정보 수집 및 이용 동의를 누르면
    @IBAction func agreeTerms(_ sender: Any) {
        if agreed == false {
            agreed = true
            agreeTermButton.backgroundColor = UIColor.white
            agreeTermButton.setTitle("동의하셨습니다", for: .normal)
            agreeTermButton.setTitleColor(UIColor.darkGray, for: .normal)
        } else {
            agreed = false
            agreeTermButton.backgroundColor = UIColor.globalTintColor()
            agreeTermButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    // 보내기 눌렀을 때
    @IBAction func sendingInquiry(_ sender: Any) {
        
        /// shoulc check there is no nil in the field
        let isChecked = checkField()
        let containerName = "inquiry-images"
        
        // imageArray clear
        imageArray.removeAll()
        
        // 이미지부터 체크
        if let image = imageView1.image {
            self.imageArray.append(image)
        }
        if let image = imageView2.image {
            self.imageArray.append(image)
        }
        if let image = imageView3.image {
            self.imageArray.append(image)
        }

        if isChecked == true {
            if imageArray.count != 0 {
                PhotoManager().uploadBlobPhotos(selectedImages: imageArray, container: containerName, completionBlock: { (success, url, error) in
                    if success {
                        self.sendEmail(url: url!)
                        SCLAlertView().showSuccess("문의 접수 완료", subTitle: "감사합니다")
                        _ = self.navigationController?.popViewController(animated: true)
                    } else {
                        print("Server reported error: \(String(describing: error))")
                    }
                })
            } else {
                self.sendEmail(url: "사진 없음")
                SCLAlertView().showSuccess("문의 접수 완료", subTitle: "감사합니다")
                _ = self.navigationController?.popViewController(animated: true)
            }
        } else {
            SCLAlertView().showWarning("확인 필요", subTitle: "모든 필드를 입력해주세요")
        }
        
    }
    
    /**
     이메일보내기 - ourpro.choi@com으로 설정되어 있음
     - param: url for photo link user attached, will be inserted in email body
     */
    
    func sendEmail(url: String) {
        let name = nameTextField.text
        var userEmail = "No User"
        if let user = Backendless.sharedInstance().userService.currentUser {
            userEmail = user.email as String
        }
        let type = inquiryTypeField.text
        let title = titleTextField.text
        let mainText = inquiryTextView.text
        let contact = contactTextField.text
        
        let subject = "Inquiry from User- Type: \(type!)"
        let body =
            "사용자 이름 \(name!).<br>" +
            "사용자 이메일 \(userEmail).<br>" +
            "사용자 연락처: \(String(describing: contact))<br>" +
            "문의 제목: \(title!)<br>" +
            "상담 분류: \(String(describing: type))<br>" +
            "문의 글 - \(mainText!)<br>" +
            "There is photo url user attached: \(url)"
        
        // 이메일 받는 사람
        let recipient = "ourpro.choi@gmail.com"
        Backendless.sharedInstance().messagingService.sendHTMLEmail(subject, body: body, to: [recipient], response: { (response) in
            print("문의 관련 메일이 관리자에게로 보내짐")
        }) { (Fault) in
            print("Server reported an error: \(String(describing: Fault?.description))")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 픽커뷰 세팅
        let pickerView = UIPickerView()
        pickerView.delegate = self
        inquiryTypeField.inputView = pickerView
        
        // 이미지 픽커
        pickerController1.delegate = self
        pickerController2.delegate = self
        pickerController3.delegate = self
        
        // 동의 버튼 세팅
        agreeTermButton.backgroundColor = UIColor.globalTintColor()
        agreeTermButton.setTitleColor(UIColor.white, for: .normal)

        // 개인정보 수집 관련 뷰 숨기기
        individualInfoView.alpha = 0.0
        
        // 유저 정보 채우기
        let user = Backendless.sharedInstance().userService.currentUser
        if let name = user?.name {
            nameTextField.text = name as String
        }
        if let email = user?.email {
            contactTextField.text = email as String
        }
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    /// Set the number of components in pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return inquiryType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return inquiryType[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        inquiryTypeField.text = inquiryType[row]
    }
}
