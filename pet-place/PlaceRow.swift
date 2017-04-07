//
//  PlaceCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 6..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class PlaceRow: UITableViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var storeList = [Recommendations]()
    
    @IBOutlet weak var placeCollection: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return storeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceCell", for: indexPath) as! StoreCollectionViewCell
        
        let store = storeList[indexPath.row].store
        let imageURL = store?.imageURL
        let url = URL(string: imageURL!)
        cell.storeImage.layer.cornerRadius = 15.0
        cell.storeImage.hnk_setImage(from: url!, placeholder: UIImage(named: "placeholder"))
        
        // let textData = store?.name?.data(using: .utf16)
        // let text = NSString(data: textData!, encoding: String.Encoding.init(rawValue: 0x80000003).rawValue)
        // print("This is text: \(text)")
        cell.storeTitle.text = store?.name!
        
        cell.tag = indexPath.row
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width/2)-20
        return CGSize(width: width, height: 160)
    }
    
    
}

