//
//  StoryViewController.swift
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
import OneSignal

class StoryViewController: UIViewController, IndicatorInfoProvider, UITableViewDataSource, UITableViewDelegate, StoryTableViewCellProtocol {
    
    var StoryArray: [Story] = []
    var isMyStory = false
    
    var itemInfo: IndicatorInfo = "스토리"
    
    @IBOutlet weak var tableView: LoadingTableView!
    
    /// 내리고 있던 스토리의 위치를 기억함
    var verticalContentOffset: CGFloat = 0
    
    /// 스토리를 다운로드하고 있으면 true
    var isLoadingItems: Bool = false
    
    /// Lazy loader for LoginViewController, cause we might not need to initialize it in the first place
    lazy var loginViewController: LoginViewController = {
        let loginViewController = StoryboardManager.loginViewController()
        return loginViewController
    }()
    
    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // 처음에 메모리에 뷰가 없을 때에만 보여주는 함수
    override func viewDidLoad() {
        
        // height setting
        tableView.estimatedRowHeight = 450
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // 스크롤뷰 속도 조절
        tableView.decelerationRate = UIScrollViewDecelerationRateFast
        
        customizeViews()
        
        let user = Backendless.sharedInstance().userService.currentUser
        
        // 유저 로그인이 안 되어있으면 로그인으로 이동, 이건 StoryAndReviewViewControllerdㅔ서 처리
        if user == nil {
            
        } else {
            // 내 스토리인 경우에는 다운로드 안함
            if isMyStory {
                // tableView.reloadData()
                self.tableView.hideLoadingIndicator()
                title = "내 스토리"
            } else {
                downloadStory()
                tableView.reloadData()
            }
        }
        
        // 변경된걸 노티 받으면 refresh - storyUploaded(업로드), 삭제(storyChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(StoryViewController.refresh), name: NSNotification.Name(rawValue: "storyUploaded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StoryViewController.refresh), name: NSNotification.Name(rawValue: "storyChanged"), object: nil)
        
        super.viewDidLoad()
    }
    
    // 뷰가 보일 때마다 불러오는 함수
    override func viewWillAppear(_ animated: Bool) {
        
        // 기억하고 있던 자리로 이동
        tableView.setContentOffset(CGPoint(x: 0, y: verticalContentOffset), animated: false)
        
        super.viewWillAppear(animated)
    }
    
    /**
     Checks if the loginViewController is already presented, if not, it adds it as a subview to our view
     */
    func presentLoginViewController() {
        if loginViewController.view.superview == nil {
            self.tabBarController?.selectedIndex = 3
            loginViewController.view.frame = self.view.bounds
            loginViewController.willMove(toParentViewController: self)
            view.addSubview(loginViewController.view)
            loginViewController.didMove(toParentViewController: self)
            addChildViewController(loginViewController)
            
        } else {
            // 여기서 dismiss를 하게 되면 topview로 돌아감 - topview가 firstviewcontroller
            // dismiss(animated: true, completion: nil)
        }
    }
    
    // 노티를 통해 refresh를 받으면 table reload
    func refresh() {
        downloadStory()
        tableView.reloadData()
    }
    
    /**
     초기에 스토리를 다운로드 하는 함수
     - 처음 다운로드 하므로 데이터 배열을 초기화하고 시작, 추가 다운로드는 downloadMoreStory에서 처리
     */
    
