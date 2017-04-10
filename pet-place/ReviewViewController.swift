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
    
    /// Refreshcontrol to show a loading indicator and a pull to refresh view, when the view is loading content
    var refreshControl: UIRefreshControl!
    
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
        tableView.showLoadingIndicator()
        
        // height setting
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableViewAutomaticDimension
        
        customizeViews()
        
        DispatchQueue.main.async {
            self.downloadReviews(nil)
        }
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tableView.reloadData()
        // 기존에 봤던 자리로 원위치
        tableView.setContentOffset(CGPoint(x: 0, y: lastContentOffset), animated: false)
        super.viewWillAppear(animated)
        
    }
    
    /**
     초기에 리뷰를 다운로드 하는 함수, 아직 로케이션 처리는 안됨
     - 처음 다운로드 하므로 데이터 배열을 초기화하고 시작, 추가 다운로드는 downloadMoreReviews에서 처리
    */
    func downloadReviews(_ location: String?) {
        isLoadingItems = true
        refreshControl.beginRefreshing()
        tableView.showLoadingIndicator()

        // 배열 초기화
        ReviewArray.removeAll()
        
        // 향후에 파라미터로 로케이션이 들어가면 쿼리가 되어야 함
        
        ReviewManager().downloadReviewPage(skippingNumberOfObects: 0, location: location, limit: 10) { (reviews, error) in
            self.isLoadingItems = false
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
        self.refreshControl.endRefreshing()
        self.tableView.hideLoadingIndicator()
    }
    
    func downloadMoreReviews(_ location: String?) {
        isLoadingItems = true
        self.refreshControl.beginRefreshing()
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
        self.refreshControl.endRefreshing()
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
        /**
        if (self.lastContentOffset < scrollView.contentOffset.y) {
            print("Hide")
            UIView.animate(withDuration: 0.5, animations: {
                self.locationView.isHidden = true
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.locationView.isHidden = false
            })
        }
        self.lastContentOffset = scrollView.contentOffset.y
        */
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
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .globalTintColor()
        refreshControl.addTarget(self, action: #selector(ReviewViewController.downloadReviews), for: .valueChanged)
        tableView.addSubview(refreshControl)
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
        // 댓글 버튼 - 태그 3, 공유 버튼 - 태그 4
        cell.profileImage.tag = (indexPath.row*10)+0
        cell.profileName.tag = (indexPath.row*10)+0
        cell.replyLabel.tag = (indexPath.row*10)+01
        cell.moreButton.tag = (indexPath.row*10)+02
        cell.replyButton.tag = (indexPath.row*10)+03
        cell.shareButton.tag = (indexPath.row*10)+04
        
        // 프로필 이미지랑 닉네임 설정
        if let user = review.creator {
            let nickname = user.getProperty("nickname") as! String
            cell.profileName.text = nickname
            
            if let profileURL = user.getProperty("profileURL") {
                if profileURL is NSNull {
                    cell.profileImage.image = #imageLiteral(resourceName: "user_profile")
                } else {
                    let url = URL(string: profileURL as! String)
                    cell.profileImage.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imageplaceholder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
                }
            }
        } else {
            //  삭제된 유저의 경우
            cell.profileName.text = "탈퇴 유저"
            cell.profileImage.image = #imageLiteral(resourceName: "user_profile")
        }
        
        // 스토어 이름을 쿼리를 해와야되는거 같다... 따로 StoreArray를 만들어야 하나?
        if let store = ReviewArray[indexPath.row].store {
            cell.storeName.text = "장소: \(String(describing: store.name!))"
        } else {
            cell.storeName.text = "가게 이름"
        }
        
        // 리뷰 평점 배당
        cell.ratingView.value = review.rating as! CGFloat
        
        // 리뷰 바디
        cell.reviewBody.text = review.text
        // 댓글 개수 적어기기
        cell.replyLabel.text = String(review.commentNumbers) + "개의 리플"
        
        if let string = review.fileURL {
            cell.photoList = string.components(separatedBy: ",").sorted()
            cell.collectionView.reloadData()
        } else {
            cell.collectionView.isHidden = true
            cell.pageControl.isHidden = true
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
        default:
            print("Some other action")
        }
    }
    
    // 신고 이메일 현재 수신인: ourpro.choi@gmail.com
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


// MARK - CollectionView Method, 사진 표시
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

