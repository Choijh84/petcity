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
    
    // 댓글 개수 라벨
    @IBOutlet weak var replyLabel: UILabel!
    // 페이지 컨트롤
    @IBOutlet weak var pageControl: UIPageControl!
    
    // 신고 버튼
    @IBOutlet weak var moreButton: UIButton!

    // 댓글 버튼
    @IBOutlet weak var replyButton: UIButton!
    
    // 공유 버튼
    @IBOutlet weak var shareButton: UIButton!
    
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
                cell.imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imageplaceholder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
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
        storeName.text = "가게 이름"
        timeLabel.text = "계산 필요"
        reviewBody.text = "로딩 필요"
        collectionView.isHidden = false
        pageControl.numberOfPages = 1
    }
}
