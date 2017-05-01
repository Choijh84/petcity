//
//  ReviewsDetailViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 20..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import HCSStarRatingView
import SKPhotoBrowser
import Kingfisher

/// Custom viewcontroller that displays a selected review
class ReviewsDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    /// Selected review to be displayed
    var reviewToDisplay: Review!
    
    /// creator Profile Image View
    @IBOutlet weak var creatorProfileImageView: LoadingImageView!
    /// crator name
    @IBOutlet weak var creatorName: UILabel!
    /// creator timeline Label
    @IBOutlet weak var timeLineLabel: UILabel!
    
    /// Star view that displays the rating value of the review
    @IBOutlet weak var ratingView: HCSStarRatingView!
    /// Label that displays the review's text
    @IBOutlet weak var reviewTextLabel: UILabel!
    /// Button to close the view
    @IBOutlet weak var closeButton: UIButton!
    /// View that contains all the ui elements
    @IBOutlet weak var containerView: UIView!
    /// Collectionview for photo view
    @IBOutlet weak var photoView: UICollectionView!
    /// Contraint on collectionview Height
    @IBOutlet weak var reviewCollectionHeight: NSLayoutConstraint!
    
    /// Datasource array for photo URLs
    var imageURL : [String] = [""]
    
    /// UIImage array 
    var imageArray = [UIImage]()
    
    /// Lazy getter for the dateformatter that formats the date property of each review to the desired format
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    /**
     뷰 초기화
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratingView.value = CGFloat(reviewToDisplay.rating)
        reviewTextLabel.text = reviewToDisplay.text
        
        if let imageArray = reviewToDisplay.fileURL {
            imageURL = imageArray.components(separatedBy: ",").sorted()
            print("Review Detail view imageUrl: \(imageURL)")
        } else {
            hideReviewImageView()
        }
        
        // 프로필 뷰 세팅 - 둥글게
        creatorProfileImageView.layer.cornerRadius = (creatorProfileImageView.layer.frame.width/2)
        closeButton.layer.cornerRadius = 15.0
        
        configureProfile()
        addShadowsToViews()
    }

    
    func configureProfile() {
        if let user = reviewToDisplay.creator {
            if let nickname = user.getProperty("nickname") as? String {
                creatorName.text = nickname
            } else{
                creatorName.text = "닉네임"
            }
            if let profile = user.getProperty("profileURL") as? String {
                let url = URL(string: profile)
                DispatchQueue.main.async(execute: {
                    
                    self.creatorProfileImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imageLoadingHolder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
                    
                })
            } else {
                self.creatorProfileImageView.image = #imageLiteral(resourceName: "imageplaceholder")
            }
        } else {
            creatorName.text = "닉네임"
            self.creatorProfileImageView.image = #imageLiteral(resourceName: "imageplaceholder")
        }
        timeLineLabel.text = dateFormatter.string(from: reviewToDisplay.created as Date)
    }

    /**
     Hides the collectionView if the review doesn't have an image
     */
    func hideReviewImageView() {
        print("Please hide the photoView")
        photoView.isHidden = true
        view.layoutIfNeeded()
    }

    /**
     Adds shadows to the close button and the container view
     */
    func addShadowsToViews() {
        
        containerView.layer.cornerRadius = 4.0
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.shadowRadius = 2.0
        containerView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        
        closeButton.layer.cornerRadius = 4.0
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOpacity = 0.5
        closeButton.layer.shadowRadius = 2.0
        closeButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    }
    
    /**
     Dismiss the current view
     */
    @IBAction func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Keep the statusbar hidden for this view
     
     - returns: true to hide it
     */
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellImage", for: indexPath) as! ReviewDetailPhotosCVC
        
        print("This is IMAGEURL: \(imageURL[indexPath.row])")
        if let url = URL(string: imageURL[indexPath.row]) {
            cell.reviewPhotos.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imageLoadingHolder"), options: [.transition(.fade(0.2))], progressBlock: nil) { (image, error, cacheType, returnedUrl) in
                if error == nil {
                    cell.reviewPhotos.image = image
                } else {
                    print("There is an error to fetch the image in review")
                }
            }
            return cell
        } else {
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        
        if cell?.isSelected == true {
            showPhotoBrowser(indexPath.row)
        }
    }
    
    func showPhotoBrowser(_ row: Int) {
        // imageURL 배열이 이미 url을 문자열로 모아놓고 있음
        var images = [SKPhoto]()
        
        // 킹피셔 사용해서 캐시에서 url 이용해서 이미지 불러오기
        for url in self.imageURL {
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
        browser.initializePageIndex(row)
        self.present(browser, animated: true, completion: nil)
    }

}
