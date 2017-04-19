//
//  ReviewManager.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 20..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import AZSClient

/// Object that helps to download reviews for the selected Shop
class ReviewManager: NSObject {
    
    var containerName = "review-images"
    var usingSAS = false
    
    // MARK: Azure Properties
    var blobs = [AZSCloudBlob]()
    var container : AZSCloudBlobContainer!
    var continuationToken : AZSContinuationToken?
    
    let backendless = Backendless.sharedInstance()
    
    /// Store object that handles downloading of Reviews
    let dataStore = Backendless.sharedInstance().data.of(Review.self)
    
    /// 리뷰의 코멘트 dataStore
    let dataStore2 = Backendless.sharedInstance().data.of(ReviewComment.ofClass())
    
    
    // MARK: Initializer
    override init() {
        if !usingSAS {
            let storageAccount : AZSCloudStorageAccount
            try! storageAccount = AZSCloudStorageAccount(fromConnectionString: azureConnectionString)
            
            let blobClient = storageAccount.getBlobClient()
            self.container = blobClient?.containerReference(fromName: containerName)
            
            let condition = NSCondition()
            var containerCreated = false
            
            self.container.createContainerIfNotExists { (error, created) in
                condition.lock()
                containerCreated = true
                condition.signal()
                condition.unlock()
            }
            
            condition.lock()
            while (!containerCreated) {
                condition.wait()
            }
            condition.unlock()
        }
        self.continuationToken = nil
        super.init()
    }
    
    /**
     Uploads a new review, 단수의 이미지를 업로드하는 함수
     */
    func uploadNewReview(_ text: String, selectedFile: UIImage?, rating: NSNumber, store: Store, completionBlock: @escaping (_ completed: Bool, _ store: Store?, _ errorMessage: String?)->()) {
        if let selectedFile = selectedFile {
            let fileName = String(format: "%0.0f.jpeg", Date().timeIntervalSince1970)
            let filePath = "reviewImages/\(fileName)"
            let content = UIImageJPEGRepresentation(selectedFile.compressImage(selectedFile), 1.0)
            
            Backendless.sharedInstance().fileService.saveFile(filePath, content: content, response: { (uploadedFile) in
                let fileURL = uploadedFile?.fileURL
                self.uploadNewReview(text, fileURL: fileURL, rating: rating, store: store, completionBlock: completionBlock)
            }, error: { (fault) in
                print(fault.debugDescription)
                completionBlock(false, nil, fault?.description)
            })
        } else {
            uploadNewReview(text, fileURL: nil, rating: rating, store: store, completionBlock: completionBlock)
        }
    }
    
    /**
     Azure Storage에 사진 복수를 업로드하고 그러고 이미지들의 연결한 URL을 completionBlock으로 return
     */
    func uploadBlobPhotos(selectedImages: [UIImage]?, completionBlock: @escaping (_ succuess: Bool,_ fileURL: String?,_ errorMessage: String?) -> ()) {
        var totalFileURL = ""
        let myGroup = DispatchGroup()
        let account = try! AZSCloudStorageAccount(fromConnectionString: azureConnectionString)
        
        let blobClient : AZSCloudBlobClient = account.getBlobClient()
        let blobContainer : AZSCloudBlobContainer = blobClient.containerReference(fromName: containerName)
        
        if let images = selectedImages {
            for var i in 0..<images.count {
                myGroup.enter()
                blobContainer.createContainerIfNotExists(with: .blob, requestOptions: nil, operationContext: nil) { (error, success) in
                    // 여기서 이름 정하고
                    let fileName = String(format: "uploaded_%0.0f\(i).png", Date().timeIntervalSince1970)
                    let blob : AZSCloudBlockBlob = blobContainer.blockBlobReference(fromName: fileName)
                    // 이미지 데이터를 생성
                    let imageData = UIImagePNGRepresentation(images[i].compressImage(images[i]))
                    
                    blob.upload(from: imageData!, completionHandler: { (error) in
                        if error != nil {
                            print("Upload Error on \(i): \(error.localizedDescription)")
                            completionBlock(false, nil, error.localizedDescription)
                        } else {
                            print("Upload Success to Azure to Review Blob")
                            let url = "https://petcity.blob.core.windows.net/review-images/\(fileName),"
                            totalFileURL.append(url)
                            i = i+1
                            print("totalFileURL: \(totalFileURL)")
                            myGroup.leave()
                        }
                    })
                }
            }
            
            myGroup.notify(queue: DispatchQueue.main, execute: {
                let finalURL = String(totalFileURL.characters.dropLast())
                completionBlock(true, finalURL, nil)
                
            })
            
        }
    }
    
