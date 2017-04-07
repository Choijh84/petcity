//
//  NewsDownloader.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 28..
//  Copyright © 2017년 press.S. All rights reserved.
//

import Foundation
import UIKit

/// Object that downloads all the News objects 
class NewsDownloader: NSObject {

    /// Store object to manage download
    let dataStore = Backendless.sharedInstance().persistenceService.of(News.self)
    
    /// Date formatter to get the right NSDate object from a string 
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    
    /** 
     Downloads the News objects from the json object received
     
     - parameter completionBlock: returns the news objects and error object
     */
    
    func downloadNews(_ completionBlock: @escaping (_ news: [News]?, _ error: NSError?) -> ()) {
        let query = BackendlessDataQuery()
        
        let queryOptions = QueryOptions()
        queryOptions.sortBy = ["title"]
        query.queryOptions = queryOptions
        
        dataStore?.find(query, response: { (collection) in
            completionBlock(collection?.data as? [News], nil)
        }, error: { (error) in
            print("Server reported error when downloading news: \(error)")
            completionBlock(nil, nil)
        })
    }
    
}
