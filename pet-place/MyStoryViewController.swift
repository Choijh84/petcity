//
//  MyStoryViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 4. 4..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import Kingfisher

class MyStoryViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var storyArray = [Story]()
    
    /// Lazy getter for the dateformatter that formats the date property of each pet profile to the desired format
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        
        title = "내 스토리들"
        
        // Do any additional setup after loading the view.
        setUpMyStoryArray()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // 향후에 페이지 기능 도입해서 10개씩 다운로드 되는 것으로 바꿔야 할 듯
    func setUpMyStoryArray() {
        let userID = UserManager.currentUser()!.objectId!
        print("This is user ObjectId: \(userID)")
        
        let dataStore = Backendless.sharedInstance().data.of(Story.ofClass())
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = "writer.objectId = \'\(userID)\'"
        
        dataStore?.find(dataQuery, response: { (collection) in
            self.storyArray = collection?.data as! [Story]
            self.collectionView.reloadData()
        }, error: { (Fault) in
            print("Server reported error: \(String(describing: Fault?.description))")
        })
    }
}


// MARK: - CollectionnView DataSource

extension MyStoryViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // 이미지 선택했을 때 팝업처럼 보여줄까?
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let myStory = storyArray[indexPath.row]
        print("Story has been selected: \(String(describing: myStory.bodyText))")
        
        let storyboard = UIStoryboard(name: "StoryAndReview", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "StoryViewController") as! StoryViewController
        viewController.StoryArray.append(myStory)
        viewController.isMyStory = true
        self.navigationController?.pushViewController(viewController, animated: true)
        
        // present(viewController, animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storyArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // 콜렉션뷰 구성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MyStoryCollectionViewCell
        
        let myStory = storyArray[indexPath.row]
        if let imageArray = myStory.imageArray {
            let imageUrls = imageArray.components(separatedBy: ",").sorted()
            if let firstImageUrl = imageUrls.first {
                let url = URL(string: firstImageUrl)
                DispatchQueue.main.async(execute: { 
                    cell.storyImage.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imageplaceholder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
                    cell.timeLabel.text = self.dateFormatter.string(from: myStory.created as Date)

                })
            }
        }
        
        return cell
    }
    
    // 콜렉션뷰 아이템 사이즈 - 2줄로
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = UIScreen.main.bounds.width
        // 20은 cell들 사이의 spacing, 10은 좌측과 우측의 공간
        let modifiedWidth = (width-30)/2
        
        return CGSize(width: modifiedWidth, height: modifiedWidth)
    }
    
}
