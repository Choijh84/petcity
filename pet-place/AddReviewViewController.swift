//
//  AddReviewViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 20..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import HCSStarRatingView
import DKImagePickerController
import SKPhotoBrowser
import SCLAlertView

 /// ViewController that allows a user to leave a review for a selected Store
class AddReviewViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate {

    /// Custom rating view for handling ratings
    @IBOutlet weak var ratingView: HCSStarRatingView!
    /// TextView for the review's body
    @IBOutlet weak var reviewField: UITextView!
    
    /// Button to select an image
    @IBOutlet weak var selectButton: UIButton!
    
    // 텍스트뷰 글자수 알려주기
    @IBOutlet weak var textViewCountLabel: UILabel!
    // 텍스트뷰 글자수 변수
    var textCount = 0
    
    /// Manager object that handles uploading/creatig a new Review
    let reviewManager = ReviewManager()
    /// selected StoreObject to leave the review for
    var selectedStore: Store!
    /// Object that helps selecting an image
    let imagePicker = UIImagePickerController()
    /// Imagepicker by DKImagePickerController
    var pickerController: DKImagePickerController!
    
    var assets: [DKAsset]?
    var imageArray = [UIImage]()
    
    
    @IBOutlet weak var previewView: UICollectionView?
    
    /// Overlay view to be shown while creating a new review
    lazy var overlayView: OverlayView = {
        let overlayView = OverlayView()
        return overlayView
    }()
    
