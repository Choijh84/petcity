//
//  PushNotis.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 5. 3..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class PushNotis: NSObject {

    var objectId: String?
    
    var from: String!
    
    var to: String!
    
    var bodyText: String?
    
    var isRead: Bool?
    
    var type: String?
    
    var typeId: String?
    
    /// time when the Story was created
    var created: Date!
    
    /// time when the Story was updated
    var updated: Date?

}
