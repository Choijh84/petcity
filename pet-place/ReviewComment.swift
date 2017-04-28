//
//  ReviewComment.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 4. 3..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class ReviewComment: NSObject {

    var objectId: String?
    
    /// 본문
    var bodyText: String?
    
    /// 어떤 리뷰에 썼는지, objectId를 저장
    var to: String!
    
    /// 글 쓴 사람, objectId를 저장
    var by: String!
    
    /// time when the comment was created
    var created: Date!
    
    /// time when the comment was updated
    var updated: Date?

    
}
