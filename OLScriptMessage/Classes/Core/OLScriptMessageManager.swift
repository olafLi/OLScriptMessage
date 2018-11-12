//
//  OLScriptMessageManager.swift
//  OLScriptMessage
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
public protocol OLScriptMessageManagerDelegate: NSObjectProtocol {
    var webViewContent:WKWebView { get }
    var contentViewController: UIViewController? { get }
}


/**
 注册的交互结构管理器
 */
open class OLScriptMessageManager: NSObject {

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
    public func register(operation: ScriptMessageOperator) {
        self.operations[operation.scriptMessageName] = operation
    }
    /**
     注销交互接口
     */
    public func unregister(operation:ScriptMessageOperator){
        self.operations.removeValue(forKey: operation.scriptMessageName)
    }

    public init(delegate:OLScriptMessageManagerDelegate) {
        self.delegate = delegate
        self.web = delegate.webViewContent
    }

    private var delegate:OLScriptMessageManagerDelegate?

}

extension OLScriptMessageManager: WKScriptMessageHandler {

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        //根据message 创建 接口交互上下文
        let context = OLScriptMessageContext(message)
        //设置上下文操作 viewController
        context.viewController = self.contentController

        //如果交互接口已经注册 执行操作  否则
        guard let operation = operations[message.name] else {
            #if DEBUG
            assertionFailure("operation named \(message.name) is not registed . please check code and register operation with \(message.name)")
            #endif
            print("operation named \(message.name) is not registed . please check code and register operation with \(message.name)")
            return
        }
        var operation_temp = operation
        let executeCompletion: ExecuteCompletion = { context in
            context.send(self)
        }
        operation_temp.executeCompletion = executeCompletion
        operation_temp.execute(context, scriptMessageName: message.name, executeCompletion: executeCompletion)
    }
}

extension OLScriptMessageManager: WKSCriptCallBackable {

    internal func callback(_ name: String, response: [String: Any]?) {
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

