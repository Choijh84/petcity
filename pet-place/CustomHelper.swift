//
//  CustomHelper.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 4. 15..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class CustomHelper: NSObject {

}

extension UIImage {
    
    /**
     이미지의 실제크기를 보고 최대 너비 800, 최대 높이 600으로 비율을 계산해서 압축해주는 함수
     iphone7 plus: 1080 x 1920 pixels
     
     : param: image
     */
    func compressImage(_ image: UIImage) -> UIImage {
        var actualHeight = image.size.height
        var actualWidth = image.size.width
        
        let data = UIImageJPEGRepresentation(image, 1)
        let imageSize = data?.count
        
        print("This is actual height and width: \(actualHeight) & \(actualWidth)")
        print("size of image in KB: %f , \(imageSize!/1024)")
        
        let maxHeight: CGFloat = 600
        let maxWidth: CGFloat = 800
        
        var imgRatio = actualWidth/actualHeight
        let maxRatio = maxWidth/maxHeight
        
        let compressionQuality: CGFloat = 0.9
        
        // 실제 높이가 최대 높이보다 크거나 또는 실제 너비가 최대 너비보다 크면
        if (actualHeight > maxHeight) || (actualWidth > maxWidth) {
            if (imgRatio < maxRatio) {
                // 실제 비율이 최대 비율보다 작다면
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            } else if (imgRatio > maxRatio) {
                // 실제 비율이 최대 비육보다 크다면
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            } else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        
        let rect = CGRect(x: 0, y: 0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImageJPEGRepresentation(image!, compressionQuality)
        let compressedSize = imageData?.count
        print("This is compressed height and width: \(actualHeight) & \(actualWidth)")
        print("size of compressed image in KB: %f , \(compressedSize!/1024)")
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!)!
        
    }
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // 특정 높이에 맞춰서 이미지 변환
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
