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
import SKPhotoBrowser

class StoryDetailViewController: UIViewController {

    var selectedStory: Story!
    
    var photoList = [String]()
    var photoArrray = [UIImage]()
    
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
    
    /// 라이크 버튼 눌렀을 때
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
    
    func changeLike(_ addLike: Bool) {
        let dataStore = Backendless.sharedInstance().data.of(StoryLikes.ofClass())
        
        let storyId = selectedStory.objectId!
        let objectID = Backendless.sharedInstance().userService.currentUser.objectId
        
        // 좋아요 눌렀을 때
        if addLike {
            let like = StoryLikes()
            like.by = objectID! as String
            like.to = storyId
            // 좋아요 저장
            dataStore?.save(like, response: nil, error: { (Fault) in
                SCLAlertView().showError("에러", subTitle: "라이크를 추가하는데 에러 발생함")
                print("라이크를 추가하는데 에러: \(String(describing: Fault?.description))")
            })
           
        } else {
            // 좋아요 취소
            let dataQuery = BackendlessDataQuery()
            dataQuery.whereClause = "by = '\(objectID!)' AND to = '\(storyId)'"
            
            dataStore?.find(dataQuery, response: { (collection) in
                let like = (collection?.data as! [StoryLikes]).first
                // 좋아요 삭제
                _ = dataStore?.remove(like)
                
            }, error: { (Fault) in
                SCLAlertView().showError("에러", subTitle: "라이크를 삭제하는데 에러 발생함")
                print("라이크를 삭제하는데 에러: \(String(describing: Fault?.description))")
            })
        }
    }
    
    /// 댓글 버튼 눌렀을 때
    @IBAction func tapCommentButton(_ sender: Any) {
        // 코멘트뷰로 segue 이동
        performSegue(withIdentifier: "showComments", sender: nil)
    }
    
    /// 공유 버튼 눌렀을 때
    @IBAction func tapShareButton(_ sender: Any) {
        shareButtonPressed()
    }
    
    ///
    @IBAction func tapMoreButton(_ sender: Any) {
        // 수정, 삭제, 신고를 선택하게 합시다 
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        
        // 이 스토리가 내 스토리면 수정과 삭제 추가
        if selectedStory.writer.objectId == UserManager.currentUser()?.objectId {
            alertView.addButton("스토리 수정") {
                // 스토리 입력하는 곳으로
                let storyBoard = UIStoryboard(name: "StoryAndReview", bundle: nil)
                let destinationVC = storyBoard.instantiateViewController(withIdentifier: "EditStoryViewController") as! EditStoryViewController
                destinationVC.selectedStory = self.selectedStory
                
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
            alertView.addButton("스토리 삭제") {
                // 삭제하기 전에 한 번 더 물어보기
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.addButton("삭제") {
                    StoryDownloadManager().deleteStory(self.selectedStory.objectId!, completionBlock: { (success, error) in
                        if success {
                            // 'changed' Notification주기
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "changed"), object: nil)
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
        
        // 사진 풀화면으로 보여주기
        let tap = UITapGestureRecognizer(target: self, action: #selector(StoryDetailViewController.showPhoto))
        tap.numberOfTapsRequired = 2
        imageCollection.isUserInteractionEnabled = true
        imageCollection.addGestureRecognizer(tap)
        
        // 코멘트 개수
        DispatchQueue.global(qos: .userInteractive).async {
            // 댓글수 찾기
            let tempStore = Backendless.sharedInstance().data.of(StoryComment.ofClass())
            
            let storyId = self.selectedStory.objectId!
            let dataQuery = BackendlessDataQuery()
            // 이 스토리에 달린 댓글 모두 몇 개인지 찾기
            dataQuery.whereClause = "to = '\(storyId)'"
            
            DispatchQueue.main.async {
                tempStore?.find(dataQuery, response: { (collection) in
                    let comments = collection?.data as! [StoryComment]
                    
                    self.commentNumberLabel.text = String(comments.count) + "개의 수다들"
                    
                }, error: { (Fault) in
                    print("서버에서 댓글 얻어오기 실패: \(String(describing: Fault?.description))")
                })
            }
        }
        
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
    
    // 사진 전체화면으로 보기
    func showPhoto() {
        
        // imageArray 구성하기
        let imageURL = selectedStory.imageArray?.components(separatedBy: ",")
        
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
        
        let shareText = "이 스토리를 펫시티에서 같이 봐주세요!"
        if let bodyText = selectedStory.bodyText {
            let activityViewController = UIActivityViewController(activityItems: [ shareText, bodyText ], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        } else {
            let activityViewController = UIActivityViewController(activityItems: [ shareText ], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any? ) {
        if segue.identifier == "showComments" {
            let destinationVC = segue.destination as! CommentViewController
            destinationVC.selectedStory = selectedStory
        }
    }
    
    // 신고 이메일 현재 수신인: ourpro.choi@gmail.com
    func sendEmail() {
        let userEmail = Backendless.sharedInstance().userService.currentUser.email
        
        let subject = "스토리 게시물 신고 이메일"
        let body = "신고 사용자: \(userEmail!).\n 신고한 게시물은 이 게시물입니다. ID: \(String(describing: selectedStory.objectId!))"
        let recipient = "ourpro.choi@gmail.com"
        Backendless.sharedInstance().messagingService.sendHTMLEmail(subject, body: body, to: [recipient], response: { (response) in
            SCLAlertView().showSuccess("신고 완료", subTitle: "제출되었습니다")
        }) { (Fault) in
            print("Server reported an error: \(String(describing: Fault?.description))")
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: width)
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