    /**
     리뷰의 사진을 업로드하는 함수, completionBlock을 통해 fileURL 문자열을 return 함 - Backendless 에
     현재는 사용 안 함
 
    func uploadPhotos(selectedImages: [UIImage]?, completionBlock: @escaping (_ completion: Bool, _ fileURL: String, _ errorMessage: String?) -> ()) {
        var totalFileURL = ""
        let myGroup = DispatchGroup()
        
        if let images = selectedImages {
            for var i in 0..<images.count {
                myGroup.enter()
                let fileName = String(format: "%0.0f\(i).jpeg", Date().timeIntervalSince1970)
                let filePath = "reviewImages/\(fileName)"
                let content = UIImageJPEGRepresentation(images[i].compressImage(images[i]), 1.0)
                
                Backendless.sharedInstance().fileService.saveFile(filePath, content: content, response: { (uploadedFile) in
                    let fileURL = uploadedFile?.fileURL
                    totalFileURL.append(fileURL!+",")
                    i = i+1
                    myGroup.leave()
                }, error: { (fault) in
                    completionBlock(false, "", fault?.description)
                })
            }
            myGroup.notify(queue: DispatchQueue.main, execute: { 
                let finalURL = String(totalFileURL.characters.dropLast())
                completionBlock(true, finalURL, nil)
            })
        }
    }
    */
    
    /**
     Uploads a new review, 파일 url(단수 또는 복수일 수도 있음)
     
     - parameter text:            리뷰 본문
     - parameter fileURL:         ','로 구분되는 url를 업로드하는 파라미터
     - parameter rating:          리뷰 평점
     - parameter store:           리뷰의 대상이 되는 store object
     - parameter completionBlock: called after the review has been uploaded
     - parameter error:           error if any
     */
    func uploadNewReview(_ text: String, fileURL: String?, rating: NSNumber, store: Store, completionBlock: @escaping (_ completed: Bool, _ store: Store?, _ errorMessage: String?) -> ()) {
        let review = Review()
        review.rating = rating
        review.text = text
        review.fileURL = fileURL
        review.creator = UserManager.currentUser()
        review.store = store
        
        var error: Fault?
        let result = Backendless.sharedInstance().data.save(store) as? Store
        if error == nil {
            print("Review havs been updated: \(String(describing: result))")
            
            result?.reviewCount = ((result?.reviews.count)!+1)
            result?.reviews.append(review)
            
            _ = Backendless.sharedInstance().data.save(result, response: { (response) in
                print("Review relationship has been updated")
                completionBlock(true, result, nil)
            }, error: { (Fault) in
                print("Server reported an error: \(String(describing: Fault?.description))")
            })
            
        } else {
            print("Server reported an error: \(String(describing: error))")
            completionBlock(false, nil, error?.description)
        }
    }
    
    /**
     Downloads reviews for the selected Store, returns the number of reviews and the average rating value
     
     - parameter storeObject:     Store Object that we need the reviews for
     - parameter completionBlock: completionBlock after it completes. Return the reviews, their count, and average value
     - parameter error:           error if any
     */
    func downloadReviewCountsAndReviewsForStore(_ storeObject: Store, completionBlock: @escaping (_ reviews: [Review]?, _ error: NSError?) -> ()) {
        let query = BackendlessDataQuery()
        
        let queryOptions = QueryOptions()
        queryOptions.sortBy = ["created desc"]
        query.queryOptions = queryOptions
        
        // Download only the reviews that are related to the selected Store
        query.whereClause = "Store[reviews].objectId = \'\(storeObject.objectId!)\'"
        
        dataStore?.find(query, response: { (collection) in
            completionBlock(collection?.data as? [Review], nil)
        }, error: { (fault) in
            print(fault?.description ?? "Error")
            completionBlock(nil, nil)
        })
    }
    
    func downloadReviewCountAndReviewByPage(skippingNumberOfObject skip: NSNumber, limit: NSNumber, storeObject: Store, completionBlock: @escaping (_ reviews: [Review]?, _ error: String?) -> ()) {
        let dataQuery = BackendlessDataQuery()
        let queryOptions = QueryOptions()
        
        queryOptions.sortBy = ["created desc"]
        queryOptions.pageSize = limit
        queryOptions.offset = skip
        dataQuery.queryOptions = queryOptions
        
        dataQuery.whereClause = "Store[reviews].objectId = \'\(storeObject.objectId!)\'"
        
        dataStore?.find(dataQuery, response: { (collection) in
            completionBlock(collection?.data as? [Review], nil)
        }, error: { (Fault) in
            print(Fault?.description ?? "Error")
            completionBlock(nil, Fault?.description)
        })
        
    }
    
