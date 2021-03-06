//
//  LoadStoreViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 4. 29..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import SCLAlertView

class LoadStoreViewController: UIViewController {
    
    var storeList = [Store]()
    
    // 검색할 정보를 입력하는 텍스트 필드
    @IBOutlet weak var inputField: UITextField!
    // 불러오기 버튼
    @IBOutlet weak var loadButton: UIButton!
    
    
    // 불러오기
    @IBAction func tapShowResult(_ sender: Any) {
        
        inputField.resignFirstResponder()
        
        let dataStore = Backendless.sharedInstance().data.of(Store.ofClass())
        if let inputText = inputField.text {
            // 숫자인지 이름인지 체크
            if inputText.isNumber {
                // 숫자인 경우 전화번호 검색
                print("This is number")
                SCLAlertView().showNotice("검색 중입니다", subTitle: "전화 번호 확인 중")
                let phoneNumber = inputText
                
                let dataQuery = BackendlessDataQuery()
                dataQuery.whereClause = "phoneNumber LIKE \'%%\(phoneNumber)%%\'"
                
                dataStore?.find(dataQuery, response: { (collection) in
                    let storeList = collection?.data as! [Store]
                    dump(storeList)
                    self.storeList = storeList
                    self.performSegue(withIdentifier: "showResult", sender: nil)
                }, error: { (Fault) in
                    print("There is an error to fetch the place by phone number: \(String(describing: Fault?.description))")
                })
                
            } else {
                // 문자열인 경우 이름 검색
                print("This is String")
                let storeName = inputText
                SCLAlertView().showNotice("검색 중입니다", subTitle: "장소 이름 확인 중")
                
                let dataQuery = BackendlessDataQuery()
                dataQuery.whereClause = "name LIKE \'%%\(storeName)%%\'"
                
                dataStore?.find(dataQuery, response: { (collection) in
                    let storeList = collection?.data as! [Store]
                    dump(storeList)
                    self.storeList = storeList
                    self.performSegue(withIdentifier: "showResult", sender: nil)
                }, error: { (Fault) in
                    print("There is an error to fetch the place by name: \(String(describing: Fault?.description))")
                })
            }
        } else {
            SCLAlertView().showWarning("입력 확인", subTitle: "입력해주세요")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = "장소 검색"
        loadButton.layer.cornerRadius = 9
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResult" {
            let destinationVC = segue.destination as! PerformSearchViewController
            destinationVC.filteredStoreArray = self.storeList
        }
    }
    
}
