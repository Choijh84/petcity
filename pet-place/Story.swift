//
//  Story.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 15..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// An object which the Story contains
class Story: NSObject {
    
    var objectId: String?
    /// 공개할지말지 정하는 변수 - 기본 공개
    var isPublic = true
    
    /// 본문
    var bodyText: String?
    
    /// 글 쓴 사람
    var writer: BackendlessUser!
    
    /// 이미지 링크 배열
    var imageArray: String?
    
    /// time when the Story was created
    var created: Date!
    
    /// time when the Story was updated
    var updated: Date?

}
