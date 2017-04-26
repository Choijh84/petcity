
//
//  StoryDownloadManager.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 15..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import AZSClient

class StoryDownloadManager: NSObject {

    // Azure Settings
    var containerName = "story-images"
    var usingSAS = false
    
    // MARK: Azure Properties
    var blobs = [AZSCloudBlob]()
    var container : AZSCloudBlobContainer!
    var continuationToken : AZSContinuationToken?
    
    /// Store object that handles downloading of Story objects
    let dataStore1 = Backendless.sharedInstance().persistenceService.of(Story.self)
    /// Store object that handles downloading of Comment objects
    let dataStore2 = Backendless.sharedInstance().data.of(Comment.self)
    
    let dataStore3 = Backendless.sharedInstance().data.of(StoryComment.ofClass())
    
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
       업로드 스토리
     - parameter text:            스토리 본문
     - parameter fileURL:         ','로 구분되는 url를 업로드하는 파라미터, 이미지 return
     - parameter completionBlock: called after the story has been uploaded
     - parameter error:           error if any
    */
    func uploadNewStory(_ text: String, fileURL: String?, completionBlock: @escaping (_ completed: Bool, _ errorMessage: String?) -> ()) {
        
        let newStory = Story()
        newStory.bodyText = text
        newStory.writer = UserManager.currentUser()
        newStory.imageArray = fileURL
        
        dataStore1?.save(newStory, response: { (response) in
            print("Story has beed added: \(String(describing: response))")
            completionBlock(true, nil)
        }, error: { (Fault) in
            print("Server reported an error: \(String(describing: Fault?.description))")
            completionBlock(false, Fault?.description)
        })
    }
    
    /**
     Downloads all the Story objects
     */
    func downloadStory(_ user: BackendlessUser?, _ completionBlock: @escaping (_ story: [Story]?, _ errorMessage: NSString?) -> Void) {
        let query = BackendlessDataQuery()
        let queryOptions = QueryOptions()
        
        // 이건 파라미터에 유저가 있어서 그 유저의 스토리만 불러 들일 때 - 마이스토리에 사용
        if let user = user {
            query.whereClause = "Story[writer].objectId = \'\(user.objectId)\'"
        }
        
        // sort option = 만들어진 시간 순 - 향후 업데이트 순으로 바꿔야할 수도....
        queryOptions.sortBy = ["created desc"]
        query.queryOptions = queryOptions
        
        dataStore1?.find(query, response: { (collection) in
            completionBlock((collection?.data as! [Story]), nil)
        }, error: { (Fault) in
            completionBlock(nil, Fault?.description as NSString?)
        })
    }
    
    /**
     스토리를 페이지로 나눠서 다운로드 받을 수 있게 해주는 함수
     : param: skippingNumberOfObjects, skip 스킵할 객체의 숫자, 이미 다운로드 받은 수
     : param: limit 다운로드 받을 객체의 수
     : param: user, 스토리 중 나중에 그 유저가 적은 스토리만 불러올 때
     : param: completionBlock
     */
    func downloadStoryByPage(skippingNumberOfObjects skip: NSNumber, limit: NSNumber, user: BackendlessUser?, _ completionBlock: @escaping (_ story: [Story]?, _ errorMessage: String?) -> Void) {
        let query = BackendlessDataQuery()
        let queryOptions = QueryOptions()
        
        // 이건 파라미터에 유저가 있어서 그 유저의 스토리만 불러 들일 때 - 마이스토리에 사용
        if let user = user {
            query.whereClause = "Story[writer].objectId = \'\(user.objectId)\'"
        }
        
        queryOptions.sortBy = ["created desc"]
        queryOptions.pageSize = limit
        queryOptions.offset = skip
        query.queryOptions = queryOptions
        
        dataStore1?.find(query, response: { (collection) in
            completionBlock((collection?.data as! [Story]), nil)
        }, error: { (Fault) in
            completionBlock(nil, Fault?.description)
        })
    }
    
