//
//  Comment.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 15..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// An object which the Story contains
class Comment: NSObject {
    
    var objectId: String?
    
    /// 본문
    var bodyText: String?
    
    /// 어떤 스토리에 썼는지
    var story: Story!
    
    /// 글 쓴 사람
    var writer: BackendlessUser!
    
    /// 라이크 누른 사람
    /// 라이크 개수
    var likeNumbers = 0
    var likeUsers: [BackendlessUser] = [] {
        didSet {
            self.likeNumbers = Int((likeUsers.count as NSNumber?)!)
        }
    }
    
    /// time when the comment was created
    var created: Date!
    
    /// time when the comment was updated 
    var updated: Date? 
}

