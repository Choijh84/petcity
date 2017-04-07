//
//  InquiryViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 28..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import DKImagePickerController
import SCLAlertView

// 문의하기 메뉴 뷰컨트롤러
class InquiryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // 문의 구분하기
    var inquiryType = ["로그인 문제", "장소 관련", "앱 이용 관련", "오류 발생 신고", "기타"]
    
    @IBOutlet weak var contactTextField: UITextField!
    var isContact = false
    
    @IBOutlet weak var inquiryTypeField: UITextField!
    var isType = false
    
    @IBOutlet weak var titleTextField: UITextField!
    var isTitle = false
    
    @IBOutlet weak var inquiryTextView: UITextView!
    var isInquiry = false
    
    @IBOutlet weak var imageView1: UIImageView!
    
    @IBOutlet weak var imageView2: UIImageView!
    
    @IBOutlet weak var imageView3: UIImageView!
    
    @IBOutlet weak var agreeTermButton: UIButton!
    var agreed = false
    
    // 입력값들이 비었는지 안 비었는지 체크
    func checkField() -> Bool {
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
        if isContact == true && isType == true && isTitle == true && isInquiry == true && agreed == true {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func agreeTerms(_ sender: Any) {
        if agreed == false {
            agreed = true
            agreeTermButton.backgroundColor = UIColor.blue
            agreeTermButton.setTitle("동의하셨습니다", for: .normal)
            agreeTermButton.setTitleColor(UIColor.white, for: .normal)
        } else {
            agreed = false
            agreeTermButton.backgroundColor = UIColor.red
            agreeTermButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    /// Imagepicker by DKImagePickerController
    var pickerController: DKImagePickerController!
    var assets: [DKAsset]?
    var imageArray = [UIImage]()
    
    /// When tap '사진 선택하기'
    @IBAction func pickPhoto(_ sender: Any) {
        inquiryTextView.resignFirstResponder()
        
        let actionsheet = UIAlertController(title: "Choose source", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionsheet.addAction(UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                self.pickerController.sourceType = .camera
                self.showImagePicker()
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            actionsheet.addAction(UIAlertAction(title: "Choose photo", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                self.pickerController.assetType = .allPhotos
                self.showImagePicker()
            }))
        }
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionsheet, animated: true, completion: nil)
    }
    
    // 보내기 눌렀을 때
    @IBAction func sendingInquiry(_ sender: Any) {
        /// shoulc check there is no nil in the field
        let isChecked = checkField()

        if isChecked == true {
            if imageArray.count != 0 {
                uploadPhotos(selectedImages: imageArray) { (success, url, error) in
                    if error == nil {
                        self.sendEmail(url: url)
                        SCLAlertView().showSuccess("Success", subTitle: "Sent!")
                        _ = self.navigationController?.popViewController(animated: true)
                    } else {
                        print("Server reported error: \(error)")
                    }
                }
            } else {
                self.sendEmail(url: "No Photo")
                SCLAlertView().showSuccess("Success", subTitle: "Sent!")
                _ = self.navigationController?.popViewController(animated: true)
            }
        } else {
            SCLAlertView().showWarning("확인 필요", subTitle: "모든 필드를 입력해주세요")
        }
        
    }
    
    func uploadPhotos(selectedImages: [UIImage]?, completionBlock: @escaping (_ completion: Bool, _ fileURL: String, _ errorMessage: String?) -> ()) {
        var totalFileURL = ""
        
        if let images = selectedImages {
            for var i in 0..<images.count {
                let fileName = String(format: "%0.0f\(i).jpeg", Date().timeIntervalSince1970)
                let filePath = "inquiry/\(fileName)"
                let content = UIImageJPEGRepresentation(images[i], 1.0)
                
                Backendless.sharedInstance().fileService.saveFile(filePath, content: content, response: { (uploadedFile) in
                    let fileURL = uploadedFile?.fileURL
                    print("This is totelFileURL:\(totalFileURL)")
                    if i == (images.count-1) {
                        totalFileURL.append(fileURL!)
                        print("This is FINAL I: \(i)")
                        print("FINAL totalFILEURL: \(totalFileURL)")
                        completionBlock(true, totalFileURL, nil)
                    } else {
                        totalFileURL.append(fileURL!+",")
                        i = i+1
                        print("This is I: \(i)")
                        print("ON THE WAY OF totalFILEURL: \(totalFileURL)")
                    }
                }, error: { (fault) in
                    completionBlock(false, "", fault?.description)
                })
            }
        }
    }
    
    /**
     이메일보내기 - ourpro.choi@com으로 설정되어 있음
     - param: url for photo link user attached, will be inserted in email body
     */
    
    func sendEmail(url: String) {
        let userEmail = Backendless.sharedInstance().userService.currentUser.email
        let type = inquiryTypeField.text
        let title = titleTextField.text
        let mainText = inquiryTextView.text
        
        let subject = "Inquiry from User- Type: \(type!)"
        let body =
            "This is an email sent by \(userEmail!).<br>" +
            "Inquiry Title: \(title!)<br>" +
            "Main Inquiry - \(mainText!)<br>" +
            "There is photo url user attached: \(url)"
        
        // 이메일 받는 사람
        let recipient = "ourpro.choi@gmail.com"
        Backendless.sharedInstance().messagingService.sendHTMLEmail(subject, body: body, to: [recipient], response: { (response) in
            print("Inquiry Email has sent")
        }) { (Fault) in
            print("Server reported an error: \(Fault?.description)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let pickerView = UIPickerView()
        pickerView.delegate = self
        inquiryTypeField.inputView = pickerView
        agreeTermButton.backgroundColor = UIColor.red
        agreeTermButton.setTitleColor(UIColor.white, for: .normal)
        
        pickerController = DKImagePickerController()
        
        
    }
    
    // MARK: DKIMAGE PICKER
    func showImagePicker() {
        
        pickerController.showsCancelButton = true
        
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            
            self.assets = assets
            self.fromAssetToImageView()
        }
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            pickerController.modalPresentationStyle = .formSheet
        }
        
        self.present(pickerController, animated: true) {}
    }
    
    func fromAssetToImageView() {
        let num = assets?.count
        let basicSize = CGSize(width: 60, height: 60)
        
        imageArray.removeAll()
        
        if num == 0 {
            print("nothing")
        } else if num == 1 {
            if let asset = assets?[0] {
                asset.fetchImageWithSize(basicSize, completeBlock: { (image, info) in
                    self.imageView1.image = image
                    self.imageArray.append(image!.compressImage(image!))
                })
            }
        } else if num == 2 {
            if let asset = assets?[0] {
                asset.fetchImageWithSize(basicSize, completeBlock: { (image, info) in
                    self.imageView1.image = image
                    self.imageArray.append(image!.compressImage(image!))
                })
            }
            if let asset = assets?[1] {
                asset.fetchImageWithSize(basicSize, completeBlock: { (image, info) in
                    self.imageView2.image = image
                    self.imageArray.append(image!.compressImage(image!))
                })
            }
        } else if num == 3 {
            if let asset = assets?[0] {
                asset.fetchImageWithSize(basicSize, completeBlock: { (image, info) in
                    self.imageView1.image = image
                    self.imageArray.append(image!.compressImage(image!))
                })
            }
            if let asset = assets?[1] {
                asset.fetchImageWithSize(basicSize, completeBlock: { (image, info) in
                    self.imageView2.image = image
                    self.imageArray.append(image!.compressImage(image!))
                })
            }
            if let asset = assets?[2] {
                asset.fetchImageWithSize(basicSize, completeBlock: { (image, info) in
                    self.imageView3.image = image
                    self.imageArray.append(image!.compressImage(image!))
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTerms" {
            let destinationVC = segue.destination as! ShowTermsViewController
            destinationVC.urlString = "http://www.servicegenius.kr/docs/termsandconditions.html"
        }
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
