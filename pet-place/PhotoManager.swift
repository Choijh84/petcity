//
//  PhotoManager.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 4. 18..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import AZSClient
import Kingfisher

class PhotoManager: NSObject {

    var containerName = "store-images"
    var usingSAS = false
    
    // MARK: Azure Properties
    var blobs = [AZSCloudBlob]()
    var container : AZSCloudBlobContainer!
    var continuationToken : AZSContinuationToken?
    
    let dataStore = Backendless.sharedInstance().data.of(Store.ofClass())
    
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
     Azure Storage에 사진 1개를 업로드하고 그 URL을 completionBlock으로 리턴
     : param: SelectedFile 사진
     : param: 컨테이너 이름
     */
    func uploadBlobPhoto(selectedFile: UIImage, container: String, completionBlock: @escaping (_ success: Bool, _ fileURL: String?, _ errorMessage: String? ) -> ()) {
        let account = try! AZSCloudStorageAccount(fromConnectionString: azureConnectionString)
        
        let blobClient : AZSCloudBlobClient = account.getBlobClient()
        let blobContainer : AZSCloudBlobContainer = blobClient.containerReference(fromName: container)
        
        let objectID = Backendless.sharedInstance().userService.currentUser.objectId!
        let partOfID = objectID.substring(to: 8)
        
        blobContainer.createContainerIfNotExists(with: .blob, requestOptions: nil, operationContext: nil) { (error, success) in
            if error != nil {
                print("There is an error in creating container")
                completionBlock(false, nil, error?.localizedDescription)
            } else {
                // 여기서 이름 정하고
                let fileName = String(format: "\(String(describing: partOfID))_uploaded_%0.0f.png", Date().timeIntervalSince1970)
                let blob : AZSCloudBlockBlob = blobContainer.blockBlobReference(fromName: fileName)
                // 이미지 데이터를 생성
                let imageData = UIImagePNGRepresentation(selectedFile.compressImage(selectedFile))
                
                // 블롭에 데이터를 업로드, 파일 이름은 우리가 정한대로 들어간다
                blob.upload(from: imageData!, completionHandler: { (error) in
                    if error != nil {
                        print("Upload Error: \(error.localizedDescription)")
                        completionBlock(false, nil, error.localizedDescription)
                    } else {
                        print("Upload Success to Azure")
                        let url = "https://petcity.blob.core.windows.net/\(container)/\(fileName)"
                        print("This is uploaded photo url: \(url)")
                        completionBlock(true, url, nil)
                    }
                })
            }
        }
    }
    
    /**
     Azure Storage에 사진 복수를 업로드하고 그러고 이미지들의 연결한 URL을 completionBlock으로 return
     */
    func uploadBlobPhotos(selectedImages: [UIImage]?, container: String, completionBlock: @escaping (_ succuess: Bool,_ fileURL: String?,_ errorMessage: String?) -> ()) {
        var totalFileURL = ""
        let myGroup = DispatchGroup()
        let account = try! AZSCloudStorageAccount(fromConnectionString: azureConnectionString)
        
        let blobClient : AZSCloudBlobClient = account.getBlobClient()
        let blobContainer : AZSCloudBlobContainer = blobClient.containerReference(fromName: container)
        
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
                            print("Upload Success to Azure to \(container) Blob")
                            let url = "https://petcity.blob.core.windows.net/\(container)/\(fileName),"
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
     Azure Storage에 지정된 파일 url을 삭제하는 함수
     */
    
    func deleteStoryFile(selectedUrl: String, completionblock: @escaping (_ success: Bool, _ errorMessage: String?) -> ()) {
        let account = try! AZSCloudStorageAccount(fromConnectionString: azureConnectionString)
        
        let blobClient : AZSCloudBlobClient = account.getBlobClient()
        let blobContainer : AZSCloudBlobContainer = blobClient.containerReference(fromName: "story-images")
        
        // 컨테이너 이름까지는 필요없음
        let fileName = selectedUrl.replacingOccurrences(of: "https://petcity.blob.core.windows.net/story-images/", with: "")
        print("지울 파일 경로: \(selectedUrl)")
        print("지울 파일 이름: \(fileName)")
        let blockBlob : AZSCloudBlockBlob = blobContainer.blockBlobReference(fromName: fileName)
        
        blockBlob.delete { (error) in
            if error != nil {
                print("Error in delete blob: \(String(describing: error?.localizedDescription))")
            } else {
                print("Delete success")
            }
        }
    }
}