    /// 스토리 삭제하기 - param: storyID
    func deleteStory(_ storyID: String, completionBlock: @escaping (_ success: Bool, _ errorMessage: String?) -> ()) {
        
        dataStore1?.findID(storyID, response: { (response) in
            let responseStory = response as! Story
            if let imageArray = responseStory.imageArray?.components(separatedBy: ",") {
                
                for image in imageArray {
                    // 관련 사진 지우기
                    PhotoManager().deleteStoryFile(selectedUrl: image, completionblock: { (success, error) in
                        if success {
                            
                        } else {
                            print("사진 삭제 에러: \(String(describing: error?.description))")
                        }
                    })
                }
                
                // 스토리 삭제하기
                self.dataStore1?.removeID(storyID, response: { (success) in
                    print("스토리 삭제 완료 \(String(describing: success))")
                    completionBlock(true, nil)
                }, error: { (Fault) in
                    print("스토리 삭제에 문제가 있습니다: \(String(describing: Fault?.description))")
                    completionBlock(false, Fault?.description)
                })
            }
            
        }, error: { (Fault) in
            print("스토리 로딩에 문제가 있습니다: \(String(describing: Fault?.description))")
            completionBlock(false, Fault?.description)
        })
        
    }
    
    /**
     업로드 코멘트
     - parameter text:            코멘트 본문
     - parameter story:           해당되는 스토리
     - parameter completionBlock: called after the comment has been uploaded
     - parameter error:           error if any
     */
    
    func uploadNewComment(_ text: String, _ story: Story, completionBlock: @escaping (_ completed: Bool, _ errorMessage: String?) -> ()) {
        
        // 새로운 코멘트 생성
        let newStoryComment = StoryComment()
        newStoryComment.bodyText = text
        newStoryComment.by = UserManager.currentUser()!.objectId! as String!
        newStoryComment.to = story.objectId!
        
        // 코멘트 클래스 - dataStore3
        dataStore3?.save(newStoryComment, response: { (response) in
            print("Comment has beed added: \(String(describing: response))")
            completionBlock(true, nil)
        }, error: { (Fault) in
            print("Server reported an error: \(String(describing: Fault?.description))")
            completionBlock(false, Fault?.description)
        })
        
        /*
        // 새로운 코멘트 생성
        let newComment = Comment()
        newComment.bodyText = text
        newComment.writer = UserManager.currentUser()
        newComment.likeNumbers = 0
        
        // 코멘트의 스토리 프로퍼티에도 배당
        newComment.story = story
        newComment.created = Date()
        
        // 스토리의 코멘트 배열에도 추가해줘야 함
        story.comments.append(newComment)
        
        // 코멘트 클래스 - dataStore2
        dataStore2?.save(newComment, response: { (response) in
            print("Comment has beed added: \(String(describing: response))")
            // 저장되면 스토리도 저장하면 안됨, 연관된 인스턴스를 생성하면 
//            self.dataStore1?.save(story, response: { (response) in
//                print("Comment has beed added to Story: \(String(describing: response))")
//                completionBlock(true, nil)
//            }, error: { (Fault) in
//                print("Server reported an error: \(String(describing: Fault?.description))")
//                completionBlock(false, Fault?.description)
//            })
            completionBlock(true, nil)
        }, error: { (Fault) in
            print("Server reported an error: \(String(describing: Fault?.description))")
            completionBlock(false, Fault?.description)
        })
        */
    }
    
    /// 코멘트를 삭제하는 함수
    func deleteComment(_ comment: StoryComment!, completionBlock: @escaping (_ completed: Bool, _ errorMessage: String?) -> ()) {
        
        dataStore3?.remove(comment, response: { (response) in
            completionBlock(true, nil)
        }, error: { (Fault) in
            completionBlock(false, Fault?.description)
        })
        
        /*
         // comment 클래스를 바꿈
        dataStore2?.remove(comment, response: { (response) in
            completionBlock(true, nil)
        }, error: { (Fault) in
            completionBlock(false, Fault?.description)
        })
        */
    }
    
