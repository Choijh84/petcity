//
//  ReviewDetailViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 5. 6..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import Kingfisher
import SCLAlertView
import SKPhotoBrowser
import OneSignal
import HCSStarRatingView

/// 전체 페이지로 리뷰의 디테일을 보여주는 뷰, 라이크, 코멘트, 공유, 기타 기능을 모두 포함
class ReviewDetailViewController: UIViewController {

    var selectedReview: Review!
    
    var photoList = [String]()
    var photoArrray = [UIImage]()
    
    @IBOutlet weak var profileImage: LoadingImageView!
    @IBOutlet weak var profileNickname: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var ratingView: HCSStarRatingView!
    
    @IBOutlet weak var bodyTextLabel: UILabel!
    
    @IBOutlet weak var imageCollection: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: NSLayoutConstraint!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var likeNumberLabel: UILabel!
    @IBOutlet weak var commentNumberLabel: UILabel!
    
    var likeNumber: Int = 0
    var commentNumber: Int = 0
    
    /// Lazy getter for the dateformatter that formats the date property of each review to the desired format
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter
    }()
    
    // 라이크 버튼 눌렀을 때
    @IBAction func tapLikeButton(_ sender: UIButton) {
        // like 여부 체크해서 추가하던가 지운다
        if sender.image(for: .normal) == #imageLiteral(resourceName: "like_bw") {
            UIView.transition(with: sender, duration: 0.2, options: .transitionCrossDissolve, animations: {
                sender.setImage(#imageLiteral(resourceName: "like_red"), for: .normal)
            }, completion: nil)
            
            // 여기서 DB에 라이크 추가
            changeLike(true)
            
        } else {
            // 좋아요를 취소할 때
            UIView.transition(with: sender, duration: 0.2, options: .transitionCrossDissolve, animations: {
                sender.setImage(#imageLiteral(resourceName: "like_bw"), for: .normal)
            }, completion: nil)
            
            // 여기서 DB에 라이크 삭제
            changeLike(false)
            
        }
    }
    
    /// 댓글 버튼 눌렀을 때
    @IBAction func tapCommentButton(_ sender: Any) {
        
        // 코멘트뷰로 이동
        let storyBoard = UIStoryboard(name: "StoryAndReview", bundle: nil)
        let destinationVC = storyBoard.instantiateViewController(withIdentifier: "ReviewCommentViewController") as! ReviewCommentViewController
        
        destinationVC.selectedReview = selectedReview
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    /// 공유 버튼 눌렀을 때
    @IBAction func tapShareButton(_ sender: Any) {
        shareButtonPressed()
    }
    
    @IBAction func tapMoreButton(_ sender: Any) {
        // 수정, 삭제, 신고를 선택하게 합시다
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        
        // 이 리뷰가 내 리뷰면 수정하고 삭제가 되게
        if selectedReview.creator?.objectId == UserManager.currentUser()?.objectId {
            alertView.addButton("리뷰 수정") {
                
                let storyBoard = UIStoryboard(name: "Reviews", bundle: nil)
                let destinationVC = storyBoard.instantiateViewController(withIdentifier: "AddReviewViewController") as! AddReviewViewController
                
                destinationVC.isReviewEditing = true
                destinationVC.selectedStore = self.selectedReview.store
                destinationVC.isEditingReview = self.selectedReview
                
                self.navigationController?.pushViewController(destinationVC, animated: true)
                
            }
            alertView.addButton("리뷰 삭제") {
                // 삭제하기 전에 한 번 더 물어보기
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.addButton("삭제") {
                    ReviewManager().deleteReview(self.selectedReview.objectId!, completionBlock: { (success, error) in
                        if success {
                            // 'changed' Notification 주기
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "reviewChanged"), object: nil)
                            SCLAlertView().showSuccess("삭제 완료", subTitle: "")
                            // 그 전 뷰로 돌아가기
                            _ = self.navigationController?.popViewController(animated: true)
                            
                        } else {
                            SCLAlertView().showError("에러", subTitle: "\(String(describing: error))")
                        }
                    })
                }
                alertView.addButton("취소") {
                    print("취소되었습니다")
                }
                alertView.showWarning("삭제하시겠습니까?", subTitle: "삭제된 스토리와 사진은 복원되지 않습니다")
            }
        }
        
        alertView.addButton("신고") {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("신고") {
                // 게시물 숨기기도 필요한가?
                // 서버나 관리자에게 이메일 보내기
                self.sendEmail()
            }
            alertView.addButton("취소") {
                print("취소되었습니다")
            }
            alertView.showWarning("신고하기", subTitle: "이 게시물을 위법/위해 게시물로 신고하시겠습니까?")
        }
        alertView.addButton("취소") {
            print("취소되었습니다")
        }
        alertView.showNotice("선택", subTitle: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 프로필 이미지 동그랗게 세팅
        profileImage.layer.cornerRadius = profileImage.frame.width/2
        
        // 페이지 컨트롤
        pageControl.hidesForSinglePage = true
        
        // 닉네임하고 프로필 설정
        if let user = selectedReview.creator {
            let nickname = user.getProperty("nickname") as! String
            profileNickname.text = nickname
            
            if let profileURL = user.getProperty("profileURL") {
                if profileURL is NSNull {
                    profileImage.image = #imageLiteral(resourceName: "user_profile")
                } else {
                    let url = URL(string: profileURL as! String)
                    profileImage.kf.indicatorType = .activity
                    profileImage.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imageLoadingHolder"), options: nil, progressBlock: nil, completionHandler: nil)
                }
            }
            
            // 장소 이름 추가해서 타이틀 만들기
            if let store = selectedReview.store {
                let storeName = store.name!
                
                let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
                let myString = "\(nickname)의 \(storeName) 리뷰"
                let myAttribute = [NSForegroundColorAttributeName: UIColor.navigationTitleColor(), NSFontAttributeName: UIFont(name: "YiSunShinDotumM", size: 18)!]
                
                titleLabel.attributedText = NSAttributedString(string: myString, attributes: myAttribute)
                titleLabel.adjustsFontSizeToFitWidth = true
                titleLabel.textColor = UIColor.navigationTitleColor()
                titleLabel.textAlignment = .center
                
                self.navigationItem.titleView = titleLabel
            }
            
        } else {
            //  삭제된 유저의 경우
            profileNickname.text = "탈퇴 유저"
            profileImage.image = #imageLiteral(resourceName: "user_profile")
            
            // 장소 이름 추가해서 타이틀 만들기
            if let store = selectedReview.store {
                let storeName = store.name!
                
                let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
                let myString = "\(storeName) 리뷰"
                let myAttribute = [NSForegroundColorAttributeName: UIColor.navigationTitleColor(), NSFontAttributeName: UIFont(name: "YiSunShinDotumM", size: 18)!]
                
                titleLabel.attributedText = NSAttributedString(string: myString, attributes: myAttribute)
                titleLabel.adjustsFontSizeToFitWidth = true
                titleLabel.textColor = UIColor.navigationTitleColor()
                titleLabel.textAlignment = .center
                
                self.navigationItem.titleView = titleLabel
            }
        }
        
        // 본문 설정
        bodyTextLabel.text = selectedReview.text
        bodyTextLabel.setLineHeight(lineHeight: 2)
        
        // 시간 설정
        timeLabel.text = dateFormatter.string(from: selectedReview.created! as Date)
        
        // 사진 배열 설정
        photoList = (selectedReview.fileURL!.components(separatedBy: ","))
        imageCollection.reloadData()
        
        // 라이크 설정
        likeCheck()
        
        // 평점 설정
        ratingView.allowsHalfStars = true
        ratingView.value = selectedReview.rating as! CGFloat
        
        // 사진 풀화면으로 보여주기
        let tap = UITapGestureRecognizer(target: self, action: #selector(ReviewDetailViewController.showPhoto))
        tap.numberOfTapsRequired = 2
        imageCollection.isUserInteractionEnabled = true
        imageCollection.addGestureRecognizer(tap)
        
        // 코멘트 개수
        DispatchQueue.global(qos: .userInteractive).async {
            // 댓글수 찾기
            let tempStore = Backendless.sharedInstance().data.of(ReviewComment.ofClass())
            
            let reviewId = self.selectedReview.objectId!
            let dataQuery = BackendlessDataQuery()
            // 이 리뷰에 달린 댓글 모두 몇 개인지 찾기
            dataQuery.whereClause = "to = '\(reviewId)'"
            
            DispatchQueue.main.async {
                tempStore?.find(dataQuery, response: { (collection) in
                    let comments = collection?.data as! [ReviewComment]
                    self.commentNumber = comments.count
                    
                    self.commentNumberLabel.text = String(self.commentNumber) + "개의 수다들"
                    
                }, error: { (Fault) in
                    print("서버에서 댓글 얻어오기 실패: \(String(describing: Fault?.description))")
                })
            }
        }
        
        // 리뷰 변경에 대한 Notification
        NotificationCenter.default.addObserver(self, selector: #selector(ReviewDetailViewController.refresh), name: NSNotification.Name(rawValue: "reviewChanged"), object: nil)
        
        // 코멘트 등록 및 삭제에 대한 Notification
        NotificationCenter.default.addObserver(self, selector: #selector(ReviewDetailViewController.commentChanged), name: NSNotification.Name(rawValue: "reviewCommentChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ReviewDetailViewController.commentChanged), name: NSNotification.Name(rawValue: "reviewCommentDeleted"), object: nil)
    }
    
    func likeCheck() {
        let likeStore = Backendless.sharedInstance().data.of(ReviewLikes.ofClass())
        let dataQuery = BackendlessDataQuery()
        
        let objectID = selectedReview.objectId!
        let userID = UserManager.currentUser()!.objectId!
        // print("objectID & userID: \(objectID) & \(userID)")
        
        // 여기서 by가 현재 유저의 objectId이어야 하고, to는 이 포스트의 objectId이어야 한다
        dataQuery.whereClause = "by = '\(userID)' AND to = '\(objectID)'"
        
        DispatchQueue.main.async {
            likeStore?.find(dataQuery, response: { (collection) in
                let likes = collection?.data as! [ReviewLikes]
                
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
        self.likeNumber = matchingLikes?.totalObjects as! Int
        
        DispatchQueue.main.async {
            self.likeNumberLabel.text = String(describing: self.likeNumber) + "개의 좋아요"
        }
    }
    
    func changeLike(_ addLike: Bool) {
        let dataStore = Backendless.sharedInstance().data.of(ReviewLikes.ofClass())
        
        let reviewId = selectedReview.objectId!
        let objectID = Backendless.sharedInstance().userService.currentUser.objectId
        
        // 좋아요 눌렀을 때
        if addLike {
            let like = StoryLikes()
            like.by = objectID! as String
            like.to = reviewId
            // 좋아요 저장
            dataStore?.save(like, response: nil, error: { (Fault) in
                SCLAlertView().showError("에러", subTitle: "라이크를 추가하는데 에러 발생함")
                print("라이크를 추가하는데 에러: \(String(describing: Fault?.description))")
            })
            
            // 스토리를 쓴 사람에게 Notification 날리기
            if let oneSignalId = selectedReview.creator?.getProperty("OneSignalID") {
                if let userName = UserManager.currentUser()!.getProperty("nickname") {
                    let data = ["contents" : ["en" : "\(userName) likes your Review!", "ko" : "\(userName)가 당신의 리뷰를 좋아합니다"], "include_player_ids" : ["\(oneSignalId)"], "ios_badgeType" : "Increase", "ios_badgeCount" : "1"] as [String : Any]
                    OneSignal.postNotification(data)
                    
                    // 데이터베이스에 저장하기
                    // 푸쉬 객체 생성
                    let newPush = PushNotis()
                    newPush.from = objectID! as String
                    newPush.to = (selectedReview.creator!).objectId! as! String
                    newPush.type = "review"
                    newPush.typeId = reviewId
                    newPush.bodyText = "\(userName)가 당신의 리뷰를 좋아합니다"
                    
                    let pushStore = Backendless.sharedInstance().data.of(PushNotis.ofClass())
                    pushStore?.save(newPush, response: { (response) in
                        print("백엔드리스에 푸쉬 저장 완료")
                    }, error: { (Fault) in
                        print("푸쉬를 백엔드리스에 저장하는데 에러: \(String(describing: Fault?.description))")
                    })
                }
            }
            self.likeNumber = likeNumber + 1
            self.likeNumberLabel.text = String(describing: self.likeNumber) + "개의 좋아요"
            
        } else {
            // 좋아요 취소
            let dataQuery = BackendlessDataQuery()
            dataQuery.whereClause = "by = '\(objectID!)' AND to = '\(reviewId)'"
            
            dataStore?.find(dataQuery, response: { (collection) in
                let like = (collection?.data as! [StoryLikes]).first
                
                // 좋아요 삭제
                _ = dataStore?.remove(like)
                
                self.likeNumber = self.likeNumber - 1
                self.likeNumberLabel.text = String(describing: self.likeNumber) + "개의 좋아요"
                
            }, error: { (Fault) in
                SCLAlertView().showError("에러", subTitle: "라이크를 삭제하는데 에러 발생함")
                print("라이크를 삭제하는데 에러: \(String(describing: Fault?.description))")
            })
        }
    }
    
    func refresh() {
        DispatchQueue.global(qos: .userInteractive).async {
            // 평점하고 본문 다시 읽어오기
            let tempStore = Backendless.sharedInstance().data.of(Review.ofClass())
            
            let reviewId = self.selectedReview.objectId!
            
            DispatchQueue.main.async {
                tempStore?.findID(reviewId, response: { (response) in
                    let responseReview = response as! Review
                    
                    // 본문
                    self.bodyTextLabel.text = responseReview.text
                    
                    // 평점
                    self.ratingView.value = responseReview.rating as! CGFloat
                    
                }, error: { (Fault) in
                    print("리뷰 로딩 실패: \(String(describing: Fault?.description))")
                })
            }
        }
    }
    
    func commentChanged() {
        DispatchQueue.global(qos: .userInteractive).async {
            // 댓글수 찾기
            let tempStore = Backendless.sharedInstance().data.of(ReviewComment.ofClass())
            
            let reviewId = self.selectedReview.objectId!
            let dataQuery = BackendlessDataQuery()
            
            dataQuery.whereClause = "to = '\(reviewId)'"
            
            // 이 스토리에 달린 댓글 모두 몇 개인지 찾기
            DispatchQueue.main.async {
                tempStore?.find(dataQuery, response: { (collection) in
                    let comments = collection?.data as! [ReviewComment]
                    self.commentNumber = comments.count
                    
                    self.commentNumberLabel.text = String(self.commentNumber) + "개의 수다들"
                    
                }, error: { (Fault) in
                    print("서버에서 댓글 얻어오기 실패: \(String(describing: Fault?.description))")
                })
            }
        }
    }
    
    // 사진 전체화면으로 보기
    func showPhoto() {
        
        // imageArray 구성하기
        let imageURL = selectedReview.fileURL?.components(separatedBy: ",")
        
        var images = [SKPhoto]()
        
        // 킹피셔 사용해서 캐시에서 url 이용해서 이미지 불러오기
        for url in imageURL! {
            ImageCache.default.retrieveImage(forKey: url, options: [.transition(.fade(0.2))], completionHandler: { (image, cacheType) in
                if let image = image {
                    let photo = SKPhoto.photoWithImage(image)
                    images.append(photo)
                } else {
                    print("Problem on cache image")
                }
            })
            
        }
        // 브라우저 보여주기
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(0)
        self.present(browser, animated: true, completion: nil)
    }
    
    /// 공유를 위한 함수
    func shareButtonPressed() {
        
        let shareText = "이 리뷰를 펫시티에서 같이 봐주세요!"
        if let bodyText = selectedReview.text {
            let activityViewController = UIActivityViewController(activityItems: [ shareText, bodyText ], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        } else {
            let activityViewController = UIActivityViewController(activityItems: [ shareText ], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }
        
    }

    // 신고 이메일 현재 수신인: ourpro.choi@gmail.com
    func sendEmail() {
        let userEmail = Backendless.sharedInstance().userService.currentUser.email
        
        let subject = "리뷰 게시물 신고 이메일"
        let body = "신고 사용자: \(userEmail!).\n 신고한 게시물은 이 게시물입니다. ID: \(String(describing: selectedReview.objectId!))"
        let recipient = "ourpro.choi@gmail.com"
        Backendless.sharedInstance().messagingService.sendHTMLEmail(subject, body: body, to: [recipient], response: { (response) in
            SCLAlertView().showSuccess("신고 완료", subTitle: "제출되었습니다")
        }) { (Fault) in
            print("Server reported an error: \(String(describing: Fault?.description))")
        }
    }
    
}

extension ReviewDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = photoList.count
        return photoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ReviewDetailCollectionViewCell
        
        cell.imageView.kf.indicatorType = .activity
        let url = URL(string: photoList[indexPath.row])
        
        cell.imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imageLoadingHolder"), options: nil, progressBlock: nil, completionHandler: nil)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.currentPage = indexPath.row
    }
    
    // uicollection - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: width)
    }
    
}

class ReviewDetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        imageView.image = nil
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
}
