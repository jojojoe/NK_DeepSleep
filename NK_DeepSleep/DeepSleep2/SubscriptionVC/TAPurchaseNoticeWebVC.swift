//
//  TAPurchaseNoticeWebVC.swift
//  TiktokAnalysis
//
//  Created by JOJO on 2020/6/12.
//  Copyright © 2020 Manager. All rights reserved.
//

import UIKit
import WebKit
class TAPurchaseNoticeWebVC: UIViewController {

    @IBAction func backBtnClick(_ sender: UIButton) {
        if (self.navigationController != nil) {
            self.navigationController?.popViewController()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBOutlet weak var noticeWeb: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        noticeWeb.navigationDelegate = self
        noticeWeb.uiDelegate = self
        prepareData()
    }

    func prepareData() {
        let filePath = Bundle.main.url(forResource: "PurchaseNotice", withExtension: "html")
        if let path = filePath {
            let request = URLRequest(url: path)
            noticeWeb.scrollView.zoomScale = 1.0
            noticeWeb.scrollView.showsHorizontalScrollIndicator = false
            noticeWeb.scrollView.showsVerticalScrollIndicator = false
            noticeWeb.scrollView.isScrollEnabled = true
            noticeWeb.scrollView.bouncesZoom = false
            noticeWeb.scrollView.bounces = false
            noticeWeb.isOpaque = false
            noticeWeb.backgroundColor(UIColor.black)
            noticeWeb.scrollView.backgroundColor(UIColor.black)
            noticeWeb.load(request)
        }
    }
     

}

extension TAPurchaseNoticeWebVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url {
                UIApplication.shared.openURL(url: url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    
    
}

extension TAPurchaseNoticeWebVC: WKUIDelegate {
    
}

