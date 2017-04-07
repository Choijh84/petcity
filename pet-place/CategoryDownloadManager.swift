//
//  CategoryDownloadManager.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 3..
//  Copyright © 2017년 press.S. All rights reserved.
//

import Foundation

class CategoryDownloadManager: NSObject {
    
    /// Store object that handles downloading of StoreCategory objects
    let dataStore = Backendless.sharedInstance().persistenceService.of(StoreCategory.self)
    
    /**
        Downloads all the Category Objects 
 
     :param: completionBlock called after the request finished, returns the categories array and an errorMessage if any
     :param: errorMessage errorMessage to return if any
     */

    func downloadStoreCategories(_ completionBlock: @escaping (_ categories: [StoreCategory]?, _ errorMessage: NSString?) -> Void )  {
        let query = BackendlessDataQuery()
        
        let queryOptions = QueryOptions()
        queryOptions.sortBy = ["name"]
        query.queryOptions = queryOptions
        
        dataStore?.find(query, response: { (collection) in
            completionBlock((collection?.data as? [StoreCategory])!, nil)
        }, error: { (Fault) in
            completionBlock(nil, Fault?.description as NSString?)
        })
    }
    
}