    /**
     리뷰를 지역별로 다운로드 받을 수 있게 하는 함수
     */
    func downloadReview(_ location: String?, _ completionBlock: @escaping (_ review: [Review]?, _ errorMessage: NSString?) -> Void) {
        let query = BackendlessDataQuery()
        let queryOptions = QueryOptions()
        
        // 이건 파라미터에 위치가 정해져서 
        if let location = location {
            query.whereClause = "Review[location] = \'\(location)\'"
        }
        
        // sort option = 만들어진 시간 순 - 향후 업데이트 순으로 바꿔야할 수도....
        queryOptions.sortBy = ["created desc"]
        query.queryOptions = queryOptions
        
        dataStore?.find(query, response: { (collection) in
            completionBlock((collection?.data as? [Review]), nil)
        }, error: { (Fault) in
            completionBlock(nil, Fault?.description as NSString?)
        })
    }
    
    /**
     지역 리뷰를 페이지로 나눠서 받을 수 있게 해주는 함수
     : param: skippingNumberOfObjects, skip 스킵할 객체의 숫자, 이미 다운로드 받은 수
     : param: location, 향후 위치가 정해지면 쿼리에 반영
     : param: limit: 다운로드 받을 객체의 수 
     : param: completionBlock
    */
    func downloadReviewPage(skippingNumberOfObects skip: NSNumber, location: String?, limit: NSNumber, _ completionBlock: @escaping (_ review: [Review]?, _ errorMessage: String?) -> Void) {
        let dataQuery = BackendlessDataQuery()
        let queryOption = QueryOptions()
        // queryOption.related = ["store", "store.address"]
        
        // 향후 위치가 정해지는 쿼리를 하는 경우
        if let location = location {
            switch location {
            case "서울 강남":
                dataQuery.whereClause = "store.address LIKE \'%%서울시 강남구%%\' OR store.address LIKE \'%%서울시 서초구%%\' OR store.address LIKE \'%%서울시 송파구%%\' OR store.address LIKE \'%%서울시 강동구%%\' OR store.address LIKE \'%%서울시 관악구%%\' OR store.address LIKE \'%%서울시 동작구%%\' OR store.address LIKE \'%%서울시 금천구%%\' OR store.address LIKE \'%%서울시 영등포구%%\' OR store.address LIKE \'%%서울시 구로구%%\' OR store.address LIKE \'%%서울시 양천구%%\' OR store.address LIKE \'%%서울시 강서구%%\' OR store.address LIKE \'%%서울특별시 강남구%%\' OR store.address LIKE \'%%서울특별시 서초구%%\' OR store.address LIKE \'%%서울특별시 송파구%%\' OR store.address LIKE \'%%서울특별시 강동구%%\' OR store.address LIKE \'%%서울특별시 관악구%%\' OR store.address LIKE \'%%서울특별시 동작구%%\' OR store.address LIKE \'%%서울특별시 금천구%%\' OR store.address LIKE \'%%서울특별시 영등포구%%\' OR store.address LIKE \'%%서울특별시 구로구%%\' OR store.address LIKE \'%%서울특별시 양천구%%\' OR store.address LIKE \'%%서울특별시 강서구%%\'"
            case "서울 강북":
                dataQuery.whereClause = "store.address LIKE \'%%서울시 마포구%%\' OR store.address LIKE \'%%서울시 서대문구%%\' OR store.address LIKE \'%%서울시 은평구%%\' OR store.address LIKE \'%%서울시 종로구%%\' OR store.address LIKE \'%%서울시 중구%%\' OR store.address LIKE \'%%서울시 용산구%%\' OR store.address LIKE \'%%서울시 성북구%%\' OR store.address LIKE \'%%서울시 강북구%%\' OR store.address LIKE \'%%서울시 성동구%%\' OR store.address LIKE \'%%서울시 동대문구%%\' OR store.address LIKE \'%%서울시 광진구%%\' OR store.address LIKE \'%%서울시 중랑구%%\' OR store.address LIKE \'%%서울시 노원구%%\' OR store.address LIKE \'%%서울시 도봉구%%\' OR store.address LIKE \'%%서울특별시 마포구%%\' OR store.address LIKE \'%%서울특별시 서대문구%%\' OR store.address LIKE \'%%서울특별시 은평구%%\' OR store.address LIKE \'%%서울특별시 종로구%%\' OR store.address LIKE \'%%서울특별시 중구%%\' OR store.address LIKE \'%%서울특별시 용산구%%\' OR store.address LIKE \'%%서울특별시 성북구%%\' OR store.address LIKE \'%%서울특별시 강북구%%\' OR store.address LIKE \'%%서울특별시 성동구%%\' OR store.address LIKE \'%%서울특별시 동대문구%%\' OR store.address LIKE \'%%서울특별시 광진구%%\' OR store.address LIKE \'%%서울특별시 중랑구%%\' OR store.address LIKE \'%%서울특별시 노원구%%\' OR store.address LIKE \'%%서울특별시 도봉구%%\'"
            case "인천":
                dataQuery.whereClause = "store.address LIKE \'%%인천광역시%%\' OR store.address LIKE \'%%인천시%%\'"
            case "대구":
                dataQuery.whereClause = "store.address LIKE \'%%대구광역시%%\' OR store.address LIKE \'%%대구시%%\'"
            case "부산":
                dataQuery.whereClause = "store.address LIKE \'%%부산광역시%%\' OR store.address LIKE \'%%부산시%%\'"
            case "제주":
                dataQuery.whereClause = "store.address LIKE \'%%제주특별자치도%%\' OR store.address LIKE \'%%제주도%%\'"
            case "대전":
                dataQuery.whereClause = "store.address LIKE \'%%대전광역시%%\' OR store.address LIKE \'%%대전시%%\'"
            case "광주":
                dataQuery.whereClause = "store.address LIKE \'%%광주광역시%%\' OR store.address LIKE \'%%광주시%%\'"
            case "울산":
                dataQuery.whereClause = "store.address LIKE \'%%울산광역시%%\' OR store.address LIKE \'%%울산시%%\'"
            case "세종":
                dataQuery.whereClause = "store.address LIKE \'%%세종특별자치시%%\' OR store.address LIKE \'%%세종시%%\'"
            case "경기도":
                dataQuery.whereClause = "store.address LIKE \'%%경기도%%\'"
            case "강원도":
                dataQuery.whereClause = "store.address LIKE \'%%강원도%%\'"
            case "경상도":
                dataQuery.whereClause = "store.address LIKE \'%%경상도%%\' OR store.address LIKE \'%%경상남도%%\' OR store.address LIKE \'%%경상북도%%\'"
            case "전라도":
                dataQuery.whereClause = "store.address LIKE \'%%전라도%%\' OR store.address LIKE \'%%전라남도%%\' OR store.address LIKE \'%%전라북도%%\'"
            case "충청도":
                dataQuery.whereClause = "store.address LIKE \'%%충청도%%\' OR store.address LIKE \'%%충청남도%%\' OR store.address LIKE \'%%충청북도%%\'"
            case "모두 보기":
                dataQuery.whereClause = nil
            default:
                print("There is no location")
            }
            // dataQuery.whereClause = "Review[location] = \'\(location)\'"
        }
        
        queryOption.sortBy = ["created desc"]
        queryOption.pageSize = limit
        queryOption.offset = skip
        dataQuery.queryOptions = queryOption
        
        dataStore?.find(dataQuery, response: { (collection) in
            dump(collection)
            completionBlock(collection?.data as? [Review], nil)
        }, error: { (Fault) in
            print("There is an error dowloading review list: \(String(describing: Fault?.description))")
            completionBlock(nil, Fault?.description)
        })
    }
    
    /**
    업로드 코멘트
    - parameter text:            코멘트 본문
    - parameter review:          해당되는 리뷰
    - parameter completionBlock: called after the comment has been uploaded
    - parameter error:           error if any
    */
    
    func uploadNewCommment(_ text: String, _ review: Review, completionBlock: @escaping (_ completed: Bool, _ errorMessage: String?) -> ()) {
        // 새로운 리뷰 코멘트 생성
        let newComment = ReviewComment()
        newComment.bodyText = text
        newComment.writer = UserManager.currentUser()
        
        // 리뷰코멘트의 프로퍼티에도 배당
        newComment.review = review
        newComment.created = Date()
        
        // 리뷰의 코멘트 배열에도 추가
        review.comments.append(newComment)
        
        dataStore2?.save(newComment, response: { (response) in
            print("ReviewComment has beed added: \(String(describing: response))")
            completionBlock(true, nil)
        }, error: { (Fault) in
            print("Server reported an error: \(String(describing: Fault?.description))")
            completionBlock(false, Fault?.description)
        })
    }
    
}
