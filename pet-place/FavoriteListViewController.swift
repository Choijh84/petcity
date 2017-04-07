//
//  FavoriteListViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 2..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import SCLAlertView
import Kingfisher

class FavoriteListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var favoriteList = [Store]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var uiView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiView.isHidden = true
        collectionView.delegate = self
        collectionView.dataSource = self
        // Do any additional setup after loading the view.
        
        downloadFavoriteList()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // 향후 page로 loading 도입 필요
    
    func downloadFavoriteList() {
        let user = Backendless.sharedInstance().userService.currentUser
        let objectId = user?.objectId
        
        let query = BackendlessDataQuery()
        // let queryOptions = QueryOptions()
        
        query.whereClause = "favoriteList.objectId = \'\(objectId!)\'"
        
        let dataStore = Backendless.sharedInstance().data.of(Store.ofClass())
        dataStore?.find(query, response: { (bc) in
            if bc == nil {
                SCLAlertView().showNotice("No List", subTitle: "Please select")
            } else {
                if let storeLists = bc?.data {
                    for storeList in storeLists {
                        let store = storeList as! Store
                        self.favoriteList.append(store)
                    }
                }
            }
            self.collectionView.reloadData()
            if self.favoriteList.count == 0 {
                self.uiView.isHidden = false
            } else {
                self.uiView.isHidden = true
            }
        }, error: { (Fault) in
            print("Server reported error: \(String(describing: Fault?.description))")
        })
    }
    
    // MARK: CollectionView func
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count: \(favoriteList.count)")

        return favoriteList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteStoreCell", for: indexPath) as! FavoriteListCollectionViewCell
        
        cell.storeName.text = favoriteList[indexPath.row].name
        
        if let imageURL = favoriteList[indexPath.row].imageURL {
            let url = URL(string: imageURL)
            cell.storeImage.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imageplaceholder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
            cell.storeImage.layer.cornerRadius = 10.0
            cell.blurView.layer.cornerRadius = 10.0
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let store = favoriteList[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "storeDetailViewController") as! StoreDetailViewController
        controller.storeToDisplay = store
        
        navigationController?.pushViewController(controller, animated: true)
        
        // Navigation controller is not working
        //present(controller, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.size.width
        return CGSize(width: (width-40)/2, height: (width-40)/2*0.8)
    }
    
}