    func downloadStory() {
        isLoadingItems = true
        tableView.showLoadingIndicator()
        
        // 배열 초기화
        StoryArray.removeAll()
        
        // 10개씩 다운로드
        DispatchQueue.main.async {
            StoryDownloadManager().downloadStoryByPage(skippingNumberOfObjects: 0, limit: 10, user: nil) { (stories, error) in
                self.isLoadingItems = false
                if let error = error {
                    SCLAlertView().showError("에러 발생", subTitle: error)
                } else {
                    if let stories = stories {
                        self.StoryArray.append(contentsOf: stories)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.tableView.hideLoadingIndicator()
                        }
                    }
                }
            }
        }
    }
    
    func downloadMoreStory() {
        isLoadingItems = true
        tableView.showLoadingIndicator()
        
        // 이미 다운로드 받은 스토리의 수
        let temp = StoryArray.count as NSNumber
        print("This is temp: \(temp)")
        
        DispatchQueue.global(qos: .userInitiated).async {
            StoryDownloadManager().downloadStoryByPage(skippingNumberOfObjects: temp, limit: 10, user: nil) { (stories, error) in
                self.isLoadingItems = false
                if let error = error {
                    SCLAlertView().showError("에러 발생", subTitle: error)
                } else {
                    if let stories = stories {
                        self.StoryArray.append(contentsOf: stories)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            self.tableView.hideLoadingIndicator()
        }
    }
    
    // MARK: - ScrollView Method
    
    /**
     사용자가 스크롤을 70% 이상 내리면 추가로 리뷰를 다운로드 - downloadMoreStory
     
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let endScrolling = scrollView.contentOffset.y + scrollView.frame.height
        if endScrolling >= (scrollView.contentSize.height*0.7) && !isLoadingItems && StoryArray.count >= 10 {
            self.downloadMoreStory()
        }
        
        // 최근 스크롤 뷰 기억
        self.verticalContentOffset = scrollView.contentOffset.y
    }
    
    /**
     Customize the tableview's look and feel
     */
    func customizeViews() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorColor = .separatorLineColor()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! StoryTableViewCell
        
        let story = StoryArray[indexPath.row]

        // 프로토콜 delegate 설정
        cell.delegate = self
        
        // tag 설정
        // 라이크 버튼 - 태그 1, 사진 이미지 - 태그 2
        // indexPath.row + 태그 숫자로 숫자를 조합 0,1,2,3,4,5 / 10,11,12,13,14,15 / 20,21,22,23,24,25 등
        
        cell.likeButton.tag = (indexPath.row*10)+01
        cell.singleImage?.tag = (indexPath.row*10)+02
        
        // 라이크버튼 설정 - 라이크 모양은 여기서 컨트롤, delegate에서 user 라이크 컨트롤
        // checklike를 하지 말고 우선 이미지 모양에 따라 바꿔주자
        DispatchQueue.global(qos: .userInteractive).async {
            
            let likeStore = Backendless.sharedInstance().data.of(StoryLikes.ofClass())
            let dataQuery = BackendlessDataQuery()
            
            let objectID = story.objectId!
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
                if let likeNumbers = matchingLikes?.totalObjects {
                    cell.likeNumber = likeNumbers as? Int
                    
                    DispatchQueue.main.async {
                        
                        cell.likeNumberLabel.text = String(describing: likeNumbers)
                        
                    }
                }
                
            }
        }
        
        cell.bodyTextLabel.text = story.bodyText
        cell.bodyTextLabel.setLineHeight(lineHeight: 2)
        
        DispatchQueue.global(qos: .userInteractive).async {
            if let photoList = (story.imageArray?.components(separatedBy: ",")) {
                let singleImageURL = photoList[0]
                cell.singlePhotoURL = singleImageURL
                let url = URL(string: singleImageURL)
                
                DispatchQueue.main.async {
                    cell.singleImage.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imageLoadingHolder"), options: [.processor(DefaultImageProcessor.default)], progressBlock: nil, completionHandler: nil)
                }
                
                if photoList.count > 1 {
                    cell.morePhotoButton.isHidden = false
                } else {
                    cell.morePhotoButton.isHidden = true
                }
            }
            
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let postCell = cell as? StoryTableViewCell {
            postCell.alpha = 0
            // let transform = CATransform3DTranslate(CATransform3DIdentity, 0, 40, 0)
            // cell.layer.transform = transform
            
            UIView.animate(withDuration: 0.5, animations: {
                postCell.alpha = 1
                // cell.layer.transform = CATransform3DIdentity
            })
        }
        
        /*
         // 1. 초기 상태 정의
         cell.alpha = 0
         let transform = CATransform3DTranslate(CATransform3DIdentity, -250, 20, 0)
         cell.layer.transform = transform
         
         // 2. 애니메이션
         UIView.animate(withDuration: 1.5) {
         cell.alpha = 1.0
         cell.layer.transform = CATransform3DIdentity
         }
         */
    }

    // 사진 하나당 높이는 너비로
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let width = UIScreen.main.bounds.width
        return width
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: indexPath.row)
    }
    
    // MARK: - Interation Handling
    // 라이크 버튼 - 태그 1, 사진 이미지 - 태그 2
    // indexPath.row + 태그 숫자로 숫자를 조합, 10으로 나눈 숫자가 indexPath.row / 나머지가 태그
    
    func actionTapped(tag: Int) {
        let row = tag/10
        let realTag = tag%10
        
        switch realTag {
        case 1:
            // 라이크 체크
            let indexPath = IndexPath(row: row, section: 0)
            let cell = self.tableView.cellForRow(at: indexPath) as! StoryTableViewCell
            cell.isUserInteractionEnabled = false
            
            // 라이크 변경 함수 콜 - changeLike
            self.checkLike(row, completionHandler: { (success) in
                
                if success {
                    // 이미 있을 때 - 삭제
                    if let likeNumbers = cell.likeNumber {
                        if likeNumbers > 0 {
                            cell.likeNumber = likeNumbers - 1
                            cell.likeNumberLabel.text = "\(String(likeNumbers-1))"
                        }
                    }
                    self.changeLike(row, true, completionHandler: { (success) in
                        print("취소 완료")
                        cell.isUserInteractionEnabled = true
                    
                    })
                } else {
                    // 아직 없을 때 - 추가
                    if let likeNumbers = cell.likeNumber {
                        cell.likeNumber = likeNumbers + 1
                        cell.likeNumberLabel.text = "\(String(likeNumbers+1))"
                        
                    }
                    self.changeLike(row, false, completionHandler: { (success) in
                        print("추가 완료")
                        cell.isUserInteractionEnabled = true
                    })
                }
            })
            
        case 2:
            performSegue(withIdentifier: "showDetail", sender: row)
            verticalContentOffset = tableView.contentOffset.y
            
        default:
            print("Some other action")
        }
    }
    
    // 사진 전체화면으로 보기
    func showPhoto(_ row: Int) {
        
        // imageArray 구성하기
        let selectedStory = StoryArray[row].imageArray
        let imageURL = selectedStory?.components(separatedBy: ",")
        
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
    
    // 라이크가 체크되어있는지를 확인
    func checkLike(_ row: Int, completionHandler: @escaping (_ success: Bool) -> Void) {
        
        let userID = Backendless.sharedInstance().userService.currentUser.objectId
        let selectedStoryID = StoryArray[row].objectId
        // 기본은 라이크가 체크되어 있지 않다
        
        let likeStore = Backendless.sharedInstance().data.of(StoryLikes.ofClass())
        
        // 여기서 쿼리는 by: userID와 to: StoryID가 match이 되어야 함
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = "by = '\(userID!)' AND to = '\(selectedStoryID!)'"
        
        likeStore?.find(dataQuery, response: { (collection) in
            let like = collection?.data as! [StoryLikes]
            
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
    
    /**
     라이크를 변경, 현재 상태를 확인하고 라이크 개수 변경
     : param: row 어떤 스토리인지 확인이 가능하고 나중에 reload를 위한 parameter
     : param: completionHandler
     */
    
    func changeLike(_ row: Int, _ nowLike: Bool, completionHandler: @escaping (_ success: Bool) -> Void) {
        
        let selectedStory = StoryArray[row]
        let storyId = selectedStory.objectId
        
        let likeStore = Backendless.sharedInstance().data.of(StoryLikes.ofClass())
        
        // 그냥 유저 객체로 비교는 안되고 objectId로 체크를 해야 함
        let objectID = Backendless.sharedInstance().userService.currentUser.objectId
        
        // 좋아요 - nowLike가 true이면 라이크 추가
        if !nowLike {
            
            // 객체 생성
            let like = StoryLikes()
            like.by = objectID! as String
            like.to = storyId
            
            likeStore?.save(like, response: { (response) in
                
                /*
                // 우선 해당 테이블 row만 refresh하자
                DispatchQueue.main.async {
                    let indexPath = IndexPath(row: row, section: 0)
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
                */
                
                // 스토리를 쓴 사람에게 Notification 날리기
                if let oneSignalId = selectedStory.writer.getProperty("OneSignalID") {
                    if let userName = UserManager.currentUser()!.getProperty("nickname") {
                        let data = ["contents" : ["en" : "\(userName) likes your Story!", "ko" : "\(userName)가 당신의 스토리를 좋아합니다"], "include_player_ids" : ["\(oneSignalId)"], "ios_badgeType" : "Increase", "ios_badgeCount" : "1"] as [String : Any]
                        OneSignal.postNotification(data)
                        
                        // 데이터베이스에 저장하기
                        // 푸쉬 객체 생성
                        let newPush = PushNotis()
                        newPush.from = objectID! as String
                        newPush.to = selectedStory.writer.objectId as String
                        newPush.type = "story"
                        newPush.typeId = storyId
                        newPush.bodyText = "\(userName)가 당신의 스토리를 좋아합니다"
                        
                        let pushStore = Backendless.sharedInstance().data.of(PushNotis.ofClass())
                        pushStore?.save(newPush, response: { (response) in
                            print("백엔드리스에 푸쉬 저장 완료")
                        }, error: { (Fault) in
                            print("푸쉬를 백엔드리스에 저장하는데 에러: \(String(describing: Fault?.description))")
                        })
                    }
                    
                }
                completionHandler(true)
                
            }, error: { (Fault) in
                print("스토리를 저장하는데 에러: \(String(describing: Fault?.description))")
                completionHandler(false)
            })
            
        } else {
            // 좋아요 취소
            
            // 먼저 storyLike에서 해당 라이크 찾기
            let dataQuery = BackendlessDataQuery()
            // 쿼리문은 by가 유저ID, to가 현재 포스트 objectId일 때
            dataQuery.whereClause = "by = '\(objectID!)' AND to = '\(storyId!)'"
            
            // 해당 스토리 라이크를 찾자
            likeStore?.find(dataQuery, response: { (collection) in
                let like = (collection?.data as! [StoryLikes]).first
                
                likeStore?.remove(like, response: { (number) in
                    /*
                    // 우선 해당 테이블 row만 refresh해보자
                    DispatchQueue.main.async(execute: {
                        let indexPath = IndexPath(row: row, section: 0)
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    })
                    */
                    completionHandler(true)
                    
                }, error: { (Fault) in
                    print("스토리를 지우는데 에러: \(String(describing: Fault?.description))")
                    completionHandler(false)
                })
                
            }, error: { (Fault) in
                print("스토리를 찾는데 에러: \(String(describing: Fault?.description))")
                completionHandler(false)
            })
        }
    }
    
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any? ) {
        if segue.identifier == "showComments" {
            let index = sender as! Int
            let destinationVC = segue.destination as! CommentViewController
            destinationVC.selectedStory = StoryArray[index]
        } else if segue.identifier == "showDetail" {
            let index = sender as! Int
            let destinationVC = segue.destination as! StoryDetailViewController
            destinationVC.selectedStory = StoryArray[index]
        }
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}

