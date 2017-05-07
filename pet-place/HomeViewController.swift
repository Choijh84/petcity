//
//  HomeViewController.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// 홈 화면 앞에 이미지 파일 돌아가는 프론트 프로모션 클래스
class FrontPromotion: NSObject {
    
    /// ID
    var objectId: String?
    /// description
    var descriptionText: String?
    /// imageURL
    var imageURL: String!
    /// linked URL 
    var url: String?
}

/// 추천하는 장소들 클래스 정의
class Recommendations: NSObject {
    
    /// ID
    var objectId: String?
    /// Reference
    var store: Store!
}

/// 홈 화면 뷰 컨트롤러, BWWalkthrough Delegate 설정 필요(워크 스루 구현을 위한)
class HomeViewController: UITableViewController, BWWalkthroughViewControllerDelegate {
    
    @IBOutlet var tableInsideHome: LoadingTableView!
    
    // 프로모션은 처음에 보이는 이미지들, 우리 뉴스나 광고를 집어넣어야 할 곳?
    var promotions = [FrontPromotion]()
    
    // 추천 장소를 모아놓는 배열
    var recommendStores = [Recommendations]()
    
    var isShowBusinessInfo = false
    var reloadIndexPath: IndexPath?
    
    @IBAction func showPushNotis(_ sender: Any) {
        performSegue(withIdentifier: "showPushNotis", sender: nil)
    }
    
    @IBAction func wantToSearch(_ sender: Any) {
        performSegue(withIdentifier: "performSearch", sender: nil)
    }
    
    override func viewDidLoad() {
        
        title = "펫시티 홈"
        
        downloadBoth()
        super.viewDidLoad()
        
        // 사용자 설정 편집
        let userDefaults = UserDefaults.standard
        
        // walkthroughPresented를 기준으로 true이면 본 것으로 설정
        if !userDefaults.bool(forKey: "walkthroughPresented") {
            showWalkThrough()
            
            userDefaults.set(true, forKey: "walkthroughPresented")
            userDefaults.synchronize()
        }
        
        // 앱 초기 애니메이션 실행, MyFirstView에서 체크
        if MyFirstViewState.isLoaded == false {
            let firstView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FirstViewController")
            self.present(firstView, animated: false, completion: nil)
        }
    }
    
