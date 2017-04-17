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
        reviewObject.commentNumbers = reviewObject.comments.count
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
                    reviewCell.profileImageView.kf.setImage(with: URL(string: imageURL as! String), placeholder: #imageLiteral(resourceName: "imageplaceholder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
                }
                reviewCell.nameLabel.text = user.name! as String
            }, error: { (Fault) in
                print("Server reported error on retreiving an user: \(String(describing: Fault?.description))")
            })
        }
        
        // 좋아요 체크해서 이미지 바꿔주기
        DispatchQueue.main.async {
            self.checkLike(indexPath.row, completionHandler: { (success) in
                if success {
                    // 어떤 스토리를 좋아했다면
                    reviewCell.likeButton.setImage(#imageLiteral(resourceName: "like_red"), for: .normal)
                    
                } else {
                    // 좋아했던 스토리가 아니라면
                    reviewCell.likeButton.setImage(#imageLiteral(resourceName: "like_bw"), for: .normal)
                    
                }
            })
        }

        reviewCell.likeLabel.text = "좋아요 \(reviewObject.likeNumbers)개"
        reviewCell.commentLabel.text = "댓글 \(reviewObject.commentNumbers)개"
        reviewCell.reviewTextLabel.text = reviewObject.text
        reviewCell.setRating(reviewObject.rating)
        reviewCell.dateLabel.text = dateFormatter.string(from: reviewObject.created as Date)
        
        if let fileURL = reviewObject.fileURL {
            reviewCell.setReviewImageViewHidden(false)
            let imageArray = fileURL.components(separatedBy: ",").sorted()
            if imageArray.count == 1 {
                
                // 이미지가 1개인 경우
                DispatchQueue.main.async(execute: { 
                    reviewCell.reviewImageView.kf.setImage(with: URL(string: fileURL), placeholder: #imageLiteral(resourceName: "imageplaceholder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
                })
                
                
            } else {
                // 이미지가 여러개인 경우 한개만 우선 앞에 보이기
                DispatchQueue.main.async(execute: { 
                    reviewCell.reviewImageView.kf.setImage(with:  URL(string: imageArray[0]), placeholder: #imageLiteral(resourceName: "imageplaceholder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
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
        performSegue(withIdentifier: "showReview", sender: indexPath)
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
            
                // 코멘트 액션 - 뷰 이동
                // let storyboard = UIStoryboard(name: "StoryAndReview", bundle: nil)
                // let viewController = storyboard.instantiateViewController(withIdentifier: "ReviewCommentViewController") as! ReviewCommentViewController
                // viewController.selectedReview = reviewsArray[row]
                // let navController = UINavigationController(rootViewController: viewController)
                // self.present(navController, animated: true, completion: nil)
                //self.navigationController?.pushViewController(viewController, animated: true)
            
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
        // 기본은 라이크가 체크되어 있지 않다
        var isLike = false
        
        // 스토리 클래스를 스토리 ID로 검색해서 스토리를 찾음
        let dataStore = Backendless.sharedInstance().data.of(Review.ofClass())
        
        dataStore?.findID(selectedReviewID, response: { (response) in
            let selectedReview = response as! Review
            let likeUsers = selectedReview.likeUsers
            
            print("내가 라이크를 눌렀었나? \(isLike) 이게 몇 번째지: \(row) 무슨 리뷰지: \(selectedReview.text)")
            
            // 좋아요를 누른 유저를 검색, objectId를 검색해서 있는 경우 isLike값 true로 변경 - 콘솔에서 autoload가 필수
            for likeUser in likeUsers {
                if likeUser.objectId == userID {
                    isLike = true
                }
            }
            
            print("라이크 결과: \(isLike)")
            
            completionHandler(isLike)
            
        }, error: { (Fault) in
            print("Server reported an error: \(String(describing: Fault?.description))")
            // 이래도 되나...
            completionHandler(isLike)
        })
    }
    
    func changeLike(_ row: Int, _ alreadyLike: Bool, completionHandler: @escaping (_ success:Bool) -> Void) {
        print("Changen LIKE in Review")
        let selectedReview = reviewsArray[row]
        let reviewId = selectedReview.objectId
        
        let likeNumber = selectedReview.likeNumbers
        print("현재 라이크수: \(likeNumber)개")
        
        // 그냥 유저 객체로 비교는 안되고 objectId로 체크를 해야 함
        let objectID = Backendless.sharedInstance().userService.currentUser.objectId
        
        let dataStore = Backendless.sharedInstance().data.of(Review.ofClass())
        
        // 적용이 안되는거 같으니 DB에서 한 번 찾아서 작업합세 - 완료
        dataStore?.findID(reviewId, response: { (response) in
            let foundReview = response as! Review
            
            // 이미 라이크를 누른 상태에서 취소
            if alreadyLike {
                // 좋아요 숫자 줄이기
                foundReview.likeNumbers = likeNumber-1
                
                // 유저 삭제하기
                let likeUserArray = foundReview.likeUsers
                for (index, _) in likeUserArray.enumerated() {
                    if likeUserArray[index].objectId == objectID {
                        foundReview.likeUsers.remove(at: index)
                        print("내가 좋아요 눌렀던거 제거함")
                    }
                }
                
                dataStore?.save(foundReview, response: { (response) in
                    let review = response as! Review
                    print("지우기 성공: \(review.likeNumbers)")
                    self.reviewsArray[row] = review
                    
                    let indexPath = IndexPath(row: row, section: 0)
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    completionHandler(true)
                }, error: { (Fault) in
                    print("Server reported an error on update Like in Review: \(String(describing: Fault?.description))")
                    completionHandler(false)
                })
                
            } else {
                // 라이크를 누른 경우
                foundReview.likeNumbers = likeNumber+1
                
                foundReview.likeUsers.append(Backendless.sharedInstance().userService.currentUser)
                
                dataStore?.save(foundReview, response: { (response) in
                    let review = response as! Review
                    print("리뷰 라이크 바꾸기 성공: \(review.likeNumbers)")
                    self.reviewsArray[row] = review
                    
                    let indexPath = IndexPath(row: row, section: 0)
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    completionHandler(true)
                }, error: { (Fault) in
                    print("Server reported an error on update Like in Review: \(String(describing: Fault?.description))")
                    completionHandler(false)
                })
            }
            
        }, error: { (Fault) in
            print("Server reported an error: \(String(describing: Fault?.description))")
        })
        
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
    

    // MARK: - Navigation
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
