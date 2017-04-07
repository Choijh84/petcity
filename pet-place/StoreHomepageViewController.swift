//
//  StoreHomepageViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 20..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import SafariServices

class StoreHomepageViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var homepageLink = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Do any additional setup after loading the view.
        print("This is homepageLink: \(homepageLink)")
        let url = URL(string: homepageLink)
        let urlRequest = URLRequest(url: url!)
        webView.loadRequest(urlRequest)
        
        
    }

}
