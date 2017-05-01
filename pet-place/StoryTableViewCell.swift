//
//  StoryTableViewCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 15..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import SCLAlertView
import SKPhotoBrowser
import Kingfisher

protocol StoryTableViewCellProtocol: class {
    func actionTapped(tag: Int)
}

class StoryTableViewCell: UITableViewCell {
    
    /// 사진의 URL들을 모아놓은 리스트
    var photoList = [String]()
    
    var singlePhotoURL : String?
    
    /// 테이블뷰에 해당되는 스토리
    var selectedStory = Story()
    
    weak var delegate: StoryTableViewCellProtocol?
    var row: Int?
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var bodyTextLabel: UILabel!
    
    @IBOutlet weak var singleImage: UIImageView!
    
    @IBOutlet weak var morePhotoButton: UIButton!
    
    @IBOutlet weak var likeNumberLabel: UILabel!
    
    // 라이크버튼 눌렀을 때
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        // 버튼 너무 빨리 연속으로 못 누르게 막아놓기
        likeButton.isUserInteractionEnabled = false
        
        delegate?.actionTapped(tag: likeButton.tag)
        // 좋아하는 스토리인지 아닌지를 구분
        // 버튼의 이미지 변경 - 클릭하면 이미지 바뀌게
        // 좋아요를 눌렀을 때
        if sender.image(for: .normal) == #imageLiteral(resourceName: "like_bw") {
            self.likeTap()
            // 리로드되는 것만 체크해서 시간에 맞춰주자
            UIView.transition(with: sender, duration: 0.2, options: .transitionCrossDissolve, animations: {
                sender.setImage(#imageLiteral(resourceName: "like_red"), for: .normal)
            }, completion: nil)
            self.likeButton.isUserInteractionEnabled = true
            
        } else {
            // 좋아요를 취소할 때
            UIView.transition(with: sender, duration: 0.2, options: .transitionCrossDissolve, animations: {
                sender.setImage(#imageLiteral(resourceName: "like_bw"), for: .normal)
            }, completion: nil)
            self.likeButton.isUserInteractionEnabled = true
        }
    }
    
    
    /// 초기화
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 추가 사진 버튼은 숨기고 시작
        morePhotoButton.isHidden = true
    }
    
    func likeTap() {
        
        // 이미지 생성 안 보이게
        let likePic = UIImageView(image: #imageLiteral(resourceName: "animatePetCity"))
        likePic.frame.size.width = (singleImage.frame.size.width / 1.5)
        likePic.frame.size.height = (singleImage.frame.size.width / 1.5)
        likePic.center = singleImage.center
        likePic.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        likePic.alpha = 0.2
        likePic.contentMode = .scaleAspectFit
        self.addSubview(likePic)
        self.bringSubview(toFront: likePic)
        
        // 크기를 키우고 0.6초 동안 키우고 0.2초 동안 숨김
        DispatchQueue.main.async(execute: {
            UIView.animate(withDuration: 1, animations: {
                likePic.alpha = 0.8
                likePic.transform = CGAffineTransform(scaleX: 1, y: 1)
            }) { (success) in
                UIView.animate(withDuration: 0.4) {
                    likePic.fadeOut()
                }
            }
        })
    }
    
    // 재사용시 초기화 함수
    override func prepareForReuse() {
        // 라이크버튼, 라이크 개수, 댓글 개수, 본문 세팅 초기화
        likeButton.setImage(#imageLiteral(resourceName: "like_bw"), for: .normal)
        bodyTextLabel.text = ""
        likeNumberLabel.text = ""
        singleImage.image = nil
        morePhotoButton.isHidden = true
        super.prepareForReuse()
    }
}

