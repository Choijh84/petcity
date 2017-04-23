//
//  StoryLikes.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 4. 21..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// 스토리에서 라이크 누른걸 기억해두기
class StoryLikes: NSObject {

    // 오브젝트 아이디
    var objectId: String?
    
    // 라이크를 누른 유저의 objectId
    var by: String?
    
    // 라이크를 누른 스토리 objectId
    var to: String?
}
