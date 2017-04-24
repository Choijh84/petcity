//
//  StoryComment.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 4. 24..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

// 스토리에 달린 코멘트들 
class StoryComment: NSObject {

    var objectId: String?
    
    /// 본문
    var bodyText: String!
    
    /// 어떤 스토리에 썼는지, objectId를 저장
    var to: String!
    
    /// 글 쓴 사람, objectId를 저장
    var by: String!
    
    /// time when the comment was created
    var created: Date!
    
    /// time when the comment was updated
    var updated: Date?
    
}
