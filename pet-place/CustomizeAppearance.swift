//
//  CustomizeAppearance.swift
//  pet-place
//
//  Created by Owner on 2016. 12. 31..
//  Copyright © 2016년 press.S. All rights reserved.
//

import UIKit

 /// UI customisation class

class CustomizeAppearance: NSObject {

    /**
    Customize the global UI elements, such as UINavigationBar and UITabBar
    */
    class func globalCustomization () {
        UINavigationBar.appearance().tintColor = UIColor.navigationTitleColor()
        UINavigationBar.appearance().barTintColor = UIColor.navigationBarColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.navigationTitleColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 16)!]    

        UITabBar.appearance().tintColor = .globalTintColor()
        UITabBar.appearance().barTintColor = .white

        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.tabBarTitleNormalColor(), NSFontAttributeName: UIFont.systemFont(ofSize: 10.0)], for: UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.globalTintColor()], for: .selected)
    }
}

extension UIImage {
    
    /**
     이미지의 실제크기를 보고 최대 너비 800, 최대 높이 600으로 비율을 계산해서 압축해주는 함수
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
        
        if (actualHeight > maxHeight) || (actualWidth > maxWidth) {
            if (imgRatio < maxRatio) {
                // adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            } else if (imgRatio > maxRatio) {
                //adjust height according to maxWidth
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
        print("This is compressed height and width: \(maxHeight) & \(maxWidth)")
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
    
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
