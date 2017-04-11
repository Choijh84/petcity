//
//  StoreDetailViewController.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 4..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import MapKit
import HCSStarRatingView
import MessageUI
import SCLAlertView
import SKPhotoBrowser
import Kingfisher

class StoreDetailViewController: UIViewController, SFSafariViewControllerDelegate {

    /// Datasource object that is responsible for managing data for the tableView
    var dataSource: StoreDetailViewDatasource!
    
    /// TableView that displays all the different sections and rows to be displayed
    @IBOutlet var tableView: UITableView!
    /// To show the store's image
    @IBOutlet var storeImageView: LoadingImageView!
    /// To show the name
    @IBOutlet var storeNameLabel: UILabel!
    /// to show the detail text
    @IBOutlet var storeSubtitleLabel: UILabel!
    /// To show the rating of the store
    @IBOutlet var storeRatingView: HCSStarRatingView!
    /// TO show the number of rating and average rating value
    @IBOutlet var storeRatingLabel: UILabel!
    /// Custom navigation bar view that displayed on top of the view, gets adjusted when tableview is scrolled
    @IBOutlet var customNavigationBarView: GradientHeaderView!
    /// Back Button 
    @IBOutlet var backButton: UIButton!
    /// Favorite Button
    @IBOutlet weak var isFavorite: UIButton!
    /// Boolean value for the store to check in the user's favorite list
    var isFavorited = false
    
    /// the store object we want to display
    var storeToDisplay: Store!
    /// 사진 브라우징을 위한 asset array 
    var SKimageArray = [SKPhoto]()
    
    /// Manager that downloads the reviews for the selected Store
    let reviewManager: ReviewManager = ReviewManager()
    /// Array of downloaded Reviews
    var downloadedReviews: [Review] = []
    /// Section to display the reviews
    var reviewsSection: StoreDetailSectionDatasource<ReviewTableViewCell>!
    
    /// Section that displays the "Read more reviews" or "Leave a review" button
    var reviewButtonSection: StoreDetailSectionDatasource<ReviewOptionsTableViewCell>!
    
    /// Section to display the Reviews headerView (which in our case is a simple Cell).
    var reviewSectionHeaderRow: StoreDetailRowDatasource<UITableViewCell>! = nil
    
    /// Total number of review
    var numberOfReviews = 0
    
    /// The default headerView height
    fileprivate let kTableHeaderHeight: CGFloat = 240
    /// Headerview reference to be able to create the stretchy headerView effect
    var headerView: UIView!
    /// Expandable Bolean
    var isExpanded: Bool = false
    /// Detail Info Button Expand or Collapse
    var detailInfoButton: StoreDetailSectionDatasource<ReviewOptionsTableViewCell>!
    
