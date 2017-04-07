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
    
    /// 어떤 스토리에 썼는지
    var review: Review!
    
    /// 글 쓴 사람
    var writer: BackendlessUser!
    
    /// time when the comment was created
    var created: Date!
    
    /// time when the comment was updated
    var updated: Date?
    
}
