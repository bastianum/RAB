//
//  WebViewController.swift
//  RAB
//
//  Created by Bastian Fischer on 16.07.20.
//  Copyright © 2020 com.bastianfischer. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    var url: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Loads website
        webView?.load(URLRequest(url: URL(string: url)!))
    }

    // Action for dismiss button
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
