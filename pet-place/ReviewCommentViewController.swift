//
//  ReviewCommentViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 4. 3..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import SCLAlertView

class ReviewCommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CommentTableViewCellProtocol  {

    // 어떤 리뷰인지 ReviewVC로부터 받아옴
    var selectedReview = Review()
    
    var commentArray = [ReviewComment]()
    
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var tableView: LoadingTableView!    
    
    /// 코멘트 저장
    @IBAction func saveComment(_ sender: Any) {
        print("Let us save the comment")
        if let text = commentTextField.text {
            ReviewManager().uploadNewCommment(text, selectedReview, completionBlock: { (success, error) in
                if success {
                    self.commentTextField.resignFirstResponder()
                    self.commentTextField.text = ""
                    self.setUpCommentArray()
                    
                    // Notification 활용해서 코멘트 달린걸 알림
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "reviewCommentChanged"), object: nil)
                } else {
                    SCLAlertView().showWarning("에러 발생", subTitle: "확인해주세요")
                }
            })
        } else {
            SCLAlertView().showWarning("입력 필요", subTitle: "코멘트를 입력해주세요")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "코멘트"
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        // height setting
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // tableView 아래 빈 셀들 separator 줄 안 보이게
        customizeViews()
        
        // 댓글 데이터 받아오기
        setUpCommentArray()
        
        // Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReviewCommentViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    func setUpCommentArray() {
        tableView.showLoadingIndicator()
        commentArray.removeAll()
        
        // ReviewCommentdㅔ서 받아오기
        let reviewId = selectedReview.objectId!
        
        let dataStore = Backendless.sharedInstance().data.of(ReviewComment.ofClass())
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = "to = '\(reviewId)'"
        
        dataStore?.find(dataQuery, response: { (collection) in
            let comments = collection?.data as! [ReviewComment]
            self.commentArray = comments
            
            self.tableView.reloadData()
            self.tableView.hideLoadingIndicator()
            
        }, error: { (Fault) in
            print("서버에서 댓글 얻어오기 실패: \(String(describing: Fault?.description))")
            self.tableView.hideLoadingIndicator()
        })
    }
    
    /**
     Customize the tableview's look and feel
     */
    func customizeViews() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorColor = .separatorLineColor()
    }
    
    /// MARK: CommentTableViewCellProtocol
    func actionTapped(row: Int) {
        
        // 데이터베이스에서도 삭제
        let selectedCommentId = commentArray[row].objectId
        // 뷰에서 삭제
        commentArray.remove(at: row)
        tableView.reloadData()
        
        let dataStore = Backendless.sharedInstance().data.of(ReviewComment.ofClass())
        dataStore?.removeID(selectedCommentId, response: { (success) in
            print("댓글이 삭제되었습니다")
        }, error: { (Fault) in
            print("Server reported an error to delete Review Comment: \(String(describing: Fault?.description))")
        })
        
    }
    
    /// Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    /// MARK: - TableView Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CommentTableViewCell
        
        // 프로토콜 delegate 설정
        cell.delegate = self
        
        let comment = commentArray[indexPath.row]
        
        // 코멘트 by 유저 찾아오기 
        let userID = comment.by
        let userStore = Backendless.sharedInstance().data.of(Users.ofClass())
        
        // 유저 찾은 이후 프로필 이미지와 이름 붙이기
        userStore?.findID(userID, response: { (returnUser) in
            let user = returnUser as! BackendlessUser
            
            // Profile 이미지 읽어오기
            if let profile = user.getProperty("profileURL") as? String {
                let url = URL(string: profile)
                DispatchQueue.main.async(execute: {
                    cell.profileImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
                })
            } else {
                cell.profileImage.image = #imageLiteral(resourceName: "user_profile")
            }
            // 이름 붙이기
            cell.nameLabel.text = user.name! as String?
            
        }, error: { (Fault) in
            print("유저 못 찾음: \(String(describing: Fault?.description))")
        })
        
        // comment
        cell.commentLabel.text = comment.bodyText
        
        // 시간은 그냥 작성된 시간 기준으로 - 편집 기능은 없앨 수도....
        let time = comment.created
        print("This is created time: \(String(describing: time))")
        let timedifference = timeDifferenceShow(date: time!)
        cell.timeLabel.text = timedifference
        
        // 편집, 삭제 버튼에 tag 부여하기
        cell.editButton.tag = indexPath.row
        cell.deleteButton.tag = indexPath.row
        
        // 편집 및 삭제 버튼, 아이디가 일치하면 보여주기
        if userID != String(Backendless.sharedInstance().userService.currentUser.objectId) {
            cell.editButton.isHidden = false
            cell.deleteButton.isHidden = false
        }
        
        // likeButton - 생략, 아직 구현 안함
        cell.likeButton.isHidden = true
        
        return cell
    }
    
    // 테이블 각 row의 높이 자동 조절을 위한 함수 2개
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // 타임 포맷 함수
    func timeDifferenceShow(date: Date) -> String {
        
        // 현재 시각
        let date1:Date = Date()
        // 결과 전달을 위한 문자열 생성
        var returnString:String = ""
        
        // 디바이스에 있는 캘린더를 도입
        let calender:Calendar = Calendar.current
        // 시간 차이 계산 to-from
        let components: DateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: date1)
        
        print(components)
        print(components.second ?? "There is no value")
        
        if components.year! >= 1 {
            returnString = String(describing: components.year!)+" 년 전"
        } else if components.month! >= 1 {
            returnString = String(describing: components.month!)+" 달 전"
        } else if components.day! >= 1 {
            returnString = String(describing: components.day!) + " 일 전"
        } else if components.hour! >= 1 {
            returnString = String(describing: components.hour!) + " 시간 전"
        } else if components.minute! >= 1 {
            returnString = String(describing: components.minute!) + " 분 전"
        } else {
            returnString = "방금 올림"
        }
        return returnString
    }
}
