//
//  ViewController.swift
//  swift-webviewapp
//
//  Created by 윤동민 on 2020/03/28.
//  Copyright © 2020 윤동민. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

class ViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setWebView()
        loadWebPage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let isReachable = NetworkReachabilityManager()?.isReachable else { return }
        if isReachable {
            print("Connect")
        } else {
            let alertController = UIAlertController(title: "네트워크 오류", message: "네트워크 연결이 필요합니다.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "확인", style: .cancel) { _ in
                exit(0)
            }
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func setWebView() {
        webView.navigationDelegate = self
        webView.uiDelegate = self
    }

    private func loadWebPage() {
        guard let url = URL(string: "https://www.coupang.com/") else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        let userScript = WKUserScript(source: "", injectionTime: .atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(userScript)
        configuration.userContentController = contentController
        return WKWebView(frame: webView.frame, configuration: configuration)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "확인", style: .cancel) { _ in
            completionHandler()
        }
        
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            completionHandler(false)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        indicator.isHidden = false
        indicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicator.stopAnimating()
        indicator.isHidden = true
    }
}

