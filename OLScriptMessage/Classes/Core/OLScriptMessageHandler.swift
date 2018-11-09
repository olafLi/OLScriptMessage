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
    func callback(_ name: String, response: [String: Any]?)
}
/**
 交互支持delegate
 */
public protocol OLBaseScriptMessageHandlerDelegate: NSObjectProtocol {
    var webViewContent:WKWebView { get }
    var contentViewController: UIViewController? { get }
}

public class OLScriptMessageHandler: NSObject {
    
    public static let prefix:String = "window.olaf"

    var context: OLScriptMessageContext?

    var contentController: UIViewController? {
        if let delegate = self.delegate {
            return delegate.contentViewController
        }
        return nil
    }

    var web: WKWebView

    //注册的交互接口
    private(set) var operations: [String: ScriptMessageOperator] = [:]

    /**
     注册交互接口
     */
    func register(operation: ScriptMessageOperator) {
        self.operations[operation.scriptMessageName] = operation
    }
    /**
     注销交互接口
     */
    func unregister(operation:ScriptMessageOperator){
        self.operations.removeValue(forKey: operation.scriptMessageName)
    }

    public init(delegate:OLBaseScriptMessageHandlerDelegate) {
        self.delegate = delegate
        self.web = delegate.webViewContent
    }

    public var delegate:OLBaseScriptMessageHandlerDelegate?

}

extension OLScriptMessageHandler: WKScriptMessageHandler {

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

extension OLScriptMessageHandler: WKSCriptCallBackable {

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

    private var commonJSBundle:URL? {
        guard let url = Bundle(for: OLScriptMessageContext.self).url(forResource: "OLScriptMessage", withExtension: "bundle") else { return nil }
        return Bundle(url: url)?.url(forResource: "common", withExtension: "js")
    }

    private func loadCommonKit() -> WKUserScript? {
        guard let commonJSURL = self.commonJSBundle , let data = NSData(contentsOf: commonJSURL) else { return nil}

        var jsString: String = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
        jsString = jsString.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        var script = WKUserScript(source: jsString, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
        return script
    }

    public func add(_ scriptMessageHandler: OLScriptMessageHandler) {
        //加载Common JavaScript
        if let script = self.loadCommonKit() {
            self.addUserScript(script)
        }

        for (name, operation) in scriptMessageHandler.operations {
            if let userScript = operation.userScript {
                self.addUserScript(userScript)
            }
            self.add(scriptMessageHandler, name: name)
        }
    }


}

