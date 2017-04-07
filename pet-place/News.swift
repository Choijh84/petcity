//
//  News.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// News object
class News: NSObject {

    /// ID
    var objectId: String?
    /// title of the news
    var title: String?
    /// date when the news was created
    var created: Date?
    /// the news' content
    var descriptionText: String?
    /// string that contains the image url
    var imageFile: String?

    /**
     Returns an NSURL using the image url string, if any

     - returns: URL for the image
     */
    func imageURL() -> URL? {
        if imageFile?.characters.count == 0 {
            return nil
        } else {
            return URL(string: imageFile!)
        }
    }
}
