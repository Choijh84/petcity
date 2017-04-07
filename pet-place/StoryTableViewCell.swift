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
    
    /// 테이블뷰에 해당되는 스토리
    var selectedStory = Story()
    
    weak var delegate: StoryTableViewCellProtocol?
    var row: Int?
    
    @IBOutlet weak var profileImageView: LoadingImageView!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var imageCollection: UICollectionView!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var likeNumberLabel: UILabel!
    
    @IBOutlet weak var bodyTextLabel: UILabel!
    
    @IBOutlet weak var commentNumberLabel: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    // 라이크버튼 눌렀을 때
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        print("Like Button Clicked: \(likeButton.tag)")
        
        delegate?.actionTapped(tag: likeButton.tag)
        // 좋아하는 스토리인지 아닌지를 구분
        // 버튼의 이미지 변경 - 클릭하면 이미지 바뀌게
        // 좋아요를 눌렀을 때
        if sender.image(for: .normal) == #imageLiteral(resourceName: "like_bw") {
            UIView.transition(with: sender, duration: 0.5, options: .transitionCrossDissolve, animations: {
                sender.setImage(#imageLiteral(resourceName: "like_red"), for: .normal)
            }, completion: nil)
        } else {
        // 좋아요를 취소할 때 
            UIView.transition(with: sender, duration: 0.5, options: .transitionCrossDissolve, animations: {
                sender.setImage(#imageLiteral(resourceName: "like_bw"), for: .normal)
            }, completion: nil)
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
    
    /// 초기화
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization
        imageCollection.delegate = self
        imageCollection.dataSource = self
        
        // 페이지컨트롤 한개의 사진이면 안 보이게
        pageControl.hidesForSinglePage = true
        pageControl.layer.cornerRadius = 10.0
        
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
        
        let tap6 = UITapGestureRecognizer(target: self, action: #selector(StoryTableViewCell.showPhotos(_:)))
        tap6.numberOfTapsRequired = 2
        imageCollection.isUserInteractionEnabled = true
        imageCollection.addGestureRecognizer(tap6)

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
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

extension StoryTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    // MARK: Collectionview Method
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.pageControl.numberOfPages = photoList.count
        return photoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "storyCell", for: indexPath) as! StoryPhotoCollectionViewCell
        
        let imageURL = photoList[indexPath.row]
        let url = URL(string: imageURL)
        
        // 킹피셔 활용
        DispatchQueue.main.async { 
            cell.imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imageplaceholder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.size.width
        return CGSize(width: width, height: width*0.8)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.row
    }
}
