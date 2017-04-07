//
//  Review.swift
//  Pet-Hotels
//
//  Created by Owner on 2016. 12. 25..
//  Copyright © 2016년 TwistWorld. All rights reserved.
//

import UIKit

 /// Review object that contains all the properties of a Store's review
class Review: NSObject {

    var objectId: String?
    /// body of the review
    var text: String!
    /// rating of the review (1-5)
    var rating: NSNumber!
    /// when the review was created
    var created: Date!
    /// Creator of the review
    var creator: BackendlessUser?
    /// Image url of the review
    var fileURL: String?
    /// 리뷰의 해당되는 스토어
    var store: Store?
    
    /// 달린 리플
    /// 리플 개수
    var commentNumbers = 0
    var comments: [ReviewComment] = [] {
        didSet {
            self.commentNumbers = Int(comments.count)
        }
    }
    
}
