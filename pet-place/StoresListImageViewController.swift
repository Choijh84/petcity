//
//  StoresListImageViewController.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 3..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import SCLAlertView

class StoresListImageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LocationHandlerProtocol {

    /// Our list view
    @IBOutlet weak var tableView: LoadingTableView!
    
    /// selected Store Category(Type) from the StoreCategory VC
    var selectedStoreType : StoreCategory!
    
    /// Objects that needs to be displayed
    var objectsArray: [Store] = []
    
    /// Refreshcontrol to show a loading indicator and a pull to refresh view, when the view is loading content
    var refreshControl: UIRefreshControl!
    
    /// A handler object that responsible for getting the user's location
    var locationHandler: LocationHandler!
    
    /// Location download manager, that will download all the objects from the server
    let downloadManager: LocationsDownloadManager = LocationsDownloadManager()
    
    /// Last saved location
    var lastLocation: CLLocation?
    /// User Picked the location
    var pickedLocation: CLLocation?
    /// Variable to check whether user picked a location or not
    var isConfirmedLocation = false
    var isDownloaded = false
    
    /// The selected category from StoresCategoryView
    var selectedStoreCategory: StoreCategory!
    /// Array to hold all the downloaded categories
    var allStoreCategories: [StoreCategory] = []
    
    /// True, if we currently loading new stores
    var isLoadingItems: Bool = false
    
    /// 검색 반경 설정 변수
    var searchRadius : Int = 0
    
    // 검색 결과가 없을 때 보여주는 뷰
    @IBOutlet weak var noResultView: UIView!
    
    
    /// View which contains filter
    @IBOutlet weak var filterView: UIView!
    /// Label which shows Filter condition
    @IBOutlet weak var filterConditionLabel: UILabel!
    
