//
//  OLWebViewController.swift
//  FourPlatform
//
//  Created by LiTengFei on 2017/8/7.
//  Copyright © 2017年 Winkind. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore
import OLScriptMessage

open class OLWebViewController: UIViewController {

    convenience init(_ url: String) {
        self.init()
        self.url = url
    }

    var url: String = ""

    lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.preferences = WKPreferences()
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
        configuration.preferences.minimumFontSize = 10
        configuration.processPool = WKProcessPool()
        configuration.userContentController = userContentController

        var webView = WKWebView(frame: self.view.frame, configuration: configuration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.isUserInteractionEnabled = true

        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }

        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false

        return webView
    }()

    private var commonJSBundle:Bundle? {
        guard let url = Bundle(for: type(of: self)).url(forResource: "OLScriptMessage", withExtension: "bundle") else { return nil }
        return Bundle(url: url)
    }
    lazy var userContentController: WKUserContentController = {
        let controller = WKUserContentController()
        
        guard  let bundle = self.commonJSBundle , let path = bundle.path(forResource: "common", ofType: "js") else {
            return controller
        }

        print(path)

        if let data = NSData(contentsOfFile: path.appending("/common.js")) {
            var jsString: String = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
            jsString = jsString.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            var script = WKUserScript(source: jsString, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
            controller.addUserScript(script)
        }
        return controller
    }()

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.edgesForExtendedLayout = UIRectEdge.all

        userContentController.add(OLDefaultScriptMessageHandler(delegate: self))

        startLoadWebContent()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    open func openURL(_ url: String) {
        if let url = URL(string: self.url) {
            var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10)
            self.webView.load(request)
        }
    }
    fileprivate func startLoadWebContent() {
        self.updateProgressFrame()
        self.openURL(self.url)
    }

    private var isWebViewLoaded: Bool = false

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes  = [NSAttributedString.Key.foregroundColor: UIColor.black]
        self.navigationController?.navigationBar.shadowImage = nil

        if isWebViewLoaded {

        }

//        self.webView.addObserverBlock(forKeyPath: "estimatedProgress") { _, _, value in
//            print(value)
//            guard let progress: Double = value as? Double else {
//                return
//            }
//            if progress > 0 {
//                self.progressView.setProgress(Float(progress), animated: true)
//            }
//            if progress == 1.0 {
//                self.hiddenOriginNavigationBar()
//                self.isWebViewLoaded = true
//                self.progressView.isHidden = true
//            }
//        }
    }

    fileprivate func updateProgressFrame() {

    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.webView.stopLoading()
    }
}

extension OLWebViewController:OLBaseScriptMessageHandlerDelegate {

    public var webViewContent: WKWebView {
        return self.webView
    }

    public var contentViewController: UIViewController {
        return self
    }

}

// MARK: - web view delegate

extension OLWebViewController: WKUIDelegate, WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {

    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }

    fileprivate func adjustWebViewScrollInserts() {
        self.webView.scrollView.contentInset = UIEdgeInsets.zero
        self.webView.layoutIfNeeded()
        self.webView.setNeedsLayout()
    }

    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {

    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {

        adjustWebViewScrollInserts()


    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {


        self.navigationController?.setNavigationBarHidden(false, animated: false)




    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {


    }

    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
}

extension OLWebViewController {

    static func clearCache() -> Swift.Void {

        if #available(iOS 9.0, *) {
            let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
            let date = Date(timeIntervalSince1970: 0)
            WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: date, completionHandler: {

            })
        } else {
            // Fallback on earlier versions

            let cookie: HTTPCookie?
            let storage: HTTPCookieStorage = HTTPCookieStorage.shared

            for cookie in storage.cookies as? [HTTPCookie] ?? [] {
                storage.deleteCookie(cookie)
            }

            URLCache.shared.removeAllCachedResponses()
            URLCache.shared.diskCapacity = 0
            URLCache.shared.memoryCapacity = 0
        }
    }
}
