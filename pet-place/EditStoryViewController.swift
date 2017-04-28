//
//  EditStoryViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 4. 28..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import DKImagePickerController
import SKPhotoBrowser
import SCLAlertView
import Kingfisher

class EditStoryViewController: UIViewController, UIImagePickerControllerDelegate, UITextViewDelegate {

    // 스토리 편집할 때 스토리 변수를 받아서 입력하기
    var selectedStory: Story!
    
    var imageArray = [UIImage]()
    
    @IBOutlet weak var imageCollection: UICollectionView!
    
    
    // 본문 텍스트뷰
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 스토리 셋업 - 본문 & 사진
        // 본문 셋업
        if let text = selectedStory.bodyText {
            textView.text = text
        }
        
        // 사진 셋업
        // 사진 추가, 삭제 등이 어렵다 DKImagePickerController와 호환이 문제
        
    }

}

extension EditStoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell?
        var imageView: UIImageView?
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell?.layer.cornerRadius = 4.5
        cell?.layer.borderColor = UIColor.lightGray.cgColor
        cell?.layer.borderWidth = CGFloat(1.0)
        imageView = cell?.contentView.viewWithTag(1) as? UIImageView
        
        if let cell = cell, let imageView = imageView {
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            let tag = indexPath.row + 1
            cell.tag = tag
            let image = imageArray[indexPath.row]
            if cell.tag == tag {
                imageView.image = image
            }
            
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
