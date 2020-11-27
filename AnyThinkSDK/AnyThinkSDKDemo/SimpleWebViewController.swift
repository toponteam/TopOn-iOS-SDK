//
//  SimpleWebViewController.swift
//  AnyThinkSDKDemo
//
//  Created by Jason on 2020/9/28.
//  Copyright © 2020 AnyThink. All rights reserved.
//

import UIKit
import WebKit

@objc
class SimpleWebViewController: UIViewController {

    private lazy var webView: WKWebView = {
        
        let config = WKWebViewConfiguration()
        let web = WKWebView(frame: self.view.bounds, configuration: config)
        web.navigationDelegate = self
        web.uiDelegate = self
        self.view.addSubview(web)
        web.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        return web
    }()
    
    @objc
    var urlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if urlString?.contains("apps.apple.com") == true {
            
            UIApplication.shared.openURL(URL(string: urlString!)!)
            return
        }
        
        self.setupItems()
                     
        guard let urlStr = urlString,
              let url = URL(string: urlStr) else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func setupItems() {
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        let items = [
            UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem.init(barButtonSystemItem: .rewind, target: self, action: ATWebAction.goBack.action),
            UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem.init(barButtonSystemItem: .fastForward, target: self, action: ATWebAction.goForward.action),
            UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem.init(barButtonSystemItem: .refresh, target: self, action: ATWebAction.refresh.action),
            UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: ATWebAction.close.action),
            UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)]
        self.setToolbarItems(items, animated: true)
    }
}

extension SimpleWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webview didFinish")
        
        self.navigationItem.title = webView.title
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("webview didFail")
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
//        if webView.url?.absoluteString.contains("itunes") == true {
//
//            UIApplication.shared.openURL(webView.url!)
//            return
//        }
    }
}

extension SimpleWebViewController: WKUIDelegate {
    
}

extension SimpleWebViewController: ATWebActionProtocol {
    func goBack() {
        self.webView.goBack()
    }
    
    func goForward() {
        self.webView.goForward()
    }
    
    func refresh() {
        self.webView.reload()
    }
    
    func close() {
        self.navigationController?.dismiss(animated: true, completion: {
            
        })
    }
}
