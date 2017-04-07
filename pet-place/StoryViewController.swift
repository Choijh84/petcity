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

class StoryViewController: UIViewController, IndicatorInfoProvider, UITableViewDataSource, UITableViewDelegate, StoryTableViewCellProtocol {
    
    var StoryArray: [Story] = []
    var isMyStory = false
    
    var itemInfo: IndicatorInfo = "스토리"
    
    @IBOutlet weak var tableView: LoadingTableView!
    
    /// 내리고 있던 스토리의 위치를 기억함
    var verticalContentOffset: CGFloat = 0
    
    /// 스토리를 다운로드하고 있으면 true
    var isLoadingItems: Bool = false
    
    /// Lazy getter for the dateformatter that formats the date property of each review to the desired format
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter
    }()
    
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
        //fatalError("init(coder:) has not been implemented")
    }
    
    // 처음에 메모리에 뷰가 없을 때에만 보여주는 함수
    override func viewDidLoad() {
        
        // height setting 
        tableView.estimatedRowHeight = 320
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let user = Backendless.sharedInstance().userService.currentUser
        
        // 유저 로그인이 안 되어있으면 로그인으로 이동
        if user == nil {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("로그인으로 이동") {
                self.presentLoginViewController()
            }
            alertView.showInfo("로그인 필요", subTitle: "로그인해주세요!")
        } else {
            
            customizeViews()
            super.viewDidLoad()
            
        }
    }
    
    // 뷰가 보일 때마다 불러오는 함수
    override func viewWillAppear(_ animated: Bool) {
        
        let user = Backendless.sharedInstance().userService.currentUser
        
        // 유저 로그인이 안 되어있으면 로그인으로 이동
        if user == nil {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("로그인으로 이동") {
                self.presentLoginViewController()
            }
            alertView.showInfo("로그인 필요", subTitle: "로그인해주세요!")
        } else {
            // 내 스토리인 경우에는 다운로드 안함
            if isMyStory {
                // tableView.reloadData()
                self.tableView.hideLoadingIndicator()
                title = "내 스토리"
            } else {
                downloadStory()
                tableView.reloadData()
                // 기억하고 있던 자리로 이동
                tableView.setContentOffset(CGPoint(x: 0, y: verticalContentOffset), animated: false)
            }
        }
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
            dismiss(animated: true, completion: nil)
        }
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
        
        StoryDownloadManager().downloadStoryByPage(skippingNumberOfObjects: 0, limit: 10, user: nil) { (stories, error) in
            self.isLoadingItems = false
            if let error = error {
                self.showAlertViewWithRedownloadOption(error)
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
    
    func downloadMoreStory() {
        isLoadingItems = true
        tableView.showLoadingIndicator()
        
        // 이미 다운로드 받은 스토리의 수
        let temp = StoryArray.count as NSNumber
        print("This is temp: \(temp)")
        
        StoryDownloadManager().downloadStoryByPage(skippingNumberOfObjects: temp, limit: 10, user: nil) { (stories, error) in
            self.isLoadingItems = false
            if let error = error {
                self.showAlertViewWithRedownloadOption(error)
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
    
    /**
     사용자가 스크롤을 70% 이상 내리면 추가로 리뷰를 다운로드 - downloadMoreStory
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let endScrolling = scrollView.contentOffset.y + scrollView.frame.height
        if endScrolling >= (scrollView.contentSize.height*0.7) && !isLoadingItems && StoryArray.count >= 10 {
            self.downloadMoreStory()
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
            self.downloadStory()
        }
        alert.showError("에러 발생", subTitle: "다운로드에 문제가 있습니다")
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
        story.commentNumbers = story.comments.count
        // 프로토콜 delegate 설정
        cell.delegate = self
        
        // tag 설정 
        // 프로필 이름 및 이미지 - 태그 0 
        // 라이크 버튼 - 태그 1, 코멘트 버튼 - 태그 2, 공유 버튼 - 태그 3
        // 라이크 개수 - 태그 4, 코멘트 개수 - 태그 5
        // indexPath.row + 태그 숫자로 숫자를 조합 0,1,2,3,4,5 / 10,11,12,13,14,15 / 20,21,22,23,24,25 등
        
        cell.nicknameLabel.tag = (indexPath.row*10)+0
        cell.profileImageView.tag = (indexPath.row*10)+0
        
        cell.likeButton.tag = (indexPath.row*10)+01
        cell.commentButton.tag = (indexPath.row*10)+02
        cell.shareButton.tag = (indexPath.row*10)+03
        cell.likeNumberLabel.tag = (indexPath.row*10)+04
        cell.commentNumberLabel.tag = (indexPath.row*10)+05
        cell.imageCollection.tag = (indexPath.row*10)+06
        cell.moreButton.tag = (indexPath.row*10)+07
        
        // 프로필 이미지랑 닉네임 설정
        if let user = story.writer {
            let nickname = user.getProperty("nickname") as! String
            cell.nicknameLabel.text = nickname
            
            if let profileURL = user.getProperty("profileURL") {
                if profileURL is NSNull {
                    cell.profileImageView.image = #imageLiteral(resourceName: "user_profile")
                } else {
                    let url = URL(string: profileURL as! String)
                    cell.profileImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imageplaceholder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
                }
            }
        } else {
            //  삭제된 유저의 경우
            cell.nicknameLabel.text = "탈퇴 유저"
            cell.profileImageView.image = #imageLiteral(resourceName: "user_profile")
        }
        
        // 라이크버튼 설정
        DispatchQueue.main.async { 
            self.checkLike(indexPath.row) { (success) in
                if success {
                    // 어떤 스토리를 좋아했다면
                    cell.likeButton.setImage(#imageLiteral(resourceName: "like_red"), for: .normal)
                    
                } else {
                    // 좋아했던 스토리가 아니라면
                    cell.likeButton.setImage(#imageLiteral(resourceName: "like_bw"), for: .normal)
                }
            }
        }
        
        cell.bodyTextLabel.text = story.bodyText
        cell.likeNumberLabel.text = String(story.likeNumbers) + "개의 좋아요"
        cell.commentNumberLabel.text = String(story.commentNumbers) + "개의 리플"
        
        cell.photoList = (story.imageArray?.components(separatedBy: ",").sorted())!
        
        cell.timeLabel.text = dateFormatter.string(from: story.created! as Date)
        
        // 향후 스크롤링하면서 데이터가 부정확해지기 때문에 꼭 reload를 해줘야 함
        cell.imageCollection.reloadData()
        
        return cell
    }
    
    // MARK: - Interation Handling
    // 프로필 이름 및 이미지 - 태그 0
    // 라이크 버튼 - 태그 1, 코멘트 버튼 - 태그 2, 공유 버튼 - 태그 3
    // 라이크 개수 - 태그 4, 코멘트 개수 - 태그 5
    // 사진 - 태그 6
    // moreButton - 태그 7 (신고)
    // indexPath.row + 태그 숫자로 숫자를 조합, 10으로 나눈 숫자가 indexPath.row / 나머지가 태그
    
    func actionTapped(tag: Int) {
        let row = tag/10
        let realTag = tag%10
        
        switch realTag {
            case 0:
                print("Move to Profile View")
            case 1:
                print("Like Button Clicked")
                // 라이크 변경 함수 콜 - changeLike
                changeLike(row, completionHandler: { (success) in
                    if success {
                        self.tableView.reloadData()
                    } else {
                        print("Like Change has failed")
                    }
                })
            case 2:
                print("Comment Button Clicked")
                // 코멘트 액션
                performSegue(withIdentifier: "showComments", sender: row)
                verticalContentOffset = tableView.contentOffset.y
            case 3:
                print("Share Button Clicked")
                // 공유 액션
                self.shareButtonPressed(row)
            case 4:
                print("Show Like Users: \(row)")
                // 좋아하는 유저들 보여주기
            case 5:
                print("Show Comments: \(row)")
                performSegue(withIdentifier: "showComments", sender: row)
                verticalContentOffset = tableView.contentOffset.y
            case 6:
                print("Show Photos: \(row)")
                self.showPhoto(row)
            case 7:
                print("Show Report: \(row)")
                self.sendEmail(row)
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
        var isLike = false
        
        let dataStore = Backendless.sharedInstance().data.of(Story.ofClass())
        dataStore?.findID(selectedStoryID, response: { (response) in
            let selectedStory = response as! Story
            let likeUsers = selectedStory.likeUsers
            
            for likeUser in likeUsers {
                if likeUser.objectId == userID {
                    isLike = true
                    completionHandler(isLike)
                }
            }
            completionHandler(isLike)
            
        }, error: { (Fault) in
            print("Server reported an error: \(String(describing: Fault?.description))")
        })
    }
    
    /** 
       라이크를 변경, 현재 상태를 확인하고 라이크 개수 변경
     : param: row 어떤 스토리인지 확인이 가능하고 나중에 reload를 위한 parameter
     : param: completionHandler
    */

    func changeLike(_ row: Int, completionHandler: @escaping (_ success: Bool) -> Void) {
        print("Change like")
        let selectedStory = StoryArray[row]
        
        let likeNumber = selectedStory.likeNumbers
        
        // 그냥 유저 객체로 비교는 안되고 objectId로 체크를 해야 함
        let objectID = Backendless.sharedInstance().userService.currentUser.objectId
        
        let dataStore = Backendless.sharedInstance().data.of(Story.ofClass())
        
        checkLike(row) { (success) in
            if success {        // 좋아요를 이미 누른 경우 - 취소가 됨
                selectedStory.likeNumbers = likeNumber-1
                
                for (index, _) in selectedStory.likeUsers.enumerated() {
                    if selectedStory.likeUsers[index].objectId == objectID {
                        selectedStory.likeUsers.remove(at: index)
                        break
                    }
                }
                
                dataStore?.save(selectedStory, response: { (response) in
                    let story = response as! Story
                    print("Successfully like deleted: \(story.likeNumbers)")
                    completionHandler(true)
                }, error: { (Fault) in
                    print("Server reported an error on update Like: \(String(describing: Fault?.description))")
                    completionHandler(false)
                })
                
            } else {            // 아직 좋아요를 누르지 않은 경우 - 좋아요가 추가가 됨
                selectedStory.likeNumbers = likeNumber+1
                selectedStory.likeUsers.append(Backendless.sharedInstance().userService.currentUser)
                
                dataStore?.save(selectedStory, response: { (response) in
                    let story = response as! Story
                    print("Successfully like added: \(story.likeNumbers)")
                    completionHandler(true)
                }, error: { (Fault) in
                    print("Server reported an error on update Like: \(String(describing: Fault?.description))")
                    completionHandler(false)
                })
            }
        }
    }
    
    // 신고 이메일 현재 수신인: ourpro.choi@gmail.com
    func sendEmail(_ row: Int) {
        let userEmail = Backendless.sharedInstance().userService.currentUser.email
        let selectedStory = StoryArray[row]
        
        let subject = "스토리 게시물 신고 이메일"
        let body = "신고 사용자: \(userEmail!).\n 신고한 게시물은 이 게시물입니다. ID: \(String(describing: selectedStory.objectId!))"
        let recipient = "ourpro.choi@gmail.com"
        Backendless.sharedInstance().messagingService.sendHTMLEmail(subject, body: body, to: [recipient], response: { (response) in
            SCLAlertView().showSuccess("신고 완료", subTitle: "제출되었습니다")
        }) { (Fault) in
            print("Server reported an error: \(String(describing: Fault?.description))")
        }
    }
    
    /// 공유를 위한 함수
    func shareButtonPressed(_ row: Int) {
        let selectedStory = StoryArray[row]
        
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
            let index = sender as! Int
            let destinationVC = segue.destination as! CommentViewController
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
