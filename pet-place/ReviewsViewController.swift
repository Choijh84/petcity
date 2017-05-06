//
//  ReviewsViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 20..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import SCLAlertView
import Kingfisher
import OneSignal

/// 스토어뷰에서 리뷰를 더 보기하면 스토어 관련된 리뷰를 쭉 보여주는 뷰컨트롤러
class ReviewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ReviewTableViewCellProtocol {

    /// Button to leave a review
    @IBOutlet weak var reviewButton: UIButton!
    /// TableView that displays all the reviews
    @IBOutlet weak var tableView: LoadingTableView!
    
    /// Manager that handles downloading reviews
    let reviewDownloadManager = ReviewManager()
    /// The selected store object, which reviews should be displayed
    var selectedStoreObject: Store!
    
    /// Array of reviews to be displayed
    var reviewsArray: [Review] = []
    /// Refresh control
    var refreshControl: UIRefreshControl!
    
    /// 내리고 있던 스토리의 위치를 기억함
    var verticalContentOffset: CGFloat = 0
    
    /// Lazy getter for the dateformatter that formats the date property of each review to the desired format
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    /// True, if we currently loading new reviews
    var isLoadingItems: Bool = false
    
    let reviewPresentManager : ReviewPresentManager = ReviewPresentManager()
    
    /**
     Called after you successfully left a review for the selected Store, from AddReviewViewController. Will reload all the reviews
     
     - parameter unwindSegue: segue
     */
    @IBAction func unwindFromAddNewReviewController(_ unwindSegue: UIStoryboardSegue) {
        loadReviews()
    }

