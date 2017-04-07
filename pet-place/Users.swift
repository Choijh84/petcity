//
//  Users.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 26..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class Users: NSObject {
    
    var objectId: String!
    
    // 사용자 이메일 주소 - 유니크키
    var email: String!

    // 사용자 닉네임 - 닉네임부터 입력받고
    var nickname: String?
    // 사용자 이름 - 닉네임과 처음에는 동일하게 입력함
    var name: String?
    // 사용자 비번
    var password: String!
    
    // 사용자가 등록한 반려동물 프로필
    var petProfiles: [PetProfile]?
    // 사용자 전화번호
    var phoneNumber: String?
    // 사용자 프로필 사진 링크
    var profileURL: String?
    
    // 사용자가 소셜 통해서 가입한 경우의 정보
    var socialAccount: String?
    
}
