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
    
    @IBOutlet weak var profileImageView: LoadingImageView!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var likeNumberLabel: UILabel!
    
    @IBOutlet weak var bodyTextLabel: UILabel!
    
    @IBOutlet weak var commentNumberLabel: UILabel!
    
    @IBOutlet weak var singleImage: UIImageView!
    
    @IBOutlet weak var readMoreButton: UIButton!
    
    @IBOutlet weak var morePhotoButton: UIButton!
    
    
    // 라이크버튼 눌렀을 때
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        // 버튼 너무 빨리 못 누르게 막아놓기
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
    
    // 댓글버튼 누르면 Reply 창으로 이동 tag = 1
    @IBAction func commentButtonClicked(_ sender: Any) {
        print("Comment Button Clicked: \(commentButton.tag)")
        delegate?.actionTapped(tag: commentButton.tag)
    }
    
    // 공유버튼 누르면 액션 실행
    @IBAction func shareButtonClicked(_ sender: Any) {
        print("Share Button Clicked: \(shareButton.tag)")
        delegate?.actionTapped(tag: shareButton.tag)
    }
    
    @IBAction func moreButtonClicked(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("신고") {
            // 게시물 숨기기도 필요한가?
            // 서버나 관리자에게 이메일 보내기
            self.delegate?.actionTapped(tag: self.moreButton.tag)
        }
        alertView.addButton("취소") {
            print("취소되었습니다")
        }
        alertView.showWarning("신고하기", subTitle: "이 게시물을 위법/위해 게시물로 신고하시겠습니까?")
    }
    
    @IBAction func readMoreButtonClicked(_ sender: Any) {
        print("Read More Button Clicked: \(readMoreButton.tag)")
        delegate?.actionTapped(tag: readMoreButton.tag)
    }
    
    
    /// 초기화
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 이미지뷰 원형 모양으로
        profileImageView.layer.cornerRadius = profileImageView.layer.frame.width/2
        
        // 라벨에 gesture 부여 
        // tap1 - IBAction
        // tap2 - IBACtion
        // tap3 - IBAction
        // tap4 좋아요 라벨 누르면 좋아요 누른 유저를 보여주고 - showLikeUsers
        // tap5 댓글 라벨 누르면 댓글 창으로 이동 - showComments
        // tap6 사진 더블탭하면 브라우저 표시
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(StoryTableViewCell.showLikeUsers(_:)))
        likeNumberLabel.isUserInteractionEnabled = true
        likeNumberLabel.addGestureRecognizer(tap4)
        
        let tap5 = UITapGestureRecognizer(target: self, action: #selector(StoryTableViewCell.showComments(_:)))
        commentNumberLabel.isUserInteractionEnabled = true
        commentNumberLabel.addGestureRecognizer(tap5)

        // 더보기와 추가 사진 버튼은 숨기고 시작
        readMoreButton.isHidden = true
        morePhotoButton.isHidden = true
    }
    
    func showPhotos(_ sender: UITapGestureRecognizer) {
        print("Show Photos: \(String(describing: sender.view?.tag))")
        guard let row = sender.view?.tag else { return }
        delegate?.actionTapped(tag: row)
    }
    
    func showLikeUsers(_ sender: UITapGestureRecognizer) {
        print("Show Like Users: \(String(describing: sender.view?.tag))")
        guard let row = sender.view?.tag else { return }
        delegate?.actionTapped(tag: row)
    }
    
    func showComments(_ sender: UITapGestureRecognizer) {
        print("Show Comments: \(String(describing: sender.view?.tag))")
        guard let row = sender.view?.tag else { return }
        delegate?.actionTapped(tag: row)
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
        // 이미지 콜렉션뷰도 초기화하고 싶은데 어케 해야될까...
        likeButton.setImage(#imageLiteral(resourceName: "like_bw"), for: .normal)
        likeNumberLabel.text = ""
        commentNumberLabel.text = ""
        bodyTextLabel.text = ""
        singleImage.image = nil
        readMoreButton.isHidden = true
        
        super.prepareForReuse()
        
    }
}