    /// Lazy getter for the dateformatter that formats the date property of each review to the desired format
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    /// Dismisses the view when the back button is pressed
    @IBAction func backButtonPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    /// 공유를 위한 함수
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        let storeName = storeToDisplay.name!
        // let storeWebsite = storeToDisplay.address
        if let imageUrl = storeToDisplay.imageURL {
            let activityViewController = UIActivityViewController(shareText: "펫시티 앱을 다운받으시고 이 장소를 같이 확인해보세요! ", storeName: storeName, imageUrl: imageUrl)
            let vc = self.parent
            vc?.present(activityViewController, animated: true, completion: nil)
        } else {
            let activityViewController = UIActivityViewController(shareText: "펫시티 앱을 다운받으시고 이 장소를 같이 확인해보세요! ", storeName: storeName, imageUrl: nil)
            let vc = self.parent
            vc?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    /// Check the Favorite button pressed
    @IBAction func isFavoritButtonPressed(_ sender: Any) {
        let user = UserManager.currentUser()
        print(storeToDisplay.favoriteList)
        
        let dataStore = Backendless.sharedInstance().data.of(Store.ofClass())
        
        if isFavorited == false {
            let randomNum : UInt32 = arc4random_uniform(2)
            if randomNum == 0 {
                isFavorite.setImage(#imageLiteral(resourceName: "redHeart"), for: .normal)
            } else {
                isFavorite.setImage(#imageLiteral(resourceName: "pawprint"), for: .normal)
            }
            
            isFavorited = true
            storeToDisplay.favoriteList.append(user!)
            print("This is favorite list: \(storeToDisplay.favoriteList)")
            dataStore?.save(storeToDisplay, response: { (Store) in
                print("Successfully added")
                print(self.storeToDisplay.favoriteList)
            }, error: { (Fault) in
                print("There is a server error: \(String(describing: Fault?.description))")
            })
        } else {
            isFavorite.setImage(#imageLiteral(resourceName: "emptyHeart"), for: .normal)
            isFavorited = false
            
            for list in storeToDisplay.favoriteList {
                if list.objectId == user?.objectId {
                    let index = storeToDisplay.favoriteList.index(of: list)
                    storeToDisplay.favoriteList.remove(at: index!)
                }
            }
            
            dataStore?.save(storeToDisplay, response: { (Store) in
                print("Successfully removed")
                print(self.storeToDisplay.favoriteList)
            }, error: { (Fault) in
                print("There is a server error: \(String(describing: Fault?.description))")
            })
        }
    }
    
    /**
     Sets up the stretchy header view of the tableView
     */
    func setupHeaderView() {
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        
        tableView.addSubview(headerView)
        
        tableView.contentInset = UIEdgeInsets(top: kTableHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -kTableHeaderHeight)
        updateHeaderView()
    }
    
    /**
     Adjusts the headerView according to the contentOffset of the tableView
     */
    func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -kTableHeaderHeight, width: tableView.bounds.width, height: kTableHeaderHeight)
        if tableView.contentOffset.y < -kTableHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        
        headerView.frame = headerRect
    }
    
    /**
     Update the headerView and tableview when the layout changes
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderView()
    }
    
    // MARK: view methods
    /**
     Calls when the view is loaded. Load all the details from the store object to the labels, and adjust the view
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storeToDisplay.hits = storeToDisplay.hits + 1
        
        let dataStore = Backendless.sharedInstance().data.of(Store.ofClass())
        dataStore?.save(storeToDisplay, response: { (response) in
            print("Successfully saved the hits")
        }, error: { (Fault) in
            print("Error on saving hits")
        })
        
        /// set up the Self-Sizing Table View Cells
        /// Should set the label line as 0
        tableView.estimatedRowHeight = 160
        tableView.rowHeight = UITableViewAutomaticDimension
    
        setupDatasource()
        
        storeNameLabel.text = storeToDisplay.name
        storeSubtitleLabel.text = storeToDisplay.storeSubtitle
        
        self.storeRatingView.alpha = 1.0
        self.storeRatingView.value = CGFloat(storeToDisplay.reviewAverage)
        
        if let imageURL = storeToDisplay.imageURL {
            storeImageView.kf.setImage(with: URL(string: imageURL), placeholder: #imageLiteral(resourceName: "imageplaceholder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
        }
        
        setupHeaderView()
        tableView.tableFooterView = UIView(frame: .zero)
        
        // Hide the navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
//        self.navigationController?.hidesBarsOnTap = true
        
        
        /// Favorite List Check 
        let user = UserManager.currentUser()
        for list in storeToDisplay.favoriteList {
            if list.objectId == user?.objectId {
                isFavorited = true
            }
        }
        
        if isFavorited == true {
            let randomNum : UInt32 = arc4random_uniform(2)
            if randomNum == 0 {
                isFavorite.setImage(#imageLiteral(resourceName: "redHeart"), for: .normal)
            } else {
                isFavorite.setImage(#imageLiteral(resourceName: "pawprint"), for: .normal)
            }
        } else {
            isFavorite.imageView?.image = #imageLiteral(resourceName: "emptyHeart")
        }
        
        /// Set the gesture recognizer, 탭 한 번 하면 didTap으로 넘어가서 전화걸기, 웹사이트 이동 등
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap(recognizer:)))
        recognizer.numberOfTapsRequired = 1
        self.tableView.addGestureRecognizer(recognizer)
        
        let anotherRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.showPhoto(recognizer:)))
        anotherRecognizer.numberOfTapsRequired = 2
        self.tableView.addGestureRecognizer(anotherRecognizer)
    }
    
    /// 사진 브라우저 더블탭하면 런칭
    func showPhoto(recognizer: UIGestureRecognizer) {
        print("showPhoto is working now")
        
        let tapLocation = recognizer.location(in: self.tableView)
        if let tapIndexPath = tableView.indexPathForRow(at: tapLocation) {
            if isExpanded == false {
                if tapIndexPath == [6,0] {
                    let browser = SKPhotoBrowser(photos: SKimageArray)
                    browser.initializePageIndex(0)
                    self.present(browser, animated: true, completion: nil)
                }
            } else {
                if tapIndexPath == [8,0] {
                    let browser = SKPhotoBrowser(photos: SKimageArray)
                    browser.initializePageIndex(0)
                    self.present(browser, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    /** 
        Detect the tap and take action, 액션을 정의하는 곳
        - parameter: recognizer
        
        Check the indexPath
     */
    func didTap(recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: self.tableView)
        
        // 싱글탭하면 전화 걸기, 웹사이트 이동, 리뷰 보기 지원 
        // 펼쳤는지 접었는지에 따라 indexPath가 달라짐
        
        if let tapIndexPath = tableView.indexPathForRow(at: tapLocation) {
            print("This is tapIndexPath: \(tapIndexPath)")
            print("This is isExpanded: \(isExpanded)")
            if self.tableView.cellForRow(at: tapIndexPath) != nil {
                // 안 접혔을 때
                if isExpanded == false {
                    /// 전화번호 걸게
                    if tapIndexPath == [3,0] {
                        callButtonPressed()
                    } else if tapIndexPath == [3,2] {
                        /// 웹사이트 로딩, 사파리뷰
                        if var website = storeToDisplay.website {
                            if website.lowercased().hasPrefix("http") == false {
                                website = "http://".appending(website)
                            } 
                            print("This is url: \(website)")
                            if let url = URL(string: website) {
                                let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
                                vc.delegate = self
                                // vc.modalPresentationStyle = .overFullScreen
                                present(vc, animated: true, completion: nil)
                            }
                        } else {
                            SCLAlertView().showNotice("웹사이트가 없어요", subTitle: "생기면 업데이트를 하겠습니다")
                        }
                    } else if tapIndexPath.section == 11 {
                        // [11]이 리뷰 3개를 표시하는 곳, 선택하면 바로 보여주기
                        let reviewPresentManager : ReviewPresentManager = ReviewPresentManager()
                        
                        let selectedReview = downloadedReviews[tapIndexPath.row]
                        let storyboard = UIStoryboard(name: "Reviews", bundle: nil)
                        let destinationController = storyboard.instantiateViewController(withIdentifier: "ReviewsDetailViewController") as! ReviewsDetailViewController
                        destinationController.reviewToDisplay = selectedReview
                        destinationController.transitioningDelegate = reviewPresentManager
                        present(destinationController, animated: true, completion: nil)
                        
                    } else if (tapIndexPath == [3,1]) ||  (tapIndexPath.section == 8) || (tapIndexPath == [3,3]) {
                        // (tapIndexPath.section == 6) ||
                        // [3,1]과 [8]은 주소 - 우선 주소만 카피
                        // [3,3]은 영업시간, 섹션 6은 디테일 정보
                        let pasteboard = UIPasteboard.general
                        if let address = storeToDisplay.address {
                            pasteboard.string = "\(address)"
                            SCLAlertView().showSuccess("복사 완료", subTitle: "클립 보드에 저장됨")
                        } else {
                            SCLAlertView().showError("복사 실패", subTitle: "저장할 정보가 없습니다")
                        }
                    }
                } else {
                    if tapIndexPath == [3,0] {
                        callButtonPressed()
                    } else if tapIndexPath == [3,2] {
                        /// 웹사이트 로딩, 사파리뷰
                        if var website = storeToDisplay.website {
                            if website.lowercased().hasPrefix("http") == false {
                                website = "http://".appending(website)
                            }
                            print("This is url: \(website)")
                            if let url = URL(string: website) {
                                let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
                                vc.delegate = self
                                // vc.modalPresentationStyle = .overFullScreen
                                present(vc, animated: true, completion: nil)
                            }
                        } else {
                            SCLAlertView().showNotice("웹사이트가 없어요", subTitle: "생기면 업데이트를 하겠습니다")
                        }
                    } else if (tapIndexPath == [3,1]) ||  (tapIndexPath.section == 6) || (tapIndexPath == [3,3]) || (tapIndexPath == [10,0]) {
                        // 펼쳐져 있을 때는 섹션 6이 디테일 정보
                        // [3,1]과 [8]은 주소 - 우선 주소만 카피
                        // [3,3]은 영업시간, 섹션 6은 디테일 정보
                        let pasteboard = UIPasteboard.general
                        if let address = storeToDisplay.address {
                            pasteboard.string = "\(address)"
                            SCLAlertView().showSuccess("복사 완료", subTitle: "클립 보드에 저장됨")
                        } else {
                            SCLAlertView().showError("복사 실패", subTitle: "저장할 정보가 없습니다")
                        }
                    } else if tapIndexPath.section == 13 {
                        // [11]이 리뷰 3개를 표시하는 곳, 선택하면 바로 보여주기
                        let reviewPresentManager : ReviewPresentManager = ReviewPresentManager()
                        
                        let selectedReview = downloadedReviews[tapIndexPath.row]
                        let storyboard = UIStoryboard(name: "Reviews", bundle: nil)
                        let destinationController = storyboard.instantiateViewController(withIdentifier: "ReviewsDetailViewController") as! ReviewsDetailViewController
                        destinationController.reviewToDisplay = selectedReview
                        destinationController.transitioningDelegate = reviewPresentManager
                        present(destinationController, animated: true, completion: nil)
                        
                    }
                }
            }
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("Nothing to do")
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidLayoutSubviews()
    }
    
    /**
     Set up the datasource for the tableView
     */
    func setupDatasource() {
        // define all your sections and rows here
        tableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "reviewCell")
        
        // About Section
         let aboutSectionHeaderRow = StoreDetailRowDatasource<UITableViewCell>(identifier: "sectionHeaderSpaceCell") { (cell) in
            cell.textLabel?.text = "장소 소개"
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
        }
        
        let aboutSection = StoreDetailRowDatasource<DescriptionTableViewCell>(identifier: "descriptionCell", setupBlock: { (cell) in
            self.configureDescriptionCell(cell)
        }) { () -> () in
            // add method here to handle cell selection
            print("About Section has selected")
        }
        
        // Info Section
        let infoSectionHeaderRow = StoreDetailRowDatasource<UITableViewCell>(identifier: "sectionHeaderSpaceCell") { (cell) in
            cell.textLabel?.text = "기본 정보"
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
        }
        
        let infoSection = StoreDetailSectionDatasource<InfoWithIconTableViewCell>(cellIdentifier: "infoWithIcon", numberOfRows: 4, setupBlock: { (cell, row) in
            self.configureInfoSectionCell(cell, row: row)
        }) { (cell, row) in
            self.infoSectionCellWasSelected(cell, row: row)
        }
        
        detailInfoButton = StoreDetailSectionDatasource<ReviewOptionsTableViewCell>(cellIdentifier: "reviewButtons", numberOfRows: 1, setupBlock: { (cell, row) -> () in
            self.configureDetailInfoButtonCell(cell, row: row)
        }) { (cell, row) -> () in
            // add method here to handle cell selection - no need
            print("Detail Info has selected")
        }
        
        // Detail Info Section
        let detailInfoSectionHeaderRow = StoreDetailRowDatasource<UITableViewCell>(identifier: "sectionHeaderSpaceCell") { (cell) in
            cell.textLabel?.text = "세부 정보"
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
        }
        
        let detailInfoSection = StoreDetailSectionDatasource<InfoWithIconTableViewCell>(cellIdentifier: "infoWithIcon", numberOfRows: 5, setupBlock: { (cell, row) in
            self.configureDetailInfoSectionCell(cell, row: row)
        }) { (cell, row) in
            self.infoSectionCellWasSelected(cell, row: row)
        }
        
        // Photo Section
        let photoSectionHeaderRow = StoreDetailRowDatasource<UITableViewCell>(identifier: "sectionHeaderSpaceCell") { (cell) in
            cell.textLabel?.text = "사진"
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
        }

        let photoSection = StoreDetailRowDatasource<storePhotoTableViewCell>(identifier: "storePhotoCell") { (cell) in
            DispatchQueue.main.async(execute: { 
                self.configureStorePhotoCell(cell)
            })
        }
        
        // Map Section
        
        let locationSectionHeaderRow = StoreDetailRowDatasource<UITableViewCell>(identifier: "sectionHeaderSpaceCell", setupBlock: { (cell) in
            cell.textLabel?.text = "지도"
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
        }) { 
            print("Location Header")
        }
        
        // 애플맵 기반으로 작성된 mapSection, 주석 처리
        /**
        let mapSection = StoreDetailRowDatasource<StoreMapTableViewCell>(identifier: "mapCell", setupBlock: { (cell) in
                self.configureMapCell(cell)
        }) {
            // add method here to handle cell selection
        }
         */
        
        // 구글맵 기반
        /**
        let googleMapSection = StoreDetailRowDatasource<StoreGoogleMapTableViewCell>(identifier: "googleMapCell", setupBlock: { (cell) in
                DispatchQueue.main.async(execute: {
                    self.configureGoogleMapCell(cell)
                })
        }) { 
            print("This is Google Map")
        }
        */
        
        let naverMapSection = StoreDetailRowDatasource<StoreNaverMapTableViewCell>(identifier: "naverMapCell", setupBlock: { (cell) in
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
            
            DispatchQueue.main.async(execute: {
                self.configureNaverMapCell(cell)
            })
        }) {
            print("This is naver map")
        }
        
        let mapInfoSection = StoreDetailRowDatasource<InfoWithIconTableViewCell>(identifier:"infoWithIcon", setupBlock: { (cell) in
            self.configureMapInfoSectionCell(cell)
        }) { 
            let placeMark = MKPlacemark(coordinate: self.storeToDisplay.coordinate(), addressDictionary: nil)
            let destination = MKMapItem(placemark: placeMark)
            destination.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
        }
        
        // Review section
        reviewSectionHeaderRow = StoreDetailRowDatasource<UITableViewCell>(identifier: "sectionHeaderSpaceCell") { (cell) -> () in
            cell.textLabel?.text = "리뷰"
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
        }
        
        reviewsSection = StoreDetailSectionDatasource<ReviewTableViewCell>(cellIdentifier: "reviewCell", numberOfRows: downloadedReviews.count, setupBlock: { (cell, row) -> () in
            self.configureReviewsCells(cell, row: row)
        }) { (cell, row) -> () in
            // add method here to handle cell selection
            print("review section has selected")
        }
        
        reviewButtonSection = StoreDetailSectionDatasource<ReviewOptionsTableViewCell>(cellIdentifier: "reviewButtons", numberOfRows: 1, setupBlock: { (cell, row) -> () in
            self.configureReviewButtonsCell(cell, row: row)
        }) { (cell, row) -> () in
            // add method here to handle cell selection
            print("review button has selected")
        }
        
        if isExpanded == false {
            dataSource = StoreDetailViewDatasource(sectionSources: [aboutSectionHeaderRow, aboutSection, infoSectionHeaderRow, infoSection, detailInfoButton, photoSectionHeaderRow, photoSection, locationSectionHeaderRow, mapInfoSection, naverMapSection, reviewSectionHeaderRow, reviewsSection, reviewButtonSection])
            
        } else {
            dataSource = StoreDetailViewDatasource(sectionSources: [aboutSectionHeaderRow, aboutSection, infoSectionHeaderRow, infoSection, detailInfoButton, detailInfoSectionHeaderRow, detailInfoSection, photoSectionHeaderRow, photoSection, locationSectionHeaderRow, mapInfoSection, naverMapSection, reviewSectionHeaderRow, reviewsSection, reviewButtonSection])
            
        }
        
        dataSource.tableView = tableView
        tableView.dataSource = dataSource
        
        downloadReviews()
        tableView.reloadData()
    }
    
    /**
     Download the reviews, updates the rating view, and displays the reviews if any is available
     */
    func downloadReviews() {
        let limit = 3 // only display 3 items here
        reviewManager.downloadReviewCountsAndReviewsForStore(storeToDisplay) { (reviews, error) -> () in
            if (reviews?.count)! > 0 {
                self.downloadedReviews = reviews!
                self.reviewsSection.numberOfRows = (limit < reviews!.count) ? limit : reviews!.count
                self.numberOfReviews = (reviews?.count)!
                
                self.storeToDisplay.reviews = reviews!
                self.storeRatingLabel.alpha = 1.0
                self.storeRatingView.value = CGFloat(self.storeToDisplay.reviewAverage)
            } else {
                // remove the review section header and reload the tableView if there are no reviews to show.
                self.dataSource.removeSectionAtIndex((self.reviewSectionHeaderRow?.sectionIndex)!)
                self.tableView.reloadData()
            }
            
            if self.storeToDisplay.reviewCount != 0 {
                let hit = self.storeToDisplay.hits
                let reviewAverage = String(format: "%.1f", self.storeToDisplay.reviewAverage)
                let reviewCount = self.storeToDisplay.reviews.count
                self.storeRatingLabel.text = "조회수: \(hit), 평점: \(reviewAverage)점, 총 리뷰: \(reviewCount)개"
                
            } else {
                let hit = self.storeToDisplay.hits
                self.storeRatingLabel.text = "조회수: \(hit)"
            }
        }
    }
    
    // MARK: configuration methods for cells
    /**
     Configures the description cell
     
     - parameter cell: cell to set
     */
    func configureDescriptionCell(_ cell: DescriptionTableViewCell) {
        cell.descriptionLabel.text = storeToDisplay.storeDescription
    }
    
    /**
     Configures the info sectin cells, sets the phone number, address, website and email address
     
     - parameter cell: cell to set
     - parameter row:  at which row
     */
    func configureInfoSectionCell(_ cell: InfoWithIconTableViewCell, row: Int) {
        if row == 0 {
            cell.infoLabel.text = storeToDisplay.phoneNumber
            cell.iconImageView.image = UIImage(named: "phoneIcon")
        } else if row == 1 {
            cell.infoLabel.text = storeToDisplay.address
            cell.iconImageView.image = UIImage(named: "visitIcon")
        } else if row == 2 {
            cell.infoLabel.text = storeToDisplay.website
            cell.iconImageView.image = UIImage(named: "homepageIcon")
        } else {
            cell.infoLabel.text = storeToDisplay.operationTime
            cell.iconImageView.image = UIImage(named: "clock")
        }
    }
    
    /**
     Configures the detail Info button cell
     
     - parameter cell: cell to configure
     */
    func configureDetailInfoButtonCell(_ cell: ReviewOptionsTableViewCell, row: Int) {
        if isExpanded == false {
            cell.changeButtonTitle("정보 더 보기")
            cell.removeButtonTargets(self, action: #selector(self.buttonTapped))
            cell.addButtonTarget(self, action: #selector(self.buttonTapped), forControlEvents: .touchUpInside)
        } else {
            cell.changeButtonTitle("정보 숨기기")
            cell.removeButtonTargets(self, action: #selector(self.buttonTapped))
            cell.addButtonTarget(self, action: #selector(self.buttonTapped), forControlEvents: .touchUpInside)
        }
    }
    
    // 정보 더 보기 / 숨기기 보여주는 버튼 컨트롤
    func buttonTapped() {
        if isExpanded == false {
            isExpanded = true
            self.setupDatasource()
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            isExpanded = false
            self.setupDatasource()
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    /**
     Configures the info sectin cells, sets the category, serviceable Pet, pet Size, price info and note
     
     - parameter cell: cell to set
     - parameter row:  at which row
     */
    func configureDetailInfoSectionCell(_ cell: InfoWithIconTableViewCell, row: Int) {
        if row == 0 {
            cell.infoLabel.text = storeToDisplay.serviceCategory
            cell.iconImageView.image = UIImage(named: "businesswoman")
        } else if row == 1 {
            cell.infoLabel.text = storeToDisplay.serviceablePet
            cell.iconImageView.image = UIImage(named: "petIcon")
        } else if row == 2 {
            cell.infoLabel.text = storeToDisplay.petSize
            cell.iconImageView.image = UIImage(named: "sizeIcon")
        } else if row == 3 {
            cell.infoLabel.text = storeToDisplay.priceInfo
            cell.iconImageView.image = UIImage(named: "pricetagIcon")
        } else {
            cell.infoLabel.text = storeToDisplay.note
            cell.iconImageView.image = UIImage(named: "noteIcon")
        }
    }

    /**
     Configures the store Photo cell
     - parameter cell: cell to configure
     */
    func configureStorePhotoCell(_ cell: storePhotoTableViewCell) {
        
        cell.scrollView.delaysContentTouches = false
        
        if storeToDisplay.imageArray != nil {
            DispatchQueue.main.async(execute: { 
                if let imageArray = self.storeToDisplay.imageArray {
                    
                    let storePhotos = imageArray.components(separatedBy: ",").sorted()
                    print("This is store photos number: \(storePhotos.count)")
                    self.SKimageArray.removeAll()
                    
                    for i in 0..<(storePhotos.count) {
                        
                        if let url = URL(string: storePhotos[i].trimmingCharacters(in: .whitespacesAndNewlines)) {
                            print("This is photo url: \(url)")
                            
                            DispatchQueue.main.async(execute: { 
                                
                                let imageView = UIImageView()
                                imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imageplaceholder"), options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, returnedUrl) in
                                    if error != nil {
                                        print("there is an error on fetching store photos")
                                    } else {
                                        let xPosition = self.view.frame.width * CGFloat(i)
                                        imageView.frame = CGRect(x: xPosition, y: 0, width: cell.scrollView.frame.width, height: cell.scrollView.frame.height)
                                        imageView.contentMode = .scaleAspectFill
                                        cell.scrollView.contentSize.width = cell.scrollView.frame.width * CGFloat(i+1)
                                        cell.scrollView.addSubview(imageView)
                                        cell.layoutIfNeeded()
                                        
                                        // 포토브라우저 준비를 위한 배열에 사진 삽입
                                        if let image = image {
                                            let photo = SKPhoto.photoWithImage(image)
                                            self.SKimageArray.append(photo)
                                        }
                                    }
                                    
                                })
                          
                            })
                            
                        } else {
                            print("url is nil")
                        }
                    }
                    // self.view.setNeedsLayout()
                }
            })
        } else {
            /// 사진이 없을 때 기본 사진, 향후 사진 준비 중입니다 이미지 준비 필요
            let imageArray = [#imageLiteral(resourceName: "backgroundImage")]
            for i in 0..<(imageArray.count) {
                
                let imageView = UIImageView()
                imageView.image = imageArray[i]
                imageView.contentMode = .scaleAspectFill
                
                let xPosition = self.view.frame.width * CGFloat(i)
                imageView.frame = CGRect(x: xPosition, y: 0, width: cell.scrollView.frame.width, height: cell.scrollView.frame.height)
                
                cell.scrollView.contentSize.width = cell.scrollView.frame.width * CGFloat(i+1)
                cell.scrollView.addSubview(imageView)
            }
        }
    }
    
    /**
     Configures the map cell
     
     - parameter cell: cell to configure
     */
    func configureMapCell(_ cell: StoreMapTableViewCell) {
        cell.zoomMapToStoreLocation(storeToDisplay)
    }
    
    /**
     Configures the Google map cell
     
     - parameter cell: cell to configure
     */
    func configureGoogleMapCell(_ cell: StoreGoogleMapTableViewCell) {
        cell.zoomMapToStoreLocation(storeToDisplay)
    }
    
    /**
     Configures the Naver map cell
     
     - parameter cell: cell to configure
     */
    func configureNaverMapCell(_ cell: StoreNaverMapTableViewCell) {
        cell.zoomMapToStoreLocation(storeToDisplay)
    }
    
    /**
     Configures the map info section
     
     - parameter cell: cell to configure
     */
    func configureMapInfoSectionCell(_ cell: InfoWithIconTableViewCell) {
        cell.infoLabel.text = storeToDisplay.address
        cell.iconImageView.image = UIImage(named: "cellLocationIcon")
        
    }
    
    /**
     Configures the reviews cell
     
     - parameter cell: cell to configure
     - parameter row:  at which row
     */
    func configureReviewsCells(_ cell: ReviewTableViewCell, row: Int) {
        let review = downloadedReviews[row]
        
        // 리뷰 프로필 뷰 세팅
        let userId = review.creator?.objectId!
        
        let dataStore = Backendless.sharedInstance().data.of(Users.ofClass())
        dataStore?.findID(userId, response: { (response) in
            let user = response as! BackendlessUser
            if let imageURL = user.getProperty("profileURL") {
                cell.profileImageView.kf.setImage(with: URL(string: imageURL as! String), placeholder: #imageLiteral(resourceName: "imageplaceholder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
            }
            cell.nameLabel.text = user.name! as String
        }, error: { (Fault) in
            print("Server reported error on retreiving an user: \(String(describing: Fault?.description))")
        })
        
        // 댓글, 공유 버튼 숨기기 false
        cell.commentLabel.isHidden = false
        cell.commentButton.isHidden = false
        cell.shareButton.isHidden = false
        
        // 본문 세팅
        cell.reviewTextLabel.text = review.text
        // 평점 세팅
        cell.setRating(review.rating)
        // 날짜 세팅
        cell.dateLabel.text = dateFormatter.string(from: review.created as Date)
        
        // 이미지 세팅
        if let fileURL = review.fileURL {
            cell.setReviewImageViewHidden(false)
            let imageArray = fileURL.components(separatedBy: ",").sorted()
            // 사진이 1개만 있는 경우, 추가로 뷰를 붙이지 않는다
            if imageArray.count == 1 {
                cell.reviewImageView.kf.setImage(with: URL(string: fileURL), placeholder: #imageLiteral(resourceName: "imageplaceholder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
            } else {
                cell.reviewImageView.kf.setImage(with: URL(string: imageArray[0]), placeholder: #imageLiteral(resourceName: "imageplaceholder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
                
                // 추가로 몇 개의 사진이 더 있는지 '+1'의 형태로 보여주는 뷰
                let myLabel = UILabel(frame: CGRect(x: cell.reviewImageView.frame.width-30, y: cell.reviewImageView.frame.height-30, width: 30, height: 30))
                myLabel.textAlignment = .center
                myLabel.backgroundColor = UIColor(red: 211, green: 211, blue: 211, alpha: 0.8)
                myLabel.text = "+\(imageArray.count-1)"
                myLabel.font = UIFont(name: "Avenir", size: 12)
                myLabel.layer.cornerRadius = 5.0
                cell.reviewImageView.addSubview(myLabel)
                cell.reviewImageView.bringSubview(toFront: myLabel)
            }
        } else {
            cell.setReviewImageViewHidden(true)
        }
    }
    
    /**
     Configures the reviews button cell
     
     - parameter cell: cell to configure
     */
    func configureReviewButtonsCell(_ cell: ReviewOptionsTableViewCell, row: Int) {
        if downloadedReviews.count == 0 {
            cell.changeButtonTitle("리뷰 글쓰기")
            cell.removeButtonTargets(self, action: #selector(StoreDetailViewController.leaveAReviewButtonPressed))
            cell.addButtonTarget(self, action: #selector(StoreDetailViewController.leaveAReviewButtonPressed), forControlEvents: .touchUpInside)
        } else {
            cell.changeButtonTitle("리뷰 더보기(총: \(numberOfReviews)개)")
            cell.removeButtonTargets(self, action: #selector(StoreDetailViewController.readMoreReviewsPressed))
            cell.addButtonTarget(self, action: #selector(StoreDetailViewController.readMoreReviewsPressed), forControlEvents: .touchUpInside)
        }
    }
    
    /**
     Show the ReviewsViewController and display all the reviews for the selected Store
     */
    func readMoreReviewsPressed() {
        let reviewsController = StoryboardManager.reviewsViewController()
        reviewsController.selectedStoreObject = storeToDisplay
        // 네비게이션 컨트롤러 스택에 넣기
        navigationController?.pushViewController(reviewsController, animated: true)
        
    }
    
    /**
     Called when the leave a review button is selected, first it checks if the user is logged in or not. If not, presents the login
     */
    func leaveAReviewButtonPressed() {
        if UserManager.isUserLoggedIn() {
            readMoreReviewsPressed()
        } else {
            // display login view
            let loginViewController = StoryboardManager.loginViewController()
            loginViewController.displayCloseButton = true
            present(loginViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: Handle selection
    /**
    Called when any of the info section's row is selected
     
     - parameter cell: cell that was selected
     - parameter row: which row was selected
    */
    func infoSectionCellWasSelected(_ cell: InfoWithIconTableViewCell, row: Int) {
        if row == 0 {
            callButtonPressed()
            print("Being Called")
        } else if row == 1 {
//            emailButtonPressed()
            print("Being Called")
        } else {
//            webButtonPressed()
            print("Being Called")
        }
    }
    
    /**
     Calls the datasource's section selection block when the user selected a row
     
     - parameter tableView: tableView
     - parameter indexPath: indexPath that was selected
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dataSource.sectionSources[indexPath.section].tableView(tableView, didSelectRowAtIndexPath: indexPath)
        print("This is selected section: \(indexPath.section) and indexPath: \(indexPath)")
    }
    
    /**
     Presents an alertView to be able to call the store's phoneNumber
     */
    func callButtonPressed () {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("전화걸기", action: {
            let replaced = self.storeToDisplay.phoneNumber!.replacingOccurrences(of: "-", with: "")
            let phoneNumberString = "telprompt://\(replaced)"
            print("This is phonenumber: \(phoneNumberString)")
            if let url = URL(string: "telprompt://\(replaced)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        alertView.addButton("취소") {
            print("전화걸기가 취소되었습니다")
        }
        alertView.showInfo("전화번호", subTitle: "\(storeToDisplay.phoneNumber!)")
    }

    /**
     What status bar style we want to use
     
     :returns: light statusbar style
     */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

}

// MARK: - Extension of the viewController
extension StoreDetailViewController {
    
    /**
     Called when the user scrolled the tableView. Updates the headerView and checks to change the navigation bar's backgroundColor to solid or not.
     
     - parameter scrollView: ScrollView
     */
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
        
        if scrollView.contentOffset.y >= -(customNavigationBarView.frame).height {
            customNavigationBarView.adjustBackground(false)
        } else {
            customNavigationBarView.adjustBackground(true)
        }
    }
}