    /**
     Called after the view is loaded. Sets up the tableView, and downloads the reviews.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        title = "리뷰"
        
        reviewButton.layer.cornerRadius = 6.0
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .globalTintColor()
        refreshControl.addTarget(self, action: #selector(ReviewsViewController.loadReviews), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "reviewCell")
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // 업로드가 된걸 노티 받으면 바로 refresh, reviewUploaded & reviewChanged(편집)
        NotificationCenter.default.addObserver(self, selector: #selector(ReviewsViewController.refresh), name: NSNotification.Name(rawValue: "reviewUploaded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ReviewsViewController.refresh), name: NSNotification.Name(rawValue: "reviewChanged"), object: nil)
        
        // 리뷰 코멘트가 올라가거나 변경된걸 받으면 바로 refresh
        NotificationCenter.default.addObserver(self, selector: #selector(ReviewsViewController.refresh), name: NSNotification.Name(rawValue: "reviewCommentChanged"), object: nil)
        
        // 처음에 10개는 로딩
        DispatchQueue.main.async {
            self.loadReviews()
        }
    }
    
    /**
     Set the navigation bar visible
     - parameter animated: animated
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 기억하고 있던 자리로 이동 - 나중에 실시간 글이 많아지게 되면 안 통할 듯...
        // 10개 이상 있던 곳에서 확인했다가 돌아오면? 어떻게 그걸 보유하고 있을까
        tableView.setContentOffset(CGPoint(x: 0, y: verticalContentOffset), animated: false)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // 노티를 통해 refresh를 받으면 table reload
    func refresh() {
        loadReviews()
        tableView.reloadData()
    }
    
    /**
     Load the reviews for the selected Store
     - 처음 다운로드 함수이므로 reviewsArray를 비우고 시작, 추가 다운로드는 loadMoreReviews에서 처리
     */
    func loadReviews() {
        isLoadingItems = true
        reviewsArray.removeAll()
        self.tableView.showLoadingIndicator()
        refreshControl.beginRefreshing()
        
        reviewDownloadManager.downloadReviewCountAndReviewByPage(skippingNumberOfObject: 0, limit: 10, storeObject: selectedStoreObject) { (reviews, error) in
            self.isLoadingItems = false
            if let error = error {
                self.showAlertViewWithRedownloadOption(error)
            } else {
                if let reviews = reviews {
                    self.reviewsArray.append(contentsOf: reviews)
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
     스크롤을 70% 이상 내리면 발동되는 리뷰 객체 추가 다운로드 함수
     */
    func loadMoreReviews(skipNumber: Int) {
        isLoadingItems = true
        self.refreshControl.beginRefreshing()
        self.tableView.showLoadingIndicator()
        
        reviewDownloadManager.downloadReviewCountAndReviewByPage(skippingNumberOfObject: skipNumber as NSNumber, limit: 10, storeObject: selectedStoreObject) { (reviews, error) in
            self.isLoadingItems = false
            if let error = error {
                self.showAlertViewWithRedownloadOption(error)
            } else {
                if let reviews = reviews {
                    self.reviewsArray.append(contentsOf: reviews)
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
        
        var selectedNumber = 0
        if reviewsArray.count >= 10 {
            selectedNumber = reviewsArray.count
        } else {
            selectedNumber = 10
        }
        
        // 조건: 스크롤의 70% 이상 내려오고, 현재 로딩 중이 아니며,
        if endScrolling >= (scrollView.contentSize.height*0.7) && !isLoadingItems && reviewsArray.count >= (selectedNumber) {
            self.loadMoreReviews(skipNumber: selectedNumber)
        }
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
            self.loadReviews()
        }
        alert.showError("에러 발생", subTitle: "다운로드에 문제가 있습니다")
    }

    // MARK: tableView methods
    /**
     How many rows to display, in this case the number of reviews.
     
     - parameter tableView: tableView
     - parameter section:   at which section
     
     - returns: number of rows
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewsArray.count
    }

    /**
     Asks the data source for a cell to insert in a particular location of the table view. Get the right review and set the cell.
     
     - parameter tableView: tableView
     - parameter indexPath: which indexPath
     
     - returns: cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reviewCell = tableView.dequeueReusableCell(withIdentifier: "reviewCell") as! ReviewTableViewCell
        
        // 해당되는 리뷰 객체
        let reviewObject = reviewsArray[indexPath.row]
        
        // 프로토콜 delegate 설정
        reviewCell.delegate = self
        
        // tag 설정
        // 댓글 개수 - 태그 0
        // 댓글 버튼 - 태그 1
        // 공유 버튼 - 태그 2
        // 좋아요 버튼 - 태그 3
        reviewCell.commentLabel.tag = (indexPath.row*10)+0
        reviewCell.commentButton.tag = (indexPath.row*10)+01
        reviewCell.shareButton.tag = (indexPath.row*10)+02
        reviewCell.likeButton.tag = (indexPath.row*10)+03
        
        // 리뷰 프로필 뷰 세팅
        let userId = reviewObject.creator?.objectId!
        let dataStore = Backendless.sharedInstance().data.of(Users.ofClass())
        DispatchQueue.main.async { 
            dataStore?.findID(userId, response: { (response) in
                let user = response as! BackendlessUser
                if let imageURL = user.getProperty("profileURL") {
                    reviewCell.profileImageView.kf.setImage(with: URL(string: imageURL as! String), placeholder: #imageLiteral(resourceName: "imageLoadingHolder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
                }
                reviewCell.nameLabel.text = user.name! as String
            }, error: { (Fault) in
                print("Server reported error on retreiving an user: \(String(describing: Fault?.description))")
            })
        }
        
        // 라이크버튼 설정 - 라이크 모양은 여기서 컨트롤, delegate에서 user 라이크 컨트롤
        DispatchQueue.global(qos: .userInteractive).async {
            
            let likeStore = Backendless.sharedInstance().data.of(ReviewLikes.ofClass())
            let dataQuery = BackendlessDataQuery()
            
            let objectID = reviewObject.objectId!
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
                            reviewCell.likeButton.setImage(#imageLiteral(resourceName: "like_bw"), for: .normal)
                        }
                    } else {
                        DispatchQueue.main.async {
                            reviewCell.likeButton.setImage(#imageLiteral(resourceName: "like_red"), for: .normal)
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
                        reviewCell.likeLabel.text = "라이크 없음 ㅠ"
                    } else {
                        reviewCell.likeLabel.text = "\(String(describing: likeNumbers!))개의 좋아요"
                    }
                }
            }
        }
        
        // 코멘트 개수 받아오기
        DispatchQueue.global(qos: .userInteractive).async {
            // 댓글수 찾기
            let tempStore = Backendless.sharedInstance().data.of(ReviewComment.ofClass())
            
            let reviewId = reviewObject.objectId!
            let dataQuery = BackendlessDataQuery()
            // 이 리뷰에 달린 댓글 모두 몇 개인지 찾기
            dataQuery.whereClause = "to = '\(reviewId)'"
            
            DispatchQueue.main.async {
                tempStore?.find(dataQuery, response: { (collection) in
                    let comments = collection?.data as! [ReviewComment]
                    
                    reviewCell.commentLabel.text = "댓글 \(comments.count)개"
                    
                }, error: { (Fault) in
                    print("서버에서 댓글 얻어오기 실패: \(String(describing: Fault?.description))")
                })
            }
        }
        
        reviewCell.reviewTextLabel.text = reviewObject.text
        reviewCell.setRating(reviewObject.rating)
        reviewCell.dateLabel.text = dateFormatter.string(from: reviewObject.created as Date)
        
        if let fileURL = reviewObject.fileURL {
            reviewCell.setReviewImageViewHidden(false)
            let imageArray = fileURL.components(separatedBy: ",").sorted()
            if imageArray.count == 1 {
                
                // 이미지가 1개인 경우
                DispatchQueue.main.async(execute: { 
                    reviewCell.reviewImageView.kf.setImage(with: URL(string: fileURL), placeholder: #imageLiteral(resourceName: "imageLoadingHolder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
                })
                
                
            } else {
                // 이미지가 여러개인 경우 한개만 우선 앞에 보이기
                DispatchQueue.main.async(execute: { 
                    reviewCell.reviewImageView.kf.setImage(with:  URL(string: imageArray[0]), placeholder: #imageLiteral(resourceName: "imageLoadingHolder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
                })
                
                // Add UIView which can explain the number of photos behind
                let myLabel = UILabel(frame: CGRect(x: reviewCell.reviewImageView.frame.width-30, y: reviewCell.reviewImageView.frame.height-30, width: 30, height: 30))
                myLabel.textAlignment = .center
                myLabel.backgroundColor = UIColor(red: 211, green: 211, blue: 211, alpha: 0.8)
                myLabel.text = "+\(imageArray.count-1)"
                myLabel.font = UIFont(name: "Avenir", size: 12)
                reviewCell.reviewImageView.addSubview(myLabel)
                reviewCell.reviewImageView.bringSubview(toFront: myLabel)
            }
        } else {
            reviewCell.setReviewImageViewHidden(true)
        }
        return reviewCell
    }
    
    /// 테이블 선택했을 때 해당되는 리뷰의 detail뷰로 이동하게 함
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 우선 선택 해제
        tableView.deselectRow(at: indexPath, animated: true)
        // 뷰 이동
        // performSegue(withIdentifier: "showReview", sender: indexPath)
        performSegue(withIdentifier: "showDetail", sender: indexPath)
    }
    
    // MARK: Interaction Handling 
    // 댓글 개수 - 태그 0
    // 댓글 버튼 - 태그 1
    // 공유 버튼 - 태그 2
    // 좋아요 버튼 - 태그 3
    
    func actionTapped(tag: Int) {
        let row = tag/10
        let realTag = tag%10
        
        switch realTag {
            case 0:
                print("Comment Button Clicked")
                verticalContentOffset = tableView.contentOffset.y
                // 코멘트 액션 - 뷰 이동
                performSegue(withIdentifier: "showComments", sender: row)
            
            case 1:
                print("Comment Button Clicked")
                verticalContentOffset = tableView.contentOffset.y
                performSegue(withIdentifier: "showComments", sender: row)
            
            case 2:
                print("Share Button Clicked")
                // 공유 액션
                self.shareButtonPressed(row)
            
            case 3:
                print("Like Button Clicked")
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
        let selectedReviewID = reviewsArray[row].objectId
        
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
        
        let selectedReview = reviewsArray[row]
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
                DispatchQueue.main.async {
                    let indexPath = IndexPath(row: row, section: 0)
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
                
                // 리뷰 쓴 사람에게 Notification 날리기
                if let oneSignalId = selectedReview.creator?.getProperty("OneSignalID") {
                    if let userName = UserManager.currentUser()!.getProperty("nickname") {
                        let data = ["contents" : ["en" : "\(userName) likes your Review!", "ko" : "\(userName)가 당신의 리뷰를 좋아합니다"], "include_player_ids" : ["\(oneSignalId)"], "ios_badgeType" : "Increase", "ios_badgeCount" : "1"] as [String : Any]
                        OneSignal.postNotification(data)
                        
                        // 데이터베이스에 저장하기
                        // 푸쉬 객체 생성
                        let newPush = PushNotis()
                        newPush.from = objectID! as String
                        newPush.to = selectedReview.creator!.objectId! as String
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
    
    /// 공유를 위한 함수
    func shareButtonPressed(_ row: Int) {
        let selectedReview = reviewsArray[row]
        
        let shareText = "이 리뷰를 펫시티에서 같이 봐주세요!"
        if let bodyText = selectedReview.text {
            let activityViewController = UIActivityViewController(activityItems: [ shareText, bodyText ], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        } else {
            let activityViewController = UIActivityViewController(activityItems: [ shareText ], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    

    // MARK: - Navigation method 
    
    /**
     Called before performing a segue. Need to assign the selected Store object to the AddReviewViewController, to be able to leave a review on that Store object.
     
     - parameter segue:  segue
     - parameter sender: sender
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddNewReview" {
            let destinationController = segue.destination as! AddReviewViewController
            destinationController.selectedStore = selectedStoreObject
        } else if segue.identifier == "showReview", let indexPath = sender as? IndexPath {
            let selectedReview = reviewsArray[indexPath.row]
            let destinationController = segue.destination as! ReviewsDetailViewController
            destinationController.reviewToDisplay = selectedReview
            destinationController.transitioningDelegate = reviewPresentManager
        } else if segue.identifier == "showComments" {
            let index = sender as! Int
            let destinationVC = segue.destination as! ReviewCommentViewController
            destinationVC.selectedReview = reviewsArray[index]
        } else if segue.identifier == "showDetail", let indexPath = sender as? IndexPath  {
            let selectedReview = reviewsArray[indexPath.row]
            let destinationVC = segue.destination as! ReviewDetailViewController
            destinationVC.selectedReview = selectedReview
        }
    }
    
    /**
     Determines whether the segue with the specified identifier should be performed. In our case, if user is not logged in, we present the loginViewController instead of performing the segue
     
     - parameter identifier: identifier of the segue
     - parameter sender:     sender
     
     - returns: YES, if it should be executed
     */
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showAddNewReview" {
            if UserManager.isUserLoggedIn() {
                return true
            } else {
                // display login view
                let loginViewController = StoryboardManager.loginViewController()
                loginViewController.displayCloseButton = true
                present(loginViewController, animated: true, completion: nil)
                return false
            }
        }
        
        return true
    }
    
    /**
     Which statusbar style to display, white in this case.
     
     - returns: White statusbar.
     */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

}