    @IBAction func moveToRecommend(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Account", bundle: nil)
        let destinationVC = storyBoard.instantiateViewController(withIdentifier: "PlaceRegisterViewController") as! PlaceRegisterViewController
        
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    /**
     Called after the view has been loaded. Customise the view and download the store objects
     */
    
    override func viewDidLoad() {
        title = NSLocalizedString(selectedStoreType.name!, comment: "")
        
        // 결과가 없을 때 보여주는 뷰는 우선 숨김
        noResultView.layer.cornerRadius = 7.5
        noResultView.isHidden = true
        
        super.viewDidLoad()
        findStoreCategoryByName()
        customizeViews()
        customizeFilterView()
        startLocationTracking()
        
        tableView.showLoadingIndicator()
    }
    
    /**
        from the selectedStoreType(Store type), query the StoreCategory table and matches the object
     */
    
    func findStoreCategoryByName() {
        
        if selectedStoreType != nil {
            
            let whereClause = "name LIKE '%%\(selectedStoreType.name!)'"
            let dataQuery = BackendlessDataQuery()
            dataQuery.whereClause = whereClause
            
            let dataStore = Backendless.sharedInstance().data.of(StoreCategory.ofClass())
            
            let bc = dataStore?.find(dataQuery)
            selectedStoreCategory = (bc?.data as! [StoreCategory]).first
            
            /*
            dataStore?.find(dataQuery, response: { (collection) in
                self.selectedStoreCategory = (collection!.data as! [StoreCategory]).first
            }, error: { (error) in
                print("Server reported an error: \(String(describing: error?.description))")
            })
            */
            
        } else {
            print("Error: The Category has not fixed")
        }
    }
    
    /**
     Called when user applies a filter from the FilterViewController
     사용자가 필터를 적용하고 나서 뷰가 돌아올 때 적용하는 unwind 함수
     쿼리에 적용할 petType과 petSize에 대한 정보를 받아서 입력
     
     :param: segue apply the selected sorting option and download the Store objects again.
     */
    @IBAction func unwindFromFilterViewVC(_ segue: UIStoryboardSegue) {
        /// let filterViewVC = segue.source as! FilterViewController
        
        if let petType = GlobalVar.filter1 {
            downloadManager.selectedPetType = " AND serviceablePet LIKE '%\(petType)%'"
        } else {
            downloadManager.selectedPetType = ""
        }
        if let petSize = GlobalVar.filter2 {
            downloadManager.selectedPetSize = " AND petSize LIKE '%\(petSize)%'"
        } else {
            downloadManager.selectedPetSize = ""
        }
        if let searchRadius = GlobalVar.filter3 {
            print("검색반경: \(searchRadius)")
            let radius = searchRadius.replacingOccurrences(of: "km", with: "")
            if let radiusInt = Int(radius) {
                downloadManager.searchRadius = radiusInt
                self.searchRadius = radiusInt
            }
        } else {
            print("이게 모냥")
        }
        /**
        if let petType = filterViewVC.selectedSortingOption1?.name {
            SortingPetType = petType
            downloadManager.selectedPetType = " AND serviceablePet LIKE '\(SortingPetType!)%'"
        }
        if let petSize = filterViewVC.selectedSortingOption2?.name {
            SortingPetSize = petSize
            downloadManager.selectedPetSize = " AND petSize LIKE '\(SortingPetSize!)%'"
        }
        */
        downloadStores()
    }
    
    /**
     Customize View which shows Filter
    */
    func customizeFilterView() {
        if GlobalVar.filter1 == nil && GlobalVar.filter2 == nil && GlobalVar.filter3 == nil {
            filterView.isHidden = true
        } else {
            UIView.animate(withDuration: 0.3, animations: { 
                self.filterView.isHidden = false
            })
            configureFilterInfo()
        }
    }
    
    func configureFilterInfo() {
        var text = ""
        if let petType = GlobalVar.filter1 {
            text = text.appending(" 가능 반려동물: \(petType)")
        }
        if let petSize = GlobalVar.filter2 {
            text = text.appending(" 가능 크기: \(petSize)")
        }
        if let radius = GlobalVar.filter3 {
            text = text.appending(" 검색 반경: \(radius)")
        }
        filterConditionLabel.text = text
    }
    
    /**
     Keep the navigation bar hidden, we don't need it
     
     - parameter animated: animated
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customizeFilterView()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /**
     Start tracking the user's location
     */
    func startLocationTracking() {
        locationHandler = LocationHandler()
        locationHandler.locationHandlerProtocol = self
        locationHandler.startLocationTracking()
    }
    /**
     Customize the tableview's look and feel
     */
    func customizeViews() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorColor = .separatorLineColor()
        self.tabBarController?.tabBar.isTranslucent = false
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .globalTintColor()
        refreshControl.addTarget(self, action: #selector(StoresListImageViewController.downloadStores), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    /**
    스토어 객체를 다운도르 시키는 함수
    */
    func downloadStores() {
        if lastLocation != nil || isConfirmedLocation == true {
            isLoadingItems = true
            refreshControl.beginRefreshing()
            
            // Store Category assignmenet
            downloadManager.selectedStoreCategory = selectedStoreCategory
            // 검색 반경 확인 - 기본 20킬로
            var radius : NSNumber = 20
            if searchRadius != 0 {
                radius = NSNumber(integerLiteral: searchRadius)
            }
            // print("This is searchRadius: \(searchRadius)")
            
            downloadManager.downloadStores(skippingNumberOfObjects: 0, limit: 50, selectedStoreCategory: selectedStoreCategory, radius: radius, completionBlock: { (storeObjects, error) in
                self.isLoadingItems = false
                if let error = error { 
                    self.showAlertViewWithRedownloadOption(error)
                } else {
                    self.displayStoreObjects(storeObjects)
                    if self.lastLocation != nil {
                        if let location = self.lastLocation {
                            self.calculateDistanceBetweenStoreLocationsWithLocation(location)
                        }
                    } else {
                        self.calculateDistanceBetweenStoreLocationsWithLocation(self.pickedLocation!)
                    }
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
                self.tableView.hideLoadingIndicator()
            })
        }
    }
    
    /**
    스크롤을 70% 이상 내리면 발동되는 스토어 객체 추가 다운로드 함수
    */
    func downloadMoreStores() {
        isLoadingItems = true
        refreshControl.beginRefreshing()
        let temp = objectsArray.count as NSNumber
        // 검색 반경 확인 - 기본 20킬로
        var radius : NSNumber = 20
        if searchRadius != 0 {
            radius = NSNumber(integerLiteral: searchRadius)
        }
        
        downloadManager.downloadStores(skippingNumberOfObjects: temp, limit: 50, selectedStoreCategory: selectedStoreCategory, radius: radius) { (storeObjects, error) in
            if let error = error {
                self.showAlertViewWithRedownloadOption(error)
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
            if stores.count == 0 {
                self.noResultView.isHidden = false
            }
        } else {
            objectsArray.removeAll()
        }
        
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    /**
     Shows an alertView and offers an option to redownload the stores again
     
     :param: error error to display
     */
    func showAlertViewWithRedownloadOption(_ error: String) {
        let alert = SCLAlertView()
        alert.addButton("확인") { 
            print("확인 완료")
        }
        alert.addButton("다시 시도") { 
            self.downloadStores()
        }
        alert.showError("에러 발생", subTitle: "다운로드에 문제가 있습니다")
    }
    
    // MARK: location handler protocol methods
    /**
     Called when the location handler got a new location information, update the mapView and recalculate the distance between the user and the stores
     
     :param: location the new location
     */
    func locationHandlerDidUpdateLocation(_ location: CLLocation) {
        // User가 location을 정하지 않은 경우, GPS가 잡는 경우
        if isConfirmedLocation == false {
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
            
            calculateDistanceBetweenStoreLocationsWithLocation(location)
            // updateTopbarTitleLabelWithLocation(location)
        } else {
            // User가 location을 확정한 경우, 1번만 실행
            if isDownloaded == false {
                downloadManager.userCoordinate = pickedLocation?.coordinate
                downloadStores()
                
                calculateDistanceBetweenStoreLocationsWithLocation(pickedLocation!)
                isDownloaded = true
            }
        }
    }
    
    /**
     Updated the title of the view with geocoded name of your location. E.g.: New York, USA. If geocodeing fails, it will use the title of the view: Stores nearby
     
     - parameter location: the location to geocode
     */
    func updateTopbarTitleLabelWithLocation(_ location: CLLocation) {
        locationHandler.geocodeLocation(location) { (geocodedName, placeMark, error) -> () in
            if let geocodedName = geocodedName {
                self.navigationItem.title = geocodedName
            } else {
                self.navigationItem.title = self.title
            }
        }
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
    
    /// Mark: TableView methods
    /**
     Asks the delegate for the height to use for a row in a specified location.
     
     :param: tableView The table-view object requesting this information.
     :param: indexPath An index path that locates a row in tableView.
     
     :return: CGFloat height of the row at the indexPath
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160.0
    }
    
    /**
     Tells the data source to return the number of rows in a given section of a table view
     
     :param: tableView  The table-view object requesting this information.
     :param: section    An index number identifying a section in tableView.
     
     :return: NSInteger number of rows
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectsArray.count
    }
    
    /**
     Asks the data source for a cell to insert in a particular location of the table view.
     
     :param: tableView A table-view object requesting the cell.
     :param: indexPath An index path locating a row in tableView.
     
     :return: UITableViewCell cell to use at the indexPath
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let storeCell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath) as! StoreListImageTableViewCell
        
        let storeObject = objectsArray[indexPath.row]
        storeCell.nameLabel.text = storeObject.name
        storeCell.locationLabel.text = storeObject.address
        storeCell.distanceLabel.text = storeObject.distanceString()
        // 조회수, 평점 보여주기
        let hits = storeObject.hits
        // print("This is review average:\(storeObject.reviewAverage)")
        if storeObject.reviewCount != 0 {
            // let reviewAverage = String(format: "%.1f", storeObject.reviewAverage)
            let text = "조회수: \(hits) | 리뷰개수: \(storeObject.reviewCount)"
            storeCell.categoriesLabel.text = text
        } else {
            let text = "조회수: \(hits)"
            storeCell.categoriesLabel.text = text
        }
        
        // 인증 마크 보여주기 설정, 인증이 false이면 인증 마크를 숨긴다
        if storeObject.isVerified == false {
            storeCell.verifiedMark.isHidden = true
        }
        
        // 장소의 이미지 불러오기
        if let imageURL = storeObject.imageURL {
            storeCell.storeImageView.hnk_setImage(from: URL(string: imageURL))
            
        }
        return storeCell
    }
    
    /**
     Combine the String in the storeObject.
     : parameter:   StoreCategory Array in the store object
     : return   :   concatenated String
     */
    func combineString(inputArray: Array<StoreCategory>) -> String {
        var combined: [String] = []
        
        for i in 0 ..< inputArray.count {
            combined.append(inputArray[i].name!)
        }
        
        let result = combined.joined(separator: ",")
        print("This is concatenated String: \(result)")
        return result
        
    }
    
    /**
     Tells the delegate that the specified row is now selected. Just deselect it, selection will be covered by segues.
     
     :param: tableView A table-view object informing the delegate about the new row selection.
     :param: indexPath An index path locating the new selected row in tableView.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    /**
     Called when the segue is about to be performed. Get the storyObject that is connected with the cell, and assign it to the destination viewController.
     
     :param: segue  The segue object containing information about the view controllers involved in the segue.
     :param: sender The object that initiated the segue.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailView" {
            let detailViewController = segue.destination as! StoreDetailViewController
            
            if let sender = sender {
                if ((sender as AnyObject) is IndexPath) {
                    let indexPath: IndexPath = sender as! IndexPath
                    detailViewController.storeToDisplay = objectsArray[indexPath.row]
                } else if ((sender as AnyObject) is Store) {
                    detailViewController.storeToDisplay = sender as! Store
                } else if ((sender as AnyObject) is StoreListImageTableViewCell) {
                    let cell = sender as! StoreListImageTableViewCell
                    let indexPath = tableView.indexPath(for: cell)
                    detailViewController.storeToDisplay = objectsArray[indexPath!.row]
                }
                detailViewController.hidesBottomBarWhenPushed = true
            }
        } else if segue.identifier == "showMapView" {
            let destinationVC = segue.destination as! StoreMapViewController
            destinationVC.selectedStoreType = selectedStoreCategory
            destinationVC.lastLocation = pickedLocation
            destinationVC.isConfirmedLocation = isConfirmedLocation
        } else if segue.identifier == "showFilterView" {
            let destinationVC = segue.destination as! FilterViewController
            destinationVC.selectedCategory = selectedStoreCategory
        }
    }
    
    /**
     Returns the preferred statusbar style, this case Light(White)
     
     :returns: the statusbar style (White)
     */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
