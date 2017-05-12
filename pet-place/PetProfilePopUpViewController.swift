//
//  PetProfilePopUpViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 31..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

// 펫 프로필의 예방접종 및 보유병력 이력 보여주는 팝업뷰
class PetProfilePopUpViewController: UIViewController {

    var selectedVaccine = ""
    var selectedSickHistory = ""
    // 뷰 그 자체
    @IBOutlet weak var popupView: UIView!
    // 제목 라벨
    @IBOutlet weak var titleLabel: UILabel!
    // 라벨 사용했으나 숨김
    @IBOutlet weak var contentsLabel: UILabel!
    // 텍스트뷰
    @IBOutlet weak var textView: UITextView!
    // 닫기 버튼
    @IBOutlet weak var closeButton: UIButton!
    // 닫기 액션
    @IBAction func dismissView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupView.layer.cornerRadius = 7.5
        closeButton.layer.cornerRadius = 7.5
        // 사용자 편집 불가
        textView.isEditable = false
        textView.layer.cornerRadius = 5.0

        // Do any additional setup after loading the view.
        if !selectedVaccine.isEmpty {
            textView.text = selectedVaccine
            titleLabel.text = "예방접종 이력"
        }
        
        if !selectedSickHistory.isEmpty {
            textView.text = selectedSickHistory
            titleLabel.text = "보유병력 이력"
        }
    }

}
