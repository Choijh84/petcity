//
//  StoreObject.swift
//  Pet-Hotels
//
//  Created by Owner on 2016. 12. 25..
//  Copyright © 2016년 TwistWorld. All rights reserved.
//

import UIKit
import CoreLocation

/// An object to store all the details of the Store that we want to display.
class Store: NSObject {

    var objectId: String?
    /// 스토어의 이름
    var name: String?
    /// 스토어 주소
    var address: String?
    /// 스토어 전화번호
    var phoneNumber: String?
    /// 스토어의 짧은 디스크립션
    var storeDescription: String?
    /// 서브 타이틀
    var storeSubtitle: String?
    /// 웹사이트
    var website: String?
    /// 현재 위치와의 거리
    var distance: Double?
    /// 지오 포인트
    var location: GeoPoint?
    /// 이메일 주소
    var emailAddress: String?
    /// 메인 이미지
    var imageURL: String?
    /// 사진 섹션에 배치되는 사진들 링크 - ','로 구분됨
    var imageArray: String?
    
    /// 서비스 카테고리 
    var serviceCategory: String? 
    /// 영업 시간
    var operationTime: String?
    /// 서비스 가능한 반려동물 품종 - 개, 고양이 등
    var serviceablePet: String?
    /// 반려동물 크기 - 대형, 중형, 소형 등
    var petSize: String?
    /// 가격 정보
    var priceInfo: String?
    /// 참고 사항
    var note: String?
    /// 좋아요 리스트에 추가한 사용자들 정보
    var favoriteList: [BackendlessUser] = []
    
    /// 몇 명의 사용자가 봤는지
    var hits: Int = 0
    /// 제휴 여부 
    var isAffiliated: Bool = false
    /// 인증 여부
    var isVerified: Bool = false
    /// 광고 여부
    var isAdvertising: Bool = false
    
    /// Number of reviews
    var reviewCount: Int = 0
    /// Average rating of reviews
    var reviewAverage: Double = 0.0
    /// Array of Review objects that connected with the Store
    var reviews: [Review] = [] {
        didSet {
            var average: Double = 0
            for review in reviews {
                average += review.rating.doubleValue
            }
            self.reviewAverage = Double(NSNumber(value: average / Double(reviews.count)))
            self.reviewCount = Int((reviews.count as NSNumber?)!)
        }
    }
    

    /**
     Creates a coordinate of the Store from the location object, if no location object is found, creates a 0,0 coordinate

     - returns: coordinate of the Store
     */
    func coordinate() -> CLLocationCoordinate2D {
        if location != nil {
            return CLLocationCoordinate2DMake(location!.latitude.doubleValue, location!.longitude.doubleValue)
        }
        return CLLocationCoordinate2DMake(0, 0)
    }

    /**
     Calculates the distance between the current location and the location of the store

     :param: currentLocation the user's current location
     */
    func calculateDistanceBetweenCurrentLocation(_ currentLocation: CLLocation?) {
        if (currentLocation != nil) {
            let coordinate = self.coordinate()
            distance = currentLocation!.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) as Double
            print("Distance: \(distance!)")
        }
    }
    
    func calculationDistanceBetweenCoordinates(_ pickedCoordinate: CLLocationCoordinate2D?) {
        let currentLocation = CLLocation(latitude: (pickedCoordinate?.latitude)!, longitude: (pickedCoordinate?.longitude)!)
        let coordinate = self.coordinate()
        distance = currentLocation.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) as Double
        print("Distance: \(distance!)")
    }

    /**
     Returns a formatted distance string, e.g.: 1,4 km away

     :return: NSString - formatted distance string
     */
    func distanceString() -> String! {
        if let distance = distance {
            if distance == 0 { // when distance is zero, return an empty string
                return ""
            }
            else {
                let temp = NSString.distanceStringWithValue(distance)
                return temp as String!
            }
        }
        return ""
    }
}
