//
//  ReviewViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 15..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SCLAlertView
import SKPhotoBrowser
import Kingfisher

/// 스토리리뷰에서 리뷰 파트를 보여주는 뷰컨트롤러
class ReviewViewController: UIViewController, IndicatorInfoProvider, UITableViewDataSource, UITableViewDelegate, StoryReviewTableViewCellProtocol  {
    
    // 지역 선택하는 뷰
    @IBOutlet weak var locationView: UIView!
    // 지역 선택하는 버튼과 라벨
    @IBOutlet weak var locationSelectButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    
    // 지역 보여주는 뷰
    @IBOutlet weak var locationShowView: UIView!
    @IBOutlet weak var locationCollectionView: UICollectionView!
    var isShowing: Bool = false
    
    // 리뷰가 없을 때
    @IBOutlet weak var noReviewView: UIView!
    
    
    // 지역 선택할 수 있게 하는 배열
    let locations = ["모두 보기", "서울 강북", "서울 강남", "경기도", "인천", "대구", "부산", "제주", "대전", "광주", "울산", "세종", "강원도", "경상도", "전라도", "충청도"]
    
    // 선택된 지역 
    var selectedLocation: String?
    
    // 내리고 있던 마지막 스크롤을 기억하게 하는 변수
    var lastContentOffset: CGFloat = 0
    
    // 리뷰 보여주는 테이블뷰
    @IBOutlet weak var tableView: LoadingTableView!
    
    // 리뷰 저장하는 배열
    var ReviewArray: [Review] = []
    
    /// 리뷰를 다운로드하고 있으면 true
    var isLoadingItems: Bool = false
    
    var itemInfo: IndicatorInfo = "지역 리뷰"
    
