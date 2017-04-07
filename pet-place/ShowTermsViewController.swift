//
//  ShowTermsViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class ShowTermsViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    var urlString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        webView.delegate = self
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }
    

}