    /**
     코멘트를 다운로드하는 메소드였는데 현재 사용안할 듯 
     
     :param: story - which Story links with the comments
     :param: completionBlock called after the request finished, returns the comment array and an errorMessage if any
     :param: errorMessage errorMessage to return if any
     */
    
    func downloadComments(_ story: Story!, _ completionBlock: @escaping (_ response: [StoryComment]?, _ errorMessage: NSString?) -> Void )  {
        
        let storyID = story.objectId!
        
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = "to = '\(storyID)'"
        
        let queryOptions = QueryOptions()
        queryOptions.sortBy = ["created desc"]
        dataQuery.queryOptions = queryOptions
        
        dataStore3?.find(dataQuery, response: { (collection) in
            let commentArray = collection?.data as! [StoryComment]
            completionBlock(commentArray, nil)
        }, error: { (Fault) in
            completionBlock(nil, Fault?.description as NSString?)
        })
        
        
        // response class change, from Comment to StoryComment
        /*
        let dataquery = BackendlessDataQuery()
    
        // sort option = 만들어진 시간 순 - 향후 업데이트 순으로 바꿔야할 수도....
        let queryOptions = QueryOptions()
        queryOptions.sortBy = ["created desc"]
        dataquery.queryOptions = queryOptions
        
        dataStore2?.find(dataquery, response: { (collection) in
            let commentArray = collection?.data as! [Comment]
            completionBlock((commentArray), nil)
        }, error: { (Fault) in
            completionBlock(nil, Fault?.description as NSString?)
        })
        */
    }
    
    /**
     Azure Storage에 사진 복수를 업로드하고 그러고 이미지들의 연결한 URL을 completionBlock으로 return
     */
    func uploadBlobPhotos(selectedFiles: [UIImage]?, completionBlock: @escaping (_ succuess: Bool,_ fileURL: String?,_ errorMessage: String?) -> ()) {
        var totalFileURL = ""
        let myGroup = DispatchGroup()
        let account = try! AZSCloudStorageAccount(fromConnectionString: azureConnectionString)
        
        let blobClient : AZSCloudBlobClient = account.getBlobClient()
        let blobContainer : AZSCloudBlobContainer = blobClient.containerReference(fromName: containerName)
        
        if let images = selectedFiles {
            for var i in 0..<images.count {
                myGroup.enter()
                blobContainer.createContainerIfNotExists(with: .blob, requestOptions: nil, operationContext: nil) { (error, success) in
                    // 여기서 이름 정하고
                    let fileName = String(format: "uploaded_%0.0f\(i).png", Date().timeIntervalSince1970)
                    let blob : AZSCloudBlockBlob = blobContainer.blockBlobReference(fromName: fileName)
                    // 이미지 데이터를 생성
                    let imageData = UIImagePNGRepresentation(images[i].compressMore(images[i]))
                    
                    blob.upload(from: imageData!, completionHandler: { (error) in
                        if error != nil {
                            print("Upload Error on \(i): \(error.localizedDescription)")
                            completionBlock(false, nil, error.localizedDescription)
                        } else {
                            print("Upload Success to Azure to Story Blob")
                            let url = "https://petcity.blob.core.windows.net/story-images/\(fileName),"
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
    
    
    /// 백엔드리스에 다수의 이미지를 업로드, 그러고 이미지들의 연결한 URL을 completionBlock으로 return
    func uploadPhotos(selectedImages: [UIImage]?, completionBlock: @escaping (_ completion: Bool, _ fileURL: String, _ errorMessage: String?) -> ()) {
        var totalFileURL = ""
        let myGroup = DispatchGroup()
        
        if let images = selectedImages {
            for var i in 0..<images.count {
                myGroup.enter()
                let fileName = String(format: "%0.0f\(i).jpeg", Date().timeIntervalSince1970)
                let filePath = "storyImages/\(fileName)"
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
    
    
}
