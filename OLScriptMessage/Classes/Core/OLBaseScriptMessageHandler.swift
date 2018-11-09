//
//  WKBaseScriptMessageHandler.swift
//  FourPlatform
//
//  Created by LiTengFei on 2017/8/16.
//  Copyright © 2017年 Winkind. All rights reserved.
//

import UIKit
import WebKit

protocol WKSCriptCallBackable {
    var callbackName: String { get set }
    func callback(_ name: String, response: [String: Any]?)
}

public protocol OLBaseScriptMessageHandlerDelegate: NSObjectProtocol {
    var webViewContent:WKWebView { get }
    var contentViewController: UIViewController { get }
}

public class OLBaseScriptMessageHandler: NSObject {

    var context: OLScriptMessageContext?
    var completion: ScriptMessageContextCompletion?

    fileprivate var callback: String = ""

    var contentController: UIViewController
    var web: WKWebView

    var operations: [String: ScriptMessageOperator] = [:]
    /* 注册交互接口*/
    func register(operation: ScriptMessageOperator) {
        var operation_t = operation
        operation_t.contentController = self.contentController
        self.operations[operation_t.scriptMessageName] = operation_t
    }

    public init(_ content: UIViewController) {
        self.contentController = content
        self.web = WKWebView()
        super.init()
    }

    public init(delegate:OLBaseScriptMessageHandlerDelegate) {
        self.delegate = delegate
        self.contentController = delegate.contentViewController
        self.web = delegate.webViewContent
    }

    public var delegate:OLBaseScriptMessageHandlerDelegate?

}

extension OLBaseScriptMessageHandler: WKScriptMessageHandler {

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        let context = OLScriptMessageContext(message)

        context.viewController = self.contentController
        self.context = context

        guard let operation = operations[message.name] else { return }
        var operation_temp = operation
        let executeCompletion: ExecuteCompletion = { context in
            context.send(self)
        }
        operation_temp.executeCompletion = executeCompletion
        operation_temp.execute(context, scriptMessageName: message.name, executeCompletion: executeCompletion)
    }
}

extension OLBaseScriptMessageHandler: WKSCriptCallBackable {

    var callbackName: String {
        get {
            return self.callback
        }
        set {
            self.callback = callbackName
        }
    }

    func callback(_ name: String, response: [String: Any]?) {
        var object: String = ""
        if let resp = response {
            do {
                let data = try JSONSerialization.data(withJSONObject: resp, options: JSONSerialization.WritingOptions.prettyPrinted)
                object = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
                object = object.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            } catch {
               
            }
        }
        let jsString = "JKEventHandler.callBack('\(name)',\(object))"
        self.web.evaluateJavaScript(jsString, completionHandler: nil)

    }
}

extension WKUserContentController {

    public func add(_ scriptMessageHandler: OLBaseScriptMessageHandler) {
        for (name, operation) in scriptMessageHandler.operations {
            self.addUserScript(operation.userScript)
            self.add(scriptMessageHandler, name: name)
        }
    }
}
