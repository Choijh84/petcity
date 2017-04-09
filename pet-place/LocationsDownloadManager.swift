//
//  LocationsDownloadManager.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 3..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// Class is intended to be used to download Store Objects

class LocationsDownloadManager : NSObject {
    
    /// User's location coordinate object 
    var userCoordinate: CLLocationCoordinate2D!
    
    /// selected Store category 
    var selectedStoreCategory: StoreCategory!
    
    /// selected sorting option
    var selectedSortedOption: SortingOption = SortingOption(name: "distance", sortingKey: SortingKey.distance)
    
    /// selected pet type
    var selectedPetType: String?
    /// selected pet size
    var selectedPetSize: String?
    
    /// Store object that handles downloading of Store objects
    let dataStore = Backendless.sharedInstance().persistenceService.of(Store.self)
    
    
    /// 리뷰 아이디를 받아서 해당되는 스토어를 찾는 함수
    func findStoreByReview(_ reviewId: String, completionBlock: @escaping (_ store: Store?, _ error: String?) -> ()) {
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = "reviews.objectId = \'\(reviewId)\'"
        
        dataStore?.find(dataQuery, response: { (collection) in
            let store = collection?.data as! [Store]
            completionBlock(store[0], nil)
        }, error: { (Fault) in
            print("Server reported an error to retrive a store object: \(String(describing: Fault?.description))")
            completionBlock(nil, Fault?.description)
        })
        
    }
    
    /**
     스토어 카테고리에 맞춰서 스토어 객체를 다운로드하는 함수
     - parameter skip                   : 이미 그 전에 로딩이 끝나서 스킵한 객체의 수
     - parameter limit                  : 한 번에 쿼리로 불러오는 객체의 수
     - parameter selectedStoreCategory  : 사용자가 선택한 스토어 카테고리
     - parameter radius                 : 사용자 검색 반경, 현재는 2,000킬로, 수정 필요
     - parameter completionBlock        : called after the request is completed, returns the Store arrays
     
     */
    
    func downloadStores(skippingNumberOfObjects skip: NSNumber, limit: NSNumber, selectedStoreCategory: StoreCategory, radius: NSNumber, completionBlock: @escaping (_ storeObjects: [Store]?, _ error: String?) -> ()) {
        
        let dataQuery = BackendlessDataQuery()
        
        let queryOptions = QueryOptions()
        queryOptions.relationsDepth = 1
        
        // 쿼리조건 - 선택된 스토어 카테고리 및 2000km, 향후에 radius도 받아서 조정 가능
        dataQuery.whereClause = "StoreCategory[stores].objectId = \'\(selectedStoreCategory.objectId!)\' AND distance(\(userCoordinate.latitude), \(userCoordinate.longitude), location.latitude, location.longitude) < km(2000)"
        
        // 반려동물 타입에 관련해서 쿼리 조건 추가
        if (selectedPetType != "" && selectedPetType != nil) {
            dataQuery.whereClause = dataQuery.whereClause.appending("\(selectedPetType!)")
        }
        
        // 반려동물 크기 관련해서 쿼리 조건 추가
        if (selectedPetSize != "" && selectedPetSize != nil) {
            dataQuery.whereClause = dataQuery.whereClause.appending("\(selectedPetSize!)")
        }
        
        queryOptions.related = ["location"]
        queryOptions.pageSize = limit
        queryOptions.offset = skip
        dataQuery.queryOptions = queryOptions
        
        print("First Clause: \(dataQuery.whereClause!)")
        
        dataStore?.find(dataQuery, response: { (collection) in
            let sortedObjects = self.sortObjectsManuallyByDistance(collection?.data as! [Store])
            completionBlock(sortedObjects, nil)
        }, error: { (fault) in
            print(fault ?? "There is an error dowloading store list")
            completionBlock(nil, fault?.description)
        })
    }
    
    /**
     이건 예제로 작성했던 함수, 더 이상 쓰지 않음
     Download Store objects
    - parameter skip:   items to skip, that were loaded before
    - parameter limit:  max amount of Store objects to load
    - parameter completionBlock: called after the request is completed, returns the Store object
    */
    
    func downloadStores(skippingNumberOfObjects skip: NSNumber, limit: NSNumber, completionBlock: @escaping (_ storeObjects: [Store]?, _ error: String?) -> ()) {
        let query = BackendlessDataQuery()
        
        let queryOptions = QueryOptions()
        
        if selectedSortedOption.sortingKey != SortingKey.distance {
            queryOptions.sortBy = ["\(selectedSortedOption.sortingKey!.rawValue).desc"]
        }
        
        queryOptions.related = ["parentCategories", "location"]
        queryOptions.pageSize = limit
        queryOptions.offset = skip
        query.queryOptions = queryOptions
        
        // 반경 2000km로 쿼리
        query.whereClause = "distance(\(userCoordinate.latitude), \(userCoordinate.longitude), location.latitude, location.longitude ) < km(2000)"
        
        print("selected Store Category is: \(selectedStoreCategory!)")
        if let selectedStoreCategory = selectedStoreCategory {
            query.whereClause = "AND parentCategory.objectId = \'\(selectedStoreCategory.objectId!)\'"
        }
        
        print("Clause: \(query.whereClause)")
        print("Sorted by: \(queryOptions.sortBy)")
        
        dataStore?.find(query, response: { (collection) in
            let sortedObjects = self.sortObjectsManuallyByDistance(collection?.data as! [Store])
            completionBlock(sortedObjects, nil)
        }, error: { (fault) in
            print(fault ?? "There is an error here in downloading stores")
            completionBlock(nil, fault?.description)
        })
    }
    
    /**
     Sorts the stores objects manually by distance from the user's location. Only temporary fix until the backendless SDK is fixed to support proper distance based sorting
     
     - parameter storeObjects: objects to sort
     
     - returns: sorted objects
    */
    private func sortObjectsManuallyByDistance(_ storeObjects: [Store]) -> [Store] {
        var storeObjects = storeObjects
        if selectedSortedOption.sortingKey == SortingKey.distance {
            storeObjects.sort { (store1, store2) -> Bool in
                let location1 = locationForStore(store1)
                let location2 = locationForStore(store2)
                
                let userLocation = CLLocation(latitude: Double(userCoordinate.latitude), longitude: Double(userCoordinate.longitude))
                let distance1 = location1.distance(from: userLocation)
                let distance2 = location2.distance(from: userLocation)
                
                return distance1 < distance2
            }
        }
        
        return storeObjects
    }
 
    
    /**
     Creates a location
     
     - parameter store: store
     
     - returns: Location
     */
    
    fileprivate func locationForStore(_ store: Store) -> CLLocation {
        return CLLocation(latitude: Double(store.location!.latitude), longitude: Double(store.location!.longitude))
    }
    
    
}
