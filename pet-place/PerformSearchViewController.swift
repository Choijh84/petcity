//
//  PerformSearchViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 4. 9..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class PerformSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
 {

    @IBOutlet weak var tableView: LoadingTableView!
    
    var storeArray = [Store]()
    var filteredStoreArray = [Store]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        title = "장소 검색"
        // Do any additional setup after loading the view.
        downloadStoreList()
        searchBarSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func searchBarSetup() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 70))
        
        /**
         // 검색창의 종류별로 만들 수 있게 함, 향후 filter에서 switch 통해서 인텍스 컨트롤 가능 searchBar.selectedScopetButtonIndex & selectedScope.name.rawValue 등
         // 향후 이름, 위치, 타입 별로 검색이 가능하게?
        searchBar.showsScopeBar = true
        searchBar.scopeButtonTitles = ["이름","타입","위치"]
        searchBar.selectedScopeButtonIndex = 0
        */
        
        searchBar.delegate = self
        
        self.tableView.tableHeaderView = searchBar
    }
    
    // MARK: - SearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredStoreArray = storeArray
            self.tableView.reloadData()
        } else {
            filterTable(searchText)
        }
    }
    
    // 검색창에 무엇인가 입력되면 바로 필터해줌
    func filterTable(_ text: String) {
        print("now still filtering...")
        filteredStoreArray = storeArray.filter({ (stores) -> Bool in
            return stores.name!.lowercased().contains(text.lowercased())
        })
        self.tableView.reloadData()
    }
    
    func downloadStoreList() {
        tableView.showLoadingIndicator()
        let dataStore = Backendless.sharedInstance().data.of(Store.ofClass())
        DispatchQueue.main.async { 
            dataStore?.find({ (collection) in
                let stores = collection?.data as! [Store]
                print("This is store numbers: \(stores.count)")
                self.storeArray = stores
                self.filteredStoreArray = stores
                self.tableView.hideLoadingIndicator()
                self.tableView.reloadData()
            }, error: { (Fault) in
                print("There is an error to fetch all stores: \(String(describing: Fault?.description))")
            })
        }
    }

    // MARK: - Tableview method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredStoreArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel!.text = filteredStoreArray[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let store = filteredStoreArray[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "storeDetailViewController") as! StoreDetailViewController
        controller.storeToDisplay = store
        
        navigationController?.pushViewController(controller, animated: true)
    }
}
