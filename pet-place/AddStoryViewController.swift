//
//  AddStoryViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 17..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import DKImagePickerController
import SKPhotoBrowser
import SCLAlertView
import Kingfisher

// Viewcontroller 스토리 추가할 때
class AddStoryViewController: UIViewController, UIImagePickerControllerDelegate, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // 글 입력하는 텍스트뷰
    @IBOutlet weak var textView: UITextView!
    // 텍스트뷰의 플레이스홀더
    var placeholderLabel: UILabel!
    
    // 이미지 선택하는 버튼
    @IBOutlet weak var selectImageButton: UIButton!
    
    /// Imagepicker by DKImagePickerController
    var pickerController: DKImagePickerController!
    
    /// 이미지 픽업된 이후 저장하는 배열
    var assets: [DKAsset]?
    var imageArray = [UIImage]()
    
    /// Overlay view to be shown while creating a new review
    lazy var overlayView: OverlayView = {
        let overlayView = OverlayView()
        return overlayView
    }()
    
    /// 콜렉션뷰
    @IBOutlet weak var colllectionView: UICollectionView!
    
    // MARK: 완료 버튼, 스토리 데이터 베이스 wire-up
    
    @IBAction func addStoryButtonPressed(_ sender: Any) {
        
        textView.resignFirstResponder()
        
        // 이미지가 없는 경우
        if imageArray.count == 0 {
            SCLAlertView().showError("사진 필요", subTitle: "사진을 업로드해주세요")
        } else if textView.text == nil {
            // 스토리가 비어있는 경우
            SCLAlertView().showError("스토리 필요", subTitle: "스토리를 입력해주세요")
        } else {
            overlayView.displayView(view, text: "스토리 올리는 중")
            // 사진부터 업로드하고 url을 return 받아온다 - 이번에는 블롭으로
            StoryDownloadManager().uploadBlobPhotos(selectedFiles: imageArray, completionBlock: { (success, fileUrl, error) in
                if success {
                    // 사진 업로드가 성공하는 경우
                    print("This is FILEURL: \(String(describing: fileUrl))")
                    
                    StoryDownloadManager().uploadNewStory(self.textView.text, fileURL: fileUrl, completionBlock: { (success, error) in
                        if success {
                            // 업로드 성공하고 나면 뒤로 돌아가야지요?
                            self.overlayView.hideView()
                            SCLAlertView().showSuccess("완료", subTitle: "업로드 되었습니다")
                            
                            // 현재 리로드가 안됨 - Notification 활용 필요
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "storyUploaded"), object: nil)
                            _ = self.navigationController?.popViewController(animated: true)
                        } else {
                            // 업로드 실패입니다 ㅠ 다시 시도
                            SCLAlertView().showError("에러", subTitle: "다시 시도해주세요")
                        }
                        self.overlayView.hideView()
                    })
                } else {
                    // 사진 업로드가 실패하는 경우
                    print("ERROR on uploading the photos of story")
                    self.overlayView.hideView()
                }
            })
        }
        
    }
    
    // MARK: image picker
    /**
     Called when the Select an image button pressed, opens an actionsheet and offers various ways (if available) to select an image
     */
    @IBAction func addImageButtonPressed() {
        textView.resignFirstResponder()
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "새로운 스토리"
        
        // 텍스트뷰 플레이스 홀더 작업
        textView.delegate = self
        
        placeholderLabel = UILabel()
        placeholderLabel.text = "스토리를 입력해주세요"
        placeholderLabel.font = UIFont(name: "Avernir Next", size: 10)
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !textView.text.isEmpty
                
        selectImageButton.layer.cornerRadius = 4.0
        pickerController = DKImagePickerController()
    }
    
    // MARK: DKIMAGE PICKER
    func showImagePicker() {
        
        pickerController.showsCancelButton = true
        
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            
            self.assets = assets
            self.colllectionView?.reloadData()
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true) { 
            self.view.layoutIfNeeded()
        }
    }
    
    // 텍스트뷰 편집을 시작하면 홀더는 없어짐
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    /**
     Set the navigation bar visible
     
     - parameter animated: animated, Need to fix the scroll
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
    
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = self.assets![indexPath.row]
        var cell: UICollectionViewCell?
        var imageView: UIImageView?
        
        if (asset.isVideo) {
            print("This is video")
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            cell?.layer.cornerRadius = 4.5
            cell?.layer.borderColor = UIColor.lightGray.cgColor
            cell?.layer.borderWidth = CGFloat(1.0)
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
