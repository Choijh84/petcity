//
//  ReviewAddViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 5. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import SCLAlertView

protocol reviewAddDelegate: class {
    // 테이블에서 선택한 스토어 객체와 함께 뷰를 변수로 넘겨줌
    // 뷰를 dismiss하고 넘겨받은 스토어를 바탕으로 리뷰를 적을 수 있음
    func dismissViewController(_ controller: UIViewController, selectedStore: Store)
    
    func placeRecommend(_ controller: UIViewController)
}

class ReviewAddViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var popupView: UIView!
    
    @IBOutlet weak var tableView: LoadingTableView!
    
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    
    // 스토어 리스트
    var objectsArray: [Store] = []
    
    var isLoadingItems: Bool = false
    
    // delegate 정의
    var delegate: reviewAddDelegate!
    
    /// Refreshcontrol to show a loading indicator and a pull to refresh view, when the view is loading content
    var refreshControl: UIRefreshControl!
    
    /// A handler object that responsible for getting the user's location
    var locationHandler: LocationHandler!
    
    /// Location download manager, that will download all the objects from the server
    let downloadManager: LocationsDownloadManager = LocationsDownloadManager()
    /// Last saved location
    var lastLocation: CLLocation?
    
    // 장소 등록하기
    @IBAction func moveToRegister(_ sender: Any) {
        self.delegate.placeRecommend(self)
    }
    
    @IBAction func tapSearchButton(_ sender: Any) {
        performSearch()
    }
    
    // 배경에 깔려있는 버튼 - dismiss
    @IBAction func dismissPopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // tableView delegate
        tableView.delegate = self
        tableView.dataSource = self
        
        // 테이블뷰 세팅
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // 텍스트필드 세팅
        searchTextField.layer.cornerRadius = 5.0
        
        // 검색 버튼 세팅
        searchButton.layer.cornerRadius = 7.5
        
        // 헤더뷰 
        headerView.layer.cornerRadius = 30.0
        
        // 팝업뷰 
        popupView.layer.cornerRadius = 10.0
        
        // FooterView
        footerView.layer.cornerRadius = 10.0
        
        // refreshControl
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .globalTintColor()
        refreshControl.addTarget(self, action: #selector(StoresListImageViewController.downloadStores), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        // 위치 파악하면서 스토어 다운로드
        startLocationTracking()
    }
    
    // 검색 함수
    func performSearch() {
        // 데이터 배열 초기화
        objectsArray.removeAll()
        // 텍스트필드에서 컨트롤 벗어나게
        searchTextField.resignFirstResponder()
        
        let dataStore = Backendless.sharedInstance().data.of(Store.ofClass())
        if let inputText = searchTextField.text {
            // 숫자인지 이름인지 체크
            if inputText.isNumber {
                // 숫자인 경우 전화번호 검색
                SCLAlertView().showNotice("검색 중입니다", subTitle: "전화 번호 확인 중")
                let phoneNumber = inputText
                
                let dataQuery = BackendlessDataQuery()
                dataQuery.whereClause = "phoneNumber LIKE \'%%\(phoneNumber)%%\'"
                
                dataStore?.find(dataQuery, response: { (collection) in
                    let storeList = collection?.data as! [Store]
                    
                    self.objectsArray = storeList
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.searchTextField.text = ""
                    }
                    
                }, error: { (Fault) in
                    print("There is an error to fetch the place by phone number: \(String(describing: Fault?.description))")
                    self.searchTextField.text = ""
                })
                
            } else {
                // 문자열인 경우 이름 검색
                let storeName = inputText
                SCLAlertView().showNotice("검색 중입니다", subTitle: "장소 이름 확인 중")
                
                let dataQuery = BackendlessDataQuery()
                dataQuery.whereClause = "name LIKE \'%%\(storeName)%%\'"
                
                dataStore?.find(dataQuery, response: { (collection) in
                    let storeList = collection?.data as! [Store]
                   
                    self.objectsArray = storeList
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.searchTextField.text = ""
                    }
                }, error: { (Fault) in
                    print("There is an error to fetch the place by name: \(String(describing: Fault?.description))")
                    self.searchTextField.text = ""
                })
            }
        } else {
            SCLAlertView().showWarning("입력 확인", subTitle: "입력해주세요")
        }
    }
    
    
    /**
     Checks to start downloading more Stores if the user scrolled down 70% of the screen and not loading anything currently
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let endScrolling = scrollView.contentOffset.y + scrollView.frame.height
        if endScrolling >= (scrollView.contentSize.height*0.7) && !isLoadingItems && objectsArray.count >= 10 {
            self.downloadMoreStores()
        }
    }
    
    /**
     Display the downloaded Store Objects
     */
    func displayStoreObjects(_ stores: [Store]?) {
        objectsArray.removeAll()
        if let stores = stores {
            objectsArray.append(contentsOf: stores)
        } else {
            objectsArray.removeAll()
        }
        
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
}

