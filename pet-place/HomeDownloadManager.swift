//
//  HomeDownloadManager.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 9..
//  Copyright © 2017년 press.S. All rights reserved.
//

import Foundation

/// Custom Class which can download the contents in the home screen
class HomeDownloadManager: NSObject {
    
    /// Store object that handles downloading of FrontPromotion objects
    let dataStore1 = Backendless.sharedInstance().persistenceService.of(FrontPromotion.self)
    
    let dataStore2 = Backendless.sharedInstance().persistenceService.of(Recommendations.self)
    
    /**
        Downloads all the FrontPromotion objects 
     */
    func downloadFrontPromotions(_ completionBlock: @escaping (_ fronts: [FrontPromotion]?, _ errorMessage: NSString?) -> Void) {
        let query = BackendlessDataQuery()
        
        dataStore1?.find(query, response: { (collection) in
            completionBlock((collection?.data as! [FrontPromotion]), nil)
        }, error: { (Fault) in
            completionBlock(nil, Fault?.description as NSString?)
        })
    }
    
    /**
     Downloads all the Recommendations Objects
     
     :param: completionBlock called after the request finished, returns the categories array and an errorMessage if any
     :param: errorMessage errorMessage to return if any
     */
    
    func downloadRecommendStores(_ completionBlock: @escaping (_ categories: [Recommendations]?, _ errorMessage: NSString?) -> Void )  {
        let query = BackendlessDataQuery()
        
        dataStore2?.find(query, response: { (collection) in
            let storeArray = collection?.data as! [Recommendations]
            completionBlock((storeArray), nil)
        }, error: { (Fault) in
            completionBlock(nil, Fault?.description as NSString?)
        })
    }
    
}
