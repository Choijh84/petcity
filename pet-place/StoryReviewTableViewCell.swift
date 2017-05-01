//
//  StoryReviewTableViewCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 22..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import HCSStarRatingView
import SKPhotoBrowser
import SCLAlertView

protocol StoryReviewTableViewCellProtocol: class {
    func actionTapped(tag: Int)
}

class StoryReviewTableViewCell: UITableViewCell {

    var photoList = [String]()
    var selectedReview = Review()
    
    weak var delegate: StoryReviewTableViewCellProtocol?
    var row: Int?
    
    // 이미지 표시하는 콜렉션뷰
    @IBOutlet weak var collectionView: UICollectionView!
    // 콜렉션뷰를 담고 있는 스택뷰
    @IBOutlet weak var photoStackview: UIStackView!
    @IBOutlet weak var photoStackViewAspectConstraints: NSLayoutConstraint!
    
    
    // 프로필 이미지와 닉네임
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    
    // 리뷰 평점 표시
    @IBOutlet weak var ratingView: HCSStarRatingView!
    
    // 스토어 이름
    @IBOutlet weak var storeName: UILabel!
    // 리뷰 입력 시간
    @IBOutlet weak var timeLabel: UILabel!
    // 리뷰 본문
    @IBOutlet weak var reviewBody: UILabel!
    
    // 좋아요 개수 라벨
    @IBOutlet weak var likeLabel: UILabel!
    
    // 댓글 개수 라벨
    @IBOutlet weak var replyLabel: UILabel!
    // 페이지 컨트롤
    @IBOutlet weak var pageControl: UIPageControl!
    
    // 신고 버튼
    @IBOutlet weak var moreButton: UIButton!

    // 라이크 버튼
    @IBOutlet weak var likeButton: UIButton!
    
    // 댓글 버튼
    @IBOutlet weak var replyButton: UIButton!
    
    // 공유 버튼
    @IBOutlet weak var shareButton: UIButton!
    
    // 이동 버튼
    @IBOutlet weak var moveButton: UIButton!
    
    // 라이크버튼 누르면 액션 실행, 태그 6
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        print("Like Button Clicked: \(likeButton.tag)")
        // 버튼 너무 빨리 연속으로 못 누르게 막아놓기
        likeButton.isUserInteractionEnabled = false
        
        delegate?.actionTapped(tag: likeButton.tag)
        
        // 우선 이미지 바꿔주기
        if sender.image(for: .normal) == #imageLiteral(resourceName: "like_bw") {
            UIView.transition(with: sender, duration: 0.2, options: .transitionCrossDissolve, animations: {
                sender.setImage(#imageLiteral(resourceName: "like_red"), for: .normal)
            }, completion: nil)
            self.likeButton.isUserInteractionEnabled = true
        } else {
            UIView.transition(with: sender, duration: 0.2, options: .transitionCrossDissolve, animations: {
                sender.setImage(#imageLiteral(resourceName: "like_bw"), for: .normal)
            }, completion: nil)
            self.likeButton.isUserInteractionEnabled = true
        }
    }
    
    // 이 버튼 누르면 해당 장소로 이동, 태그 5
    @IBAction func moveToStore(_ sender: Any) {
        print("Move Button Clicked: \(moveButton.tag)")
        delegate?.actionTapped(tag: moveButton.tag)
    }
    
    // 댓글버튼 누르면 Reply 창으로 이동 tag = 3
    @IBAction func commentButtonClicked(_ sender: Any) {
        print("Comment Button Clicked: \(replyButton.tag)")
        delegate?.actionTapped(tag: replyButton.tag)
    }
    
    // 공유버튼 누르면 액션 실행, 태그 4
    @IBAction func shareButtonClicked(_ sender: Any) {
        print("Share Button Clicked: \(shareButton.tag)")
        delegate?.actionTapped(tag: shareButton.tag)
    }
    
    // 신고 버튼, 태그 2
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Initialization
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // 페이지컨트롤 한개의 사진이면 안 보이게
        pageControl.hidesForSinglePage = true
        pageControl.layer.cornerRadius = 10.0
        
        // 이미지뷰 원형 모양으로
        profileImage.layer.cornerRadius = profileImage.layer.frame.width/2
        
        // 사진 보여주기 기능 설정
        /*
        let tap = UITapGestureRecognizer(target: self, action: #selector(StoryTableViewCell.showPhotos(_:)))
        tap.numberOfTapsRequired = 2
        collectionView.isUserInteractionEnabled = true
        collectionView.addGestureRecognizer(tap)
        */
    }
    
    func showPhotos(_ sender: UITapGestureRecognizer) {
        print("Show Photos: \(String(describing: sender.view?.tag))")
        guard let row = sender.view?.tag else { return }
        delegate?.actionTapped(tag: row)
    }
    
}

extension StoryReviewTableViewCell : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    // MARK: Collectionview Method
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.pageControl.numberOfPages = photoList.count
        return photoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviewCell", for: indexPath) as! StoryReviewPhotoCollectionViewCell
        
        DispatchQueue.global().async { 
            let imageURL = self.photoList[indexPath.row]
            let url = URL(string: imageURL)
            DispatchQueue.main.async {
                cell.imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imageLoadingHolder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.layer.frame.width
        return CGSize(width: width, height: width*0.9)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.row
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileName.text = nil
        profileImage.image = #imageLiteral(resourceName: "user_profile")
        storeName.text = "장소 이름"
        timeLabel.text = ""
        reviewBody.text = ""
        collectionView.isHidden = false
        pageControl.numberOfPages = 1
        likeButton.setImage(#imageLiteral(resourceName: "like_bw"), for: .normal)
        likeLabel.text = ""
        replyLabel.text = ""
    }
}