extension ReviewAddViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AddReviewShopListTableViewCell
        
        let selectedStore = objectsArray[indexPath.row]
        
        cell.storeNameLabel.text = selectedStore.name!
        
        if let serviceCategory = selectedStore.serviceCategory {
            cell.storeServiceCategory.text = serviceCategory
        } else {
            cell.storeServiceCategory.text = "작업 중"
        }
        
        cell.storeDistanceLabel.text = selectedStore.distanceString()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate.dismissViewController(self, selectedStore: objectsArray[indexPath.row])
    }
}

extension ReviewAddViewController: LocationHandlerProtocol {
    
    /**
     Start tracking the user's location
     */
    func startLocationTracking() {
        locationHandler = LocationHandler()
        locationHandler.locationHandlerProtocol = self
        locationHandler.startLocationTracking()
    }
    
    /// 로케이션 트랙킹하면서 현재 위치 파악하고 downloadStore 실행
    func locationHandlerDidUpdateLocation(_ location: CLLocation) {
        if let lastLocation = lastLocation {
            // only request new store objects when the user moved 1000 meters or more, since the last saved location
            if lastLocation.distance(from: location) > 1000 {
                downloadManager.userCoordinate = location.coordinate
                downloadStores()
            }
            self.lastLocation = location
        } else {
            downloadManager.userCoordinate = location.coordinate
            self.lastLocation = location
            downloadStores()
        }
        // 위치 계산
        calculateDistanceBetweenStoreLocationsWithLocation(location)
    }
    
    /**
     Calculates the distance between each store object and the new location
     
     :param: location the new location
     */
    func calculateDistanceBetweenStoreLocationsWithLocation(_ location: CLLocation) {
        for storeObject in objectsArray {
            storeObject.calculateDistanceBetweenCurrentLocation(location)
        }
        tableView.reloadData()
    }
    
    func downloadStores() {
        
        if lastLocation != nil {
            isLoadingItems = true
            refreshControl.beginRefreshing()
            tableView.showLoadingIndicator()
            
            downloadManager.downloadStoresWithoutCategory(skippingNumberOfObjects: 0, limit: 50, radius: 50, completionBlock: { (storeObjects, error) in
                self.isLoadingItems = false
                if let error = error {
                    SCLAlertView().showError("에러", subTitle: error)
                } else {
                    self.displayStoreObjects(storeObjects)
                    
                    if self.lastLocation != nil {
                        if let location = self.lastLocation {
                            self.calculateDistanceBetweenStoreLocationsWithLocation(location)
                        }
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
                self.tableView.hideLoadingIndicator()
            })
        }
        
    }
    
    func downloadMoreStores() {
        isLoadingItems = true
        refreshControl.beginRefreshing()
        tableView.showLoadingIndicator()
        let temp = objectsArray.count as NSNumber
        
        downloadManager.downloadStoresWithoutCategory(skippingNumberOfObjects: temp, limit: 50, radius: 50) { (storeObjects, error) in
            if let error = error {
                SCLAlertView().showError("에러", subTitle: error)
            } else {
                if let storeObjects = storeObjects {
                    self.objectsArray.append(contentsOf: storeObjects)
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
                if let location = self.lastLocation {
                    self.calculateDistanceBetweenStoreLocationsWithLocation(location)
                }
            }
            self.isLoadingItems = false
            self.refreshControl.endRefreshing()
            self.tableView.hideLoadingIndicator()
        }
    }

}
