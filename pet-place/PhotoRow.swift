//
//  PhotoCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 6..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class PhotoRow: UITableViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet weak var promotionCollection: UICollectionView!
    
    var photoList = [FrontPromotion]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        
        let imageURL = photoList[indexPath.row].imageURL
        let url = URL(string: imageURL!)
        
        cell.imageView.hnk_setImage(from: url, placeholder: UIImage(named: "placeholder"))
        
        return cell
        
    }
    
    // In order to keep the collectionview's paging as center by photo
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.size.width
        let height = width * 0.65
        return CGSize(width: width, height: height)
    }
    
}