    /**
     Creates a new review when the user pressed the send button
     */
    func sendButtonPressed() {
        
        // 리뷰가 30자 이상 되는지 검사
        if let text = reviewField.text {
            if textCount < 20 {
                SCLAlertView().showError("20자가 안되요 ㅠ", subTitle: "상세한 리뷰를 부탁드릴게요")
            } else {
                reviewField.resignFirstResponder()
                
                overlayView.displayView(view, text: "리뷰 올리는 중...")
                
                // 사진이 없을 때
                if imageArray.count == 0 {
                    reviewManager.uploadNewReview(text, fileURL: nil, rating: (self.ratingView.value) as NSNumber, store: self.selectedStore, completionBlock: { (success, store, errorMessage) in
                        if success == true {
                        
                            // 현재 리로드가 안됨 - Notification 활용 필요
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "reviewUploaded"), object: nil)
                            _ = self.navigationController?.popViewController(animated: true)
                            
                        } else {
                            SCLAlertView().showInfo("에러 발생", subTitle: "확인 부탁드립니다")
                            self.overlayView.hideView()
                        }
                    })
                } else {
                    // 사진이 여러 장
                    reviewManager.uploadBlobPhotos(selectedImages: imageArray, completionBlock: { (success, fileURL, error) in
                        if error == nil {
                            print("This is FILEURL: \(String(describing: fileURL))")
                            self.overlayView.hideView()
                            self.reviewManager.uploadNewReview(text, fileURL: fileURL, rating: (self.ratingView.value) as NSNumber, store: self.selectedStore, completionBlock:
                                { (success, store, errorMessage) in
                                    if success == true {
                                        
                                        // 현재 리로드가 안됨 - Notification 활용 필요
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: "reviewUploaded"), object: nil)
                                        _ = self.navigationController?.popViewController(animated: true)
                                        
                                    } else {
                                        SCLAlertView().showInfo("에러 발생", subTitle: "확인 부탁드립니다")
                                    }
                            })
                        } else {
                            SCLAlertView().showInfo("사진 업로드 에러", subTitle: "확인 부탁드립니다")
                        }
                    })
                }
            }
        } else {
            SCLAlertView().showError("확인 필요", subTitle: "리뷰를 입력해주세요")
        }
    }
    
    // MARK: image picker
    /**
     Called when the Select an image button pressed, opens an actionsheet and offers various ways (if available) to select an image
     */
    @IBAction func addImageButtonPressed() {
        reviewField.resignFirstResponder()
        
        let actionsheet = UIAlertController(title: "Choose source", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionsheet.addAction(UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                self.pickerController.sourceType = .camera
                self.showImagePicker()
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            actionsheet.addAction(UIAlertAction(title: "Choose photo", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                self.pickerController.assetType = .allPhotos
                self.showImagePicker()
            }))
        }
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionsheet, animated: true, completion: nil)
    }
    
    // MARK: DKIMAGE PICKER
    func showImagePicker() {
        
        pickerController.showsCancelButton = true
        
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            
            self.assets = assets
            self.previewView?.reloadData()
            self.fromAssetToImage()
        }
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            pickerController.modalPresentationStyle = .formSheet
        }
        
        self.present(pickerController, animated: true) {}
    }
    
    func fromAssetToImage() {
        imageArray.removeAll()
        for asset in self.assets! {
            asset.fetchOriginalImageWithCompleteBlock({ (image, info) in
                self.imageArray.append(image!.compressImage(image!))
            })
        }
    }
    
    /**
     Presents the image picker object
     */
    func presentImagePicker() {
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    /**
     Tells the delegate that the user picked a still image or movie.
     
     - parameter picker: The controller object managing the image picker interface.
     - parameter info:   A dictionary containing the original image and the edited image, if an image was picked; or a filesystem URL for the movie, if a movie was picked. The dictionary also contains any relevant editing information. The keys for this dictionary are listed in Editing Information Keys.
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if (info[UIImagePickerControllerOriginalImage] as? UIImage) != nil {
//            reviewImageView.image = pickedImage
        }
        
        dismiss(animated: true) { () -> Void in
//            self.reviewImageViewHeightConstraint.constant = 100.0
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: view methods
    /**
     Some view setup after the view is loaded
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "리뷰 올리기"
        
        // show a send button on the navigation bar
        let sendBarButton = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(AddReviewViewController.sendButtonPressed))
        sendBarButton.tintColor = UIColor.rgbColor(red: 235.0, green: 198.0, blue: 16.0)
        navigationItem.rightBarButtonItem = sendBarButton
        
        // 별점 반개 allow
        ratingView.allowsHalfStars = true
        ratingView.value = 4.5
        
        reviewField.text = ""
        reviewField.layer.borderColor = UIColor.rgbColor(red: 179, green: 179, blue: 179).withAlphaComponent(0.2).cgColor
        reviewField.layer.borderWidth = 1.0
        reviewField.layer.cornerRadius = 4.0
        reviewField.becomeFirstResponder()
        
        selectButton.layer.cornerRadius = 4.0
        
        view.layoutIfNeeded()
        
        // Add tap recongizer to the view, so keyboard can be closed easily
        // Close this action bcs collectionView Tap should be active
        /**
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddReviewViewController.viewTapped))
            tapRecognizer.numberOfTapsRequired = 1
            view.addGestureRecognizer(tapRecognizer)
          */
        
        pickerController = DKImagePickerController()
        previewView?.allowsSelection = true
    }

    /**
     Dismisses the keyboard if the view is tapped - disabled
     */
    func viewTapped() {
        reviewField.resignFirstResponder()
    }
    
    /**
     Set the navigation bar visible
     
     - parameter animated: animated
     Need to fix the scroll
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    /**
     Show the white statusbar
     
     - returns: white statusbar
     */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - TextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.length
        textCount = count
        
        // 라벨에 반영하기
        textViewCountLabel.text = "현재 \(textCount)자"
    }
    
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = self.assets![indexPath.row]
        var cell: UICollectionViewCell?
        var imageView: UIImageView?
        
        if asset.isVideo {
            print("This is Video")
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellImage", for: indexPath)
            cell?.layer.cornerRadius = 3.0
            cell?.layer.borderColor = UIColor.lightGray.cgColor
            cell?.layer.borderWidth = CGFloat(2.0)
            imageView = cell?.contentView.viewWithTag(1) as? UIImageView
        }
        
        if let cell = cell, let imageView = imageView {
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            let tag = indexPath.row + 1
            cell.tag = tag
            asset.fetchImageWithSize(layout.itemSize.toPixel(), completeBlock: { (image, info) in
                if cell.tag == tag {
                    imageView.image = image
                }
            })
        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        
        if cell?.isSelected == true {
            var images = [SKPhoto]()
            for image in imageArray {
                let photo = SKPhoto.photoWithImage(image)
                images.append(photo)
            }
            
            let browser = SKPhotoBrowser(photos: images)
            browser.initializePageIndex(indexPath.row)
            present(browser, animated: true, completion: nil)
        }
    }
}
