//
//  PushNotisTableViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 5. 3..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import Kingfisher
import SCLAlertView

class PushNotisTableViewController: UITableViewController {

    var pushArray = [PushNotis]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "알림"

        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        downloadPushArray()
        
        /*
        // 네비게이션 바에 '수정' 버튼 추가하기
        let sendBarButton = UIBarButtonItem(title: "전체 삭제", style: .plain, target: self, action: #selector(PushNotisTableViewController.allDelete))
        // sendBarButton.tintColor = UIColor.rgbColor(red: 235.0, green: 198.0, blue: 16.0)
        navigationItem.rightBarButtonItem = sendBarButton
         */
    }
    
    func allDelete() {
        pushArray.removeAll()
        tableView.reloadData()
    }
    
    func downloadPushArray() {
        pushArray.removeAll()
        
        let pushStore = Backendless.sharedInstance().data.of(PushNotis.ofClass())
        
        // let myUserId = UserManager.currentUser()?.objectId!
        let dataQuery = BackendlessDataQuery()
        // dataQuery.whereClause = "to = '\(myUserId)'"
        
        let queryOptions = QueryOptions()
        queryOptions.sortBy = ["created desc"]
        queryOptions.pageSize = 20
        queryOptions.offset = 0
        dataQuery.queryOptions = queryOptions
        
        pushStore?.find(dataQuery, response: { (collection) in
            let pushData = collection?.data as! [PushNotis]
            self.pushArray = pushData
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }, error: { (Fault) in
            print("푸쉬 읽어오는데 에러: \(String(describing: Fault?.description))")
        })
    }
    
    func downloadMorePushArray() {
        let offset = pushArray.count
        
        let pushStore = Backendless.sharedInstance().data.of(PushNotis.ofClass())
        
        // let myUserId = UserManager.currentUser()?.objectId!
        let dataQuery = BackendlessDataQuery()
        // dataQuery.whereClause = "to = '\(myUserId)'"
        
        let queryOptions = QueryOptions()
        queryOptions.sortBy = ["created desc"]
        queryOptions.pageSize = 20
        queryOptions.offset = offset as NSNumber
        dataQuery.queryOptions = queryOptions
        
        pushStore?.find(dataQuery, response: { (collection) in
            let pushData = collection?.data as! [PushNotis]
            self.pushArray = pushData
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }, error: { (Fault) in
            print("푸쉬 읽어오는데 에러: \(String(describing: Fault?.description))")
        })
    }
    
    // MARK: - Scrollview method 
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let endScrolling = scrollView.contentOffset.y + scrollView.frame.height
        if endScrolling >= (scrollView.contentSize.height*0.7) && pushArray.count >= 20 {
            self.downloadMorePushArray()
        }
    }

    // MARK: - Table view method

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pushArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PushNotisTableViewCell

        let selectedPush = pushArray[indexPath.row]
        
        // 프로필 이미지 구성
        DispatchQueue.main.async {
            let fromUserId = selectedPush.from
            let userStore = Backendless.sharedInstance().data.of(Users.ofClass())
            userStore?.findID(fromUserId, response: { (response) in
                let returnedUser = response as! BackendlessUser
                if let profileLink = returnedUser.getProperty("profileURL") {
                    let url = URL(string: profileLink as! String)
                    
                    DispatchQueue.main.async {
                        cell.profileImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imageLoadingHolder"), options: nil, progressBlock: nil, completionHandler: nil)
                    }
                    
                } else {
                    cell.profileImageView.image = #imageLiteral(resourceName: "loadingIndicator")
                }
            }, error: { (Fault) in
                print("유저 읽어오는데 에러: \(String(describing: Fault?.description))")
            })
        }
        
        // 본문 구성
        if let text = selectedPush.bodyText {
            cell.bodyText.text = text
        } else {
            cell.bodyText.text = "전달한 내용이 없습니다"
        }
        
        // 시간 구성
        let time = selectedPush.created
        let timedifference = timeDifferenceShow(date: time!)
        cell.timeLabel.text = timedifference

        // 스토리나 리뷰의 첫 사진 불러오기
        DispatchQueue.main.async {
            if selectedPush.type == "story" {
                if let storyId = selectedPush.typeId {
                    let storyStore = Backendless.sharedInstance().data.of(Story.ofClass())
                    
                    storyStore?.findID(storyId, response: { (response) in
                        let returnedStory = response as! Story
                        
                        if let photoList = (returnedStory.imageArray?.components(separatedBy: ",")) {
                            let singleImageURL = photoList[0]
                            let url = URL(string: singleImageURL)
                            
                            DispatchQueue.main.async {
                                cell.targetImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imageLoadingHolder"), options: [.processor(DefaultImageProcessor.default)], progressBlock: nil, completionHandler: nil)
                            }
                        } else {
                            cell.targetImageView.isHidden = true

                        }
                    }, error: { (Fault) in
                        print("스토리 읽어오는데 에러: \(String(describing: Fault?.description))")
                        cell.targetImageView.image = #imageLiteral(resourceName: "imageplaceholder")
                    })
                }
            } else if selectedPush.type == "review" {
                if let reviewId = selectedPush.typeId {
                    let reviewStore = Backendless.sharedInstance().data.of(Review.ofClass())
                    
                    reviewStore?.findID(reviewId, response: { (response) in
                        let returnedReview = response as! Review
                        
                        if let photoList = (returnedReview.fileURL?.components(separatedBy: ",")) {
                            let singleImageURL = photoList[0]
                            let url = URL(string: singleImageURL)
                            
                            DispatchQueue.main.async {
                                cell.targetImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imageLoadingHolder"), options: [.processor(DefaultImageProcessor.default)], progressBlock: nil, completionHandler: nil)
                            }
                        } else {
                            cell.targetImageView.isHidden = true
                            
                        }
                    }, error: { (Fault) in
                        print("스토리 읽어오는데 에러: \(String(describing: Fault?.description))")
                        cell.targetImageView.image = #imageLiteral(resourceName: "imageplaceholder")
                    })
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPush = pushArray[indexPath.row]
        
        if selectedPush.type == "story" {
            
            if let storyId = selectedPush.typeId {
                let storyStore = Backendless.sharedInstance().data.of(Story.ofClass())
                
                storyStore?.findID(storyId, response: { (response) in
                    let returnedStory = response as! Story
                    
                    let storyBoard = UIStoryboard(name: "StoryAndReview", bundle: nil)
                    let destinationVC = storyBoard.instantiateViewController(withIdentifier: "StoryDetailViewController") as! StoryDetailViewController
                    
                    destinationVC.selectedStory = returnedStory
                    
                    self.navigationController?.pushViewController(destinationVC, animated: true)
                    
                }, error: { (Fault) in
                    print("스토리 읽어오는데 에러: \(String(describing: Fault?.description))")
                    if Fault?.faultCode == "1000" {
                        SCLAlertView().showInfo("스토리를 찾을 수 없음", subTitle: "스토리가 사용자에 의해 삭제됨")
                    }
                })
            }
            
        } else if selectedPush.type == "review" {
            
            if let reviewId = selectedPush.typeId {
                let reviewStore = Backendless.sharedInstance().data.of(Review.ofClass())
                
                reviewStore?.findID(reviewId, response: { (response) in
                    let returnedReview = response as! Review
                    
                    let storyBoard = UIStoryboard(name: "Reviews", bundle: nil)
                    let destinationVC = storyBoard.instantiateViewController(withIdentifier: "ReviewDetailViewController") as! ReviewDetailViewController
                    
                    destinationVC.selectedReview = returnedReview
                    
                    self.navigationController?.pushViewController(destinationVC, animated: true)
                    
                }, error: { (Fault) in
                    print("리뷰 읽어오는데 에러: \(String(describing: Fault?.description))")
                    if Fault?.faultCode == "1000" {
                        SCLAlertView().showInfo("리뷰를 찾을 수 없음", subTitle: "리뷰가 사용자에 의해 삭제됨")
                    }
                })
            }
        }
        
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // 데이터베이스에서 삭제
            let selectedPushId = pushArray[indexPath.row].objectId!
            
            let pushStore = Backendless.sharedInstance().data.of(PushNotis.ofClass())
            pushStore?.removeID(selectedPushId, response: { (response) in
                print("삭제 완료")
                // 배열에서 제거
                self.pushArray.remove(at: indexPath.row)
                // 테이블에서 삭제
                tableView.deleteRows(at: [indexPath], with: .fade)
            }, error: { (Fault) in
                print("푸쉬 삭제하는데 에러: \(String(describing: Fault?.description))")
            })
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
