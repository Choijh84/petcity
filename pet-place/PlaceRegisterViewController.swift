//
//  PlaceRegisterViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 5..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import SCLAlertView
import GooglePlaces
import IQKeyboardManagerSwift

// 장소 추천 뷰컨트롤러
class PlaceRegisterViewController: UIViewController {
    
    // 이름(매장명 필드)
    @IBOutlet weak var nameTextField: UITextField!
    // 탭하면 구글 autoComplete로 이동, gestureRecognizer 설정 필요
    @IBOutlet weak var locationLabel: UILabel!
    // 추천 이유
    @IBOutlet weak var reasonTextView: UITextView!
    
    // 주소나 장소 관련된 정보를 저장할 변수
    var formattedAddress: String = ""
    var placeName: String = ""
    var placeID: String = ""
    var coordinate = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        IQKeyboardManager.sharedManager().enable = true
        
        // 뷰 설정
        nameTextField.layer.cornerRadius = 5.0
        locationLabel.layer.cornerRadius = 5.0
        reasonTextView.layer.cornerRadius = 5.0
        
        // 스택뷰안에서 textView가 보이려면 스크롤 false 필요, 안 그러면 사이즈 계산이 안됨
        reasonTextView.isScrollEnabled = false
        
        // Tap Gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(autocompleteClicked))
        tap.numberOfTapsRequired = 1
        locationLabel.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    /** 
      Define the action when user tap the submit button
     */
    
    @IBAction func submitOnTap(_ sender: Any) {
        print("name: \(String(describing: nameTextField.text)), location: \(String(describing: locationLabel.text))")
        
        if nameTextField.text?.isEmpty == true || locationLabel.text?.isEmpty == true || nameTextField.text == "매장명을 입력해주세요" || reasonTextView.text.isEmpty {

            SCLAlertView().showWarning("입력 필요", subTitle: "입력 확인 부탁드립니다")

        } else {
            
            self.sendEmail()
            
        }
    }
    
    // 위치 검색을 클릭하면 autoComplete뷰가 보임
    func autocompleteClicked() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Set a filter to return only address
        let addressFilter = GMSAutocompleteFilter()
        addressFilter.type = .noFilter
        addressFilter.country = "KR"
        autocompleteController.autocompleteFilter = addressFilter
        
        present(autocompleteController, animated: true, completion: nil)
    }
    
    
    // Send email to designated person, 현재 수신인: ourpro.choi@gmail.com
    func sendEmail() {
        let userEmail = Backendless.sharedInstance().userService.currentUser.email
        let name = nameTextField.text
        let reason = reasonTextView.text
        
        let subject = "Recommendation from User"
        let body = "This is an email sent by \(userEmail!).\n User recommends this place: \(name!) and the reason is like this - \(reason!)"
        let recipient = "ourpro.choi@gmail.com"
        Backendless.sharedInstance().messagingService.sendHTMLEmail(subject, body: body, to: [recipient], response: { (response) in
            SCLAlertView().showSuccess("제출 완료", subTitle: "제출되었습니다")
            self.nameTextField.text = ""
            self.locationLabel.text = ""
            self.reasonTextView.text = ""
        }) { (Fault) in
            print("Server reported an error: \(String(describing: Fault?.description))")
        }
    }
    
    func fillAutoCompleteButton() {
        var connected = ""
        // 장소 이름이 있는지 없는지 검사
        if placeName.isEmpty {
            connected = formattedAddress
        } else {
            connected = " \(placeName) : \(formattedAddress) "
        }
        locationLabel.fadeIn(0.3, delay: 0) { (true) in
            self.locationLabel.text = connected
        }
    }
}

// 오토컴플리트 익스텐션
extension PlaceRegisterViewController: GMSAutocompleteViewControllerDelegate {
    
    // GMSAutocompleteVC에서 유저의 검색을 처리
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        // Print place info to the console.
        print("Place name: \(place.name)")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(String(describing: place.attributions))")
        print("Place Geolocation: \(place.coordinate)")
        
        if let address = place.formattedAddress {
            placeName = place.name
            placeID = place.placeID
            formattedAddress = address
            coordinate = place.coordinate
        }
        
        // 로컬리티 데이터 체크
        var locality = ""
        if let addressLines = place.addressComponents {
            for field in addressLines {
                switch field.type {
                case kGMSPlaceTypeLocality:
                    locality = field.name
                    print("This is locality: \(locality)")
                default:
                    print("Type: \(field.type), Name: \(field.name)")
                }
            }
        }
        
        // Call custom function to populate the address form.
        UIView.animate(withDuration: 0.3) {
            self.fillAutoCompleteButton()
        }
        
        
        // Close the autocomplete widget.
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
        self.dismiss(animated: true, completion: nil)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Show the network activity indicator.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    // Hide the network activity indicator.
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