    /// 레이지 게터 데이트포매터
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter
    }()
    
    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    // 지역 선택하는 버튼
    @IBAction func locationSelection(_ sender: Any) {
        // 우선 이 것부터 숨기고
        noReviewView.isHidden = true
        
        // 보이기
        if isShowing == false {
            UIView.animate(withDuration: 0.5) {
                self.locationShowView.alpha = 1.0
                self.tableView.alpha = 0.1
            }
            isShowing = true
            self.tableView.isUserInteractionEnabled = false
            selectedLocation = nil
            
            
        } else {
            // 숨기기
            UIView.animate(withDuration: 0.5) {
                self.locationShowView.alpha = 0.0
                self.tableView.alpha = 1.0
            }
            isShowing = false
            self.tableView.isUserInteractionEnabled = true
            print("선택된 장소: \(String(describing: selectedLocation))")
            
        }
    }
    
    override func viewDidLoad() {
        
        // height setting
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableViewAutomaticDimension
        
        customizeViews()
        
        // 스크롤뷰
        tableView.decelerationRate = UIScrollViewDecelerationRateFast
        
        // 업로드가 된걸 노티 받으면 바로 refresh
        NotificationCenter.default.addObserver(self, selector: #selector(ReviewViewController.refresh), name: NSNotification.Name(rawValue: "reviewUploaded"), object: nil)
        // 리뷰 코멘트가 올라가거나 변경된걸 받으면 바로 refresh
        NotificationCenter.default.addObserver(self, selector: #selector(ReviewViewController.refresh), name: NSNotification.Name(rawValue: "reviewCommentChanged"), object: nil)
        
        // 리뷰가 없을 때 보여지는 뷰 보통 hide
        noReviewView.isHidden = true
        
        DispatchQueue.main.async {
            self.downloadReviews(nil)
        }
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // 기존에 봤던 자리로 원위치
        tableView.setContentOffset(CGPoint(x: 0, y: lastContentOffset), animated: false)
        super.viewWillAppear(animated)
        
    }
    
    // 노티를 통해 refresh를 받으면 table reload
    func refresh() {
        downloadReviews(nil)
        tableView.reloadData()
    }
    
    /**
     초기에 리뷰를 다운로드 하는 함수, 아직 로케이션 처리는 안됨
     - 처음 다운로드 하므로 데이터 배열을 초기화하고 시작, 추가 다운로드는 downloadMoreReviews에서 처리
    */
    func downloadReviews(_ location: String?) {
        isLoadingItems = true
        tableView.showLoadingIndicator()

        // 배열 초기화
        ReviewArray.removeAll()
        
        // 향후에 파라미터로 로케이션이 들어가면 쿼리가 되어야 함
        ReviewManager().downloadReviewPage(skippingNumberOfObects: 0, location: location, limit: 10) { (reviews, error) in
            self.isLoadingItems = false
            if reviews?.count == 0 {
                self.noReviewView.isHidden = false
            }
            if let error = error {
                self.showAlertViewWithRedownloadOption(error)
            } else {
                if let reviews = reviews {
                    self.ReviewArray.append(contentsOf: reviews)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.tableView.hideLoadingIndicator()
                    }
                }
            }
        }
    }
    
    func downloadMoreReviews(_ location: String?) {
        isLoadingItems = true
        self.tableView.showLoadingIndicator()
        
        // 이미 다운로드 받은 리뷰의 숫자
        let temp = ReviewArray.count as NSNumber
        
        ReviewManager().downloadReviewPage(skippingNumberOfObects: temp, location: location, limit: 10) { (reviews, error) in
            if let error = error {
                self.showAlertViewWithRedownloadOption(error)
            } else {
                if let reviews = reviews {
                    self.ReviewArray.append(contentsOf: reviews)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        self.tableView.hideLoadingIndicator()
    }
    
    /**
    사용자가 스크롤을 70% 이상 내리면 추가로 리뷰를 다운로드 - loadMoreReviews
    */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let endScrolling = scrollView.contentOffset.y + scrollView.frame.height
        if endScrolling >= (scrollView.contentSize.height*0.7) && !isLoadingItems && ReviewArray.count >= 10 {
            self.downloadMoreReviews(selectedLocation)
        }
        
        // 지역 선택하는 뷰를 스크롤 방향에 따라 보였다 숨겼다 하기 - 뷰 높이 조절이 안되서 아직 미구현
        // 스택뷰에 넣어서 숨김
        // Review 개수를 체크해서 0개이면 적용 안함
        if ReviewArray.count != 0 {
            if (self.lastContentOffset > scrollView.contentOffset.y) && self.lastContentOffset < (scrollView.contentSize.height - scrollView.frame.height) {
                UIView.animate(withDuration: 0.5, animations: {
                    self.locationView.isHidden = false
                })
            } else if (self.lastContentOffset < scrollView.contentOffset.y && scrollView.contentOffset.y > 0) {
                UIView.animate(withDuration: 0.5, animations: {
                    self.locationView.isHidden = true
                })
            }
        }
        
        // 최근 스크롤 뷰 기억
        self.lastContentOffset = scrollView.contentOffset.y
        
    }
    
    /**
     다운로드에 문제가 있다는 것을 알려주는 함수
     */
    func showAlertViewWithRedownloadOption(_ error: String) {
        let alert = SCLAlertView()
        alert.addButton("확인") {
            print("확인 완료")
        }
        alert.addButton("다시 시도") {
            self.downloadReviews(self.selectedLocation)
        }
        alert.showError("에러 발생", subTitle: "다운로드에 문제가 있습니다")
    }
    
    /**
     Customize the tableview's look and feel
     */
    func customizeViews() {
        // 아래 테이블뷰의 줄 지워주기
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorColor = .separatorLineColor()
        
        locationShowView.alpha = 0.0
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    
    // MARK: - Tableview DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReviewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! StoryReviewTableViewCell
        
        let review = ReviewArray[indexPath.row]
        // 프로토콜 delegate 설정
        cell.delegate = self
            
        // 태그 설정
        // 프로필 이름 및 이미지 - 태그 0
        // 댓글 라벨 - 태그 1, 신고 버튼 - 태그 2
        // 댓글 버튼 - 태그 3, 공유 버튼 - 태그 4, 이동 버튼 - 태그 5
        // 사진 콜렉션 - 태그 6, 좋아요 버튼 - 태그 7, 좋아요 라벨 - 태그 8
        cell.profileImage.tag = (indexPath.row*10)+0
        cell.profileName.tag = (indexPath.row*10)+0
        cell.replyLabel.tag = (indexPath.row*10)+01
        cell.moreButton.tag = (indexPath.row*10)+02
        cell.replyButton.tag = (indexPath.row*10)+03
        cell.shareButton.tag = (indexPath.row*10)+04
        cell.moveButton.tag = (indexPath.row*10)+05
        cell.collectionView.tag = (indexPath.row*10)+06
        cell.likeButton.tag = (indexPath.row*10)+07
        cell.likeLabel.tag = (indexPath.row*10)+08
        
        // 프로필 이미지랑 닉네임 설정
        if let user = review.creator {
            let nickname = user.getProperty("nickname") as! String
            cell.profileName.text = nickname
            
            if let profileURL = user.getProperty("profileURL") {
                if profileURL is NSNull {
                    cell.profileImage.image = #imageLiteral(resourceName: "user_profile")
                } else {
                    let url = URL(string: profileURL as! String)
                    DispatchQueue.main.async {
                        cell.profileImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
                    }
                }
            }
        } else {
            //  삭제된 유저의 경우
            cell.profileName.text = "탈퇴 유저"
            cell.profileImage.image = #imageLiteral(resourceName: "user_profile")
        }
        
        // 장소 이름
        if let store = ReviewArray[indexPath.row].store {
            cell.storeName.text = "장소: \(String(describing: store.name!))"
        } else {
            cell.storeName.text = "가게 이름"
        }
        
        // 라이크버튼 설정 - 라이크 모양은 여기서 컨트롤, delegate에서 user 라이크 컨트롤
        DispatchQueue.global(qos: .userInteractive).async {
            
            let likeStore = Backendless.sharedInstance().data.of(ReviewLikes.ofClass())
            let dataQuery = BackendlessDataQuery()
            
            let objectID = review.objectId!
            let userID = UserManager.currentUser()!.objectId!
            // print("objectID & userID: \(objectID) & \(userID)")
            
            // 여기서 by가 현재 유저의 objectId이어야 하고, to는 이 리뷰의 objectId이어야 한다
            dataQuery.whereClause = "by = '\(userID)' AND to = '\(objectID)'"
            
            DispatchQueue.main.async {
                likeStore?.find(dataQuery, response: { (collection) in
                    let likes = collection?.data as! [ReviewLikes]
                    
                    // 하트를 안 눌렀을 때
                    if likes.count == 0 {
                        DispatchQueue.main.async {
                            cell.likeButton.setImage(#imageLiteral(resourceName: "like_bw"), for: .normal)
                        }
                    } else {
                        DispatchQueue.main.async {
                            cell.likeButton.setImage(#imageLiteral(resourceName: "like_red"), for: .normal)
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
            
            DispatchQueue.global(qos: .userInteractive).async {
                let matchingLikes = likeStore?.find(countQuery)
                let likeNumbers = matchingLikes?.totalObjects
                
                DispatchQueue.main.async {
                    if likeNumbers == 0 {
                        cell.likeLabel.text = "라이크 없음 ㅠ"
                    } else {
                        cell.likeLabel.text = "\(String(describing: likeNumbers!))개의 좋아요"
                    }
                }
            }
        }
        
        // 리뷰 평점 배당
        cell.ratingView.value = review.rating as! CGFloat
        
        // 리뷰 바디
        cell.reviewBody.text = review.text
        
        // 코멘트 개수 받아오기
        DispatchQueue.global(qos: .userInteractive).async {
            // 댓글수 찾기
            let tempStore = Backendless.sharedInstance().data.of(ReviewComment.ofClass())
            
            let reviewId = review.objectId!
            let dataQuery = BackendlessDataQuery()
            // 이 리뷰에 달린 댓글 모두 몇 개인지 찾기
            dataQuery.whereClause = "to = '\(reviewId)'"
            
            DispatchQueue.main.async {
                tempStore?.find(dataQuery, response: { (collection) in
                    let comments = collection?.data as! [ReviewComment]
                    
                    cell.replyLabel.text = "댓글 \(comments.count)개"
                    
                }, error: { (Fault) in
                    print("서버에서 댓글 얻어오기 실패: \(String(describing: Fault?.description))")
                })
            }
        }
        
        // 사진URL이 유효한지 체크
        if let string = review.fileURL {
            cell.photoList = string.components(separatedBy: ",").sorted()
            cell.photoStackview.isHidden = false
            cell.pageControl.isHidden = false
            cell.collectionView.reloadData()
        } else {
            print("There is no fileURL: \(review.text)")
            // cell.collectionView.isHidden = true
            cell.photoStackview.isHidden = true
            cell.pageControl.isHidden = true
            cell.collectionView.reloadData()
        }
        
        cell.timeLabel.text = dateFormatter.string(from: review.created! as Date)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    // MARK: - Interation Handling
    // 프로필 이름 및 이미지 - 태그 0
    // 댓글 라벨 - 태그 1, 신고 버튼 - 태그 2
    // 댓글 버튼 - 태그 3, 공유 버튼 - 태그 4
    // 해당 샵으로 이동하는 버튼 - 태그 5
    // 사진 보여주기 - 태그 6
    // 좋아요 버튼 - 태그 7
    // 좋아요 라벨 - 태그 8
    func actionTapped(tag: Int) {
        let row = tag/10
        let realTag = tag%10
        
        switch realTag {
        case 0:
            print("프로필뷰 만들면 이동")
        case 1:
            print("댓글 라벨 탭")
            // 코멘트 액션
            performSegue(withIdentifier: "showComments", sender: row)
            lastContentOffset = tableView.contentOffset.y
        case 2:
            print("신고 버튼 탭")
            sendEmail(row)
        case 3:
            print("댓글 버튼 탭")
            // 코멘트 액션
            performSegue(withIdentifier: "showComments", sender: row)
            lastContentOffset = tableView.contentOffset.y
        case 4:
            // 공유 액션
            self.shareButtonPressed(row)
        case 5:
            // 이동 액션
            self.moveToStore(row)
        case 6:
            // 사진 보기
            self.showPhoto(row)
        case 7:
            // 좋아요 관련 액션
            // 라이크 체크
            self.checkLike(row, completionHandler: { (success) in
                if success {
                    // 이미 좋아해서 취소할 때
                    self.changeLike(row, true, completionHandler: { (success) in
                        if success {
                            // 나중에 DB에 처리하고 바꿔주기
                            // self.tableView.reloadData()
                        }
                    })
                } else {
                    // 새롭게 좋아해서 추가
                    self.changeLike(row, false, completionHandler: { (success) in
                        if success {
                            // 나중에 DB에 처리하고 바꿔주기
                            // self.tableView.reloadData()
                        }
                    })
                }
            })
            
        default:
            print("Some other action")
        }
    }
    
    // 라이크가 체크되었는지를 확인
    func checkLike(_ row: Int, completionHandler: @escaping (_ success: Bool) -> Void) {
        
        let userID = Backendless.sharedInstance().userService.currentUser.objectId
        let selectedReviewID = ReviewArray[row].objectId
        
        // 리뷰라이크 클래스를 스토리 ID로 검색해서 스토리를 찾음
        let dataStore = Backendless.sharedInstance().data.of(ReviewLikes.ofClass())
        
        // 여기서 쿼리는 by: userID와 to: reviewID가 match이 되어야 함
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = "by = '\(userID!)' AND to = '\(selectedReviewID!)'"
        
        dataStore?.find(dataQuery, response: { (collection) in
            let like = collection?.data as! [ReviewLikes]
            
            if like.count == 0 {
                // 없는 경우 false return
                completionHandler(false)
            } else {
                // 이미 있는 경우 true를 return
                completionHandler(true)
            }
            
        }, error: { (Fault) in
            print("에러: \(String(describing: Fault?.description))")
        })
    }
    
    func changeLike(_ row: Int, _ alreadyLike: Bool, completionHandler: @escaping (_ success:Bool) -> Void) {
        
        let selectedReview = ReviewArray[row]
        let reviewId = selectedReview.objectId
        
        // 그냥 유저 객체로 비교는 안되고 objectId로 체크를 해야 함
        let objectID = Backendless.sharedInstance().userService.currentUser.objectId
        
        let dataStore = Backendless.sharedInstance().data.of(ReviewLikes.ofClass())
        
        // 좋아요 - alreadyLike가 true이면
        if !alreadyLike {
            // 객체 생성
            
            let like = ReviewLikes()
            like.by = objectID! as String
            like.to = reviewId
            
            dataStore?.save(like, response: { (response) in
                print("liked")
                DispatchQueue.main.async {
                    let indexPath = IndexPath(row: row, section: 0)
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
                
            }, error: { (Fault) in
                print("리뷰 라이크를 저장하는데 에러: \(String(describing: Fault?.description))")
            })
            
        } else {
            // 좋아요 취소
            
            // 먼저 reviewLikes에서 해당 라이크 찾기
            let dataQuery = BackendlessDataQuery()
            // 쿼리문은 by가 유저ID, to가 현재 포스트 objectId일 때
            dataQuery.whereClause = "by = '\(objectID!)' AND to = '\(reviewId!)'"
            
            dataStore?.find(dataQuery, response: { (collection) in
                let like = (collection?.data as! [ReviewLikes]).first
                
                dataStore?.remove(like, response: { (number) in
                    DispatchQueue.main.async {
                        let indexPath = IndexPath(row: row, section: 0)
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }, error: { (Fault) in
                    print("리뷰 라이크 지우는데 에러: \(String(describing: Fault?.description))")

                })
                
            }, error: { (Fault) in
                print("리뷰 라이크 찾는데 에러: \(String(describing: Fault?.description))")
            })
            
        }
        
    }

    
    /// 사진 전체화면으로 보기
    func showPhoto(_ row: Int) {
        
        // imageArray 구성하기
        let selectedReview = ReviewArray[row]
        let selectedImages = selectedReview.fileURL
        let imageURL = selectedImages?.components(separatedBy: ",")
        
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
    
    /// 해당 장소로 뷰 이동
    func moveToStore(_ row: Int) {
        let selectedReview = ReviewArray[row]
        let selectedStore = selectedReview.store
        let selectedObjectId = selectedStore?.objectId
        
        let dataStore = Backendless.sharedInstance().data.of(Store.ofClass())
        dataStore?.findID(selectedObjectId, response: { (response) in
            
            let returnedStore = response as? Store
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "StoreDetailViewController") as! StoreDetailViewController
            destinationVC.storeToDisplay = returnedStore
            self.navigationController?.pushViewController(destinationVC, animated: true)
            
        }, error: { (Fault) in
            print("Server reported an error: \(String(describing: Fault?.description))")
        })
        
    }
    
    /// 신고 이메일 현재 수신인: ourpro.choi@gmail.com
    func sendEmail(_ row: Int) {
        let userEmail = Backendless.sharedInstance().userService.currentUser.email
        let selectedReview = ReviewArray[row]
        
        let subject = "리뷰 게시물 신고 이메일"
        let body = "신고 사용자: \(userEmail!).\n 신고한 게시물은 이 게시물입니다. ID: \(String(describing: selectedReview.objectId!))"
        let recipient = "ourpro.choi@gmail.com"
        Backendless.sharedInstance().messagingService.sendHTMLEmail(subject, body: body, to: [recipient], response: { (response) in
            SCLAlertView().showSuccess("신고 완료", subTitle: "제출되었습니다")
        }) { (Fault) in
            print("Server reported an error: \(String(describing: Fault?.description))")
        }
    }
    
    /// 공유를 위한 함수
    func shareButtonPressed(_ row: Int) {
        let selectedReview = ReviewArray[row]
        
        let shareText = "이 리뷰를 펫시티에서 같이 봐주세요!"
        if let bodyText = selectedReview.text {
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
            let index = sender as! Int
            let destinationVC = segue.destination as! ReviewCommentViewController
            destinationVC.selectedReview = ReviewArray[index]
        }
    }
}


// MARK - CollectionView Method, 위치 표시
extension ReviewViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationCell", for: indexPath) as! ReviewLocationCollectionViewCell
        
        cell.locationLabel.text = locations[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5) {
            self.locationShowView.alpha = 0.0
            self.tableView.alpha = 1.0
        }
        isShowing = false
        self.tableView.isUserInteractionEnabled = true
        selectedLocation = locations[indexPath.row]
        locationLabel.text = selectedLocation
        downloadReviews(selectedLocation)
    }
}

