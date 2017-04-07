//
//  AddReviewImageCVC.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 15..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import DKImagePickerController

private let reuseIdentifier = "AddImageCell"

class AddReviewImageCVC: UICollectionViewController {

    var imageArray = [#imageLiteral(resourceName: "pethotel1"), #imageLiteral(resourceName: "pethotel2"), #imageLiteral(resourceName: "pethotel3"), #imageLiteral(resourceName: "pethotel4"), #imageLiteral(resourceName: "pethotel5")]
    var assetArray = [#imageLiteral(resourceName: "pethotel1"), #imageLiteral(resourceName: "pethotel2"), #imageLiteral(resourceName: "pethotel3"), #imageLiteral(resourceName: "pethotel4"), #imageLiteral(resourceName: "pethotel5")]
    
    @IBOutlet var photoCV: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        if assetArray.count > 0
        { print("container loaded with photos: \(assetArray.count)") }
        else { print ("container loaded, but no photos") }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        photoCV.reloadData()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return assetArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AddReviewImageCollectionViewCell
        
        // Configure the cell
        cell.addedImageView.image = assetArray[indexPath.row]
        
        return cell
    }

    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = CGSize(width: 99, height: 99)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
