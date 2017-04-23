//
//  StoryDetailViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 4. 23..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import Kingfisher
import SCLAlertView

class StoryDetailViewController: UIViewController {

    var selectedStory: Story!
    
    var photoList = [String]()
    
    @IBOutlet weak var profileImage: LoadingImageView!
    @IBOutlet weak var profileNickname: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var bodyTextLabel: UILabel!
    
    @IBOutlet weak var imageCollection: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: NSLayoutConstraint!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var likeNumberLabel: UILabel!
    @IBOutlet weak var commentNumberLabel: UILabel!
    
    /// Lazy getter for the dateformatter that formats the date property of each review to the desired format
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 프로필 이미지 동그랗게
        profileImage.layer.cornerRadius = profileImage.frame.width/2
        
        // 페이지 컨트롤
        pageControl.hidesForSinglePage = true

        // 닉네임하고 프로필 설정
        if let user = selectedStory.writer {
            let nickname = user.getProperty("nickname") as! String
            profileNickname.text = nickname
            
            if let profileURL = user.getProperty("profileURL") {
                if profileURL is NSNull {
                    profileImage.image = #imageLiteral(resourceName: "user_profile")
                } else {
                    let url = URL(string: profileURL as! String)
                    profileImage.kf.indicatorType = .activity
                    profileImage.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
                }
            }
        } else {
            //  삭제된 유저의 경우
            profileNickname.text = "탈퇴 유저"
            profileImage.image = #imageLiteral(resourceName: "user_profile")
        }
        
        // 본문 설정
        bodyTextLabel.text = selectedStory.bodyText
        bodyTextLabel.setLineHeight(lineHeight: 2)
        
        
        // 시간 설정
        timeLabel.text = dateFormatter.string(from: selectedStory.created! as Date)
        
        // 사진 배열 설정
        photoList = (selectedStory.imageArray?.components(separatedBy: ","))!
        imageCollection.reloadData()
        
        // 라이크 설정
        likeCheck()
    }
    
    func likeCheck() {
        let likeStore = Backendless.sharedInstance().data.of(StoryLikes.ofClass())
        let dataQuery = BackendlessDataQuery()
        
        let objectID = selectedStory.objectId!
        let userID = UserManager.currentUser()!.objectId!
        // print("objectID & userID: \(objectID) & \(userID)")
        
        // 여기서 by가 현재 유저의 objectId이어야 하고, to는 이 포스트의 objectId이어야 한다
        dataQuery.whereClause = "by = '\(userID)' AND to = '\(objectID)'"
        
        DispatchQueue.main.async {
            likeStore?.find(dataQuery, response: { (collection) in
                let likes = collection?.data as! [StoryLikes]
                
                // 하트를 안 눌렀을 때
                if likes.count == 0 {
                    DispatchQueue.main.async {
                        self.likeButton.setImage(#imageLiteral(resourceName: "like_bw"), for: .normal)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.likeButton.setImage(#imageLiteral(resourceName: "like_red"), for: .normal)
                    }
                }
                
            }, error: { (Fault) in
                print("라이크 불러오기에서 에러: \(String(describing: Fault?.description))")
            })
        }
        
        
        // 좋아요 개수 세기
        let countQuery = BackendlessDataQuery()
        // to가 story의 objectID와 일치하면 땡
        countQuery.whereClause = "to = '\(objectID)'"
        
        let queryOptions = QueryOptions()
        queryOptions.pageSize = 1
        countQuery.queryOptions = queryOptions
        
        let matchingLikes = likeStore?.find(countQuery)
        let likeNumbers = matchingLikes?.totalObjects
        
        DispatchQueue.main.async {
            self.likeNumberLabel.text = String(describing: likeNumbers!) + "개의 좋아요"
        }
    }

}

extension StoryDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = photoList.count
        return photoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! StoryDetailCollectionViewCell
        
        cell.imageView.kf.indicatorType = .activity
        let url = URL(string: photoList[indexPath.row])
        
        cell.imageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.currentPage = indexPath.row
    }
    
    // uicollection - UICollectionViewDelegateFlowLayout
    // 너비 설정, 너비:높이 = 3:2
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: width*2/3)
    }
    
}

class StoryDetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        imageView.image = nil
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
}
