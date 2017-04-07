//
//  ExtensionDistanceHelper.swift
//  pet-place
//
//  Created by Owner on 2017. 3. 3.

//  Copyright © 2017년 press.S. All rights reserved.
//

import Foundation

// MARK: - Extension for the UIActivityViewController to be able to customise the shared content
public extension UIActivityViewController {

    /**
     Initialises an UIActivityViewController with the text to share, and the site's website

     - parameter shareText:    string to share
     - parameter storeWebsite: website of the Store object

     - returns: self
     */
    public convenience init(shareText: String, storeName: String?, imageUrl: String?) {
        var activityItems: [AnyObject] = []

        if let name = storeName {
            activityItems.append(name as AnyObject)
        }
        if let url = imageUrl {
            do {
                let data = try Data(contentsOf: URL(string: url)!)
                activityItems.append(UIImage(data: data)!)
                
            } catch {
                print("Error on url")
            }
        }
        activityItems.append(shareText as AnyObject)

        self.init(activityItems: activityItems, applicationActivities: nil)
        excludedActivityTypes = excludedActivities
    }

    /// What activities should be excluded
    fileprivate var excludedActivities: [UIActivityType] {
        get {
            return [
                UIActivityType.postToTencentWeibo,
                UIActivityType.print,
                UIActivityType.assignToContact,
                UIActivityType.saveToCameraRoll,
                UIActivityType.addToReadingList,
                UIActivityType.postToFlickr,
                UIActivityType.postToVimeo,
                UIActivityType.postToVimeo ]
        }
    }
}