    /**
     Set the navigation bar visible
     
     - parameter animated: animated
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)

    }
    
    // 워크스루 보여주는 함수
    func showWalkThrough() {
        let stb = UIStoryboard(name: "Walkthrough", bundle: nil)
        let walkthrough = stb.instantiateViewController(withIdentifier: "walk") as! BWWalkthroughViewController
        
        let page_one = stb.instantiateViewController(withIdentifier: "walkHome")
        let page_two = stb.instantiateViewController(withIdentifier: "categorySelection")
        let page_three = stb.instantiateViewController(withIdentifier: "storeList")
        let page_four = stb.instantiateViewController(withIdentifier: "storeDetail1")
        let page_five = stb.instantiateViewController(withIdentifier: "storeDetail2")
        let page_six = stb.instantiateViewController(withIdentifier: "myAccount")
        
        // 마스터 페이지에 결합
        walkthrough.delegate = self
        
        // 순서대로 붙는다
        walkthrough.add(viewController:page_one)
        walkthrough.add(viewController:page_two)
        walkthrough.add(viewController:page_three)
        walkthrough.add(viewController:page_four)
        walkthrough.add(viewController:page_five)
        walkthrough.add(viewController:page_six)
        
        // 보여주기
        self.present(walkthrough, animated: true, completion: nil)
    }
    
    
    
    // 둘 다 다운로드 받게 함
    func downloadBoth() {
        refreshControl?.beginRefreshing()
        downloadFrontPromotions()
        downloadRecommendations()
        refreshControl?.endRefreshing()
    }
    
    // MARK: - Walkthrough delegate -
    
    func walkthroughPageDidChange(_ pageNumber: Int) {
        // print("This is page: \(pageNumber)")
    }
    
    // Close Button을 누르면
    func walkthroughCloseButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     Downloads all the FrontPromotion objects
     */
    func downloadFrontPromotions() {
        self.tableInsideHome.showLoadingIndicator()
        let download = HomeDownloadManager()
        download.downloadFrontPromotions { (promotions, errorMessage) in
            DispatchQueue.main.async(execute: { 
                if let errorMessage = errorMessage {
                    let alertView = UIAlertController(title: "Error", message: errorMessage as String, preferredStyle: .alert)
                    alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    alertView.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (alertAction) in
                        self.downloadFrontPromotions()
                    }))
                    self.present(alertView, animated: true, completion: nil)
                } else {
                    if let promotions = promotions {
                        // print("promotion download done: \(promotions)")
                        self.promotions = promotions
                    }
                    self.tableInsideHome.reloadData()
                    self.tableInsideHome.hideLoadingIndicator()
                }
            })
        }
    }

    /**
     Downloads all the Recommendations objects
     */
    func downloadRecommendations() {
        self.tableInsideHome.showLoadingIndicator()
        let download = HomeDownloadManager()
        download.downloadRecommendStores { (recommends, errorMessage) in
            DispatchQueue.main.async(execute: { 
                if let errorMessage = errorMessage {
                    let alertView = UIAlertController(title: "Error", message: errorMessage as String, preferredStyle: .alert)
                    alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    alertView.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (alertAction) in
                        self.downloadRecommendations()
                    }))
                    self.present(alertView, animated: true, completion: nil)
                } else {
                    if let recommends = recommends {
                        self.recommendStores = recommends
                    }
                    self.tableInsideHome.reloadData()
                    self.tableInsideHome.hideLoadingIndicator()
                    
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /// Recommendation Places Tap Segue
        if segue.identifier == "showDetailStoreSegue" {
            if let collectionCell: StoreCollectionViewCell = sender as? StoreCollectionViewCell {
                let indexPath = collectionCell.tag
                    if let destination = segue.destination as? StoreDetailViewController {
                        destination.storeToDisplay = recommendStores[indexPath].store
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoRow", for: indexPath) as! PhotoRow
            DispatchQueue.main.async(execute: { 
                cell.photoList = self.promotions
                cell.promotionCollection.reloadData()
            })
            
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderRow", for: indexPath) as! HeaderRow
            cell.title.text = "추천 장소"
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceRow", for: indexPath) as! PlaceRow
            
            DispatchQueue.main.async(execute: { 
                cell.storeList = self.recommendStores
                cell.placeCollection.reloadData()
            })
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessInfoRow", for: indexPath) as! BusinessInfoRow
            
            reloadIndexPath = indexPath
            
            /// detail business info 보여주기/숨기기
            cell.businessInfoShowButton.addTarget(self, action: #selector(HomeViewController.showBusinessInfo), for: .touchUpInside)
            
            if isShowBusinessInfo == false {
                cell.businessInfoStack.isHidden = true
                cell.businessInfoShowButton.setTitle("사업자 정보 보기", for: .normal)
            } else {
                cell.businessInfoShowButton.setTitle("사업자 정보 숨기기", for: .normal)
                UIView.animate(withDuration: 0.3, animations: { 
                    cell.businessInfoStack.isHidden = false
                })
            }

            return cell
        }
    }
    
    func showBusinessInfo() {
        isShowBusinessInfo = !isShowBusinessInfo
         self.tableView.reloadRows(at: [reloadIndexPath!], with: .automatic)
    }
    
    /**
        Tableview Height setting function
        - parameter: tableView
        - parameter: indexPath
        row 0: 프로모션 이미지 place, row 1: 헤더, row 2: 추천 장소 콜렉션뷰 높이 계산
     */
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 250
        } else if (indexPath.row == 1) {
            return 40
        } else if (indexPath.row == 2) {
            let storeCount = recommendStores.count
            // 짝수면 180*짝수/2, 홀수면 180*(짝수/2+1)
            if storeCount%2 == 0 {
                return CGFloat(180 * storeCount/2)
            } else {
                return CGFloat(180 * ((storeCount/2)+1))
            }
        } else {
            if isShowBusinessInfo == false {
                return 150
            } else {
                return 200
            }
        }
    }
    
    /**
     Which statusbar style to display, white in this case.
     
     - returns: White statusbar.
     */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
