//
//  ViewController.swift
//  OLScriptMessage
//
//  Created by olafLi on 11/05/2018.
//  Copyright (c) 2018 olafLi. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore
import OLScriptMessage
import SnapKit

class ViewController: UIViewController, OLScriptMessageManagerDelegate {

	var webViewContent: WKWebView {
		return self.webView
	}

	var contentViewController: UIViewController? {
		return self
	}

	lazy var scriptMessageManager:OLScriptMessageManager = {
		let scriptMessageManager = OLScriptMessageManager()
		scriptMessageManager.delegate = self
		scriptMessageManager.autoSearchAndRegisterOperations()
		return scriptMessageManager
	}()

	lazy var userContentController:OLUserContentController = {
		let userContentController = OLUserContentController()
		userContentController.addScriptMessageManager(self.scriptMessageManager)
		return userContentController
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.addSubview(self.webView)
		
		self.webView.snp.makeConstraints { (maker) in
			maker.edges.equalTo(self.view)
		}

		startLoadWebContent()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	//MARK:- Private Methods

	private func startLoadWebContent() {
		guard let path = Bundle.main.path(forResource: "index", ofType: "html") else { return }
		let url = URL(fileURLWithPath: path)
		let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10)
		self.webView.load(request)
	}

	//MARK:- Getter Setter
	lazy var webView: WKWebView = {
		let configuration = WKWebViewConfiguration()
		configuration.preferences = WKPreferences()
		configuration.preferences.javaScriptEnabled = true
		configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
		configuration.preferences.minimumFontSize = 10
		configuration.processPool = WKProcessPool()
		configuration.userContentController = self.userContentController

		var webView = WKWebView(frame: self.view.frame, configuration: configuration)
		webView.navigationDelegate = self
		webView.isUserInteractionEnabled = true

		if #available(iOS 11.0, *) {
			webView.scrollView.contentInsetAdjustmentBehavior = .never
		}

		webView.scrollView.showsVerticalScrollIndicator = false
		webView.scrollView.showsHorizontalScrollIndicator = false

		return webView
	}()

}


extension ViewController : WKNavigationDelegate {

	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		decisionHandler(.allow)
	}

}
