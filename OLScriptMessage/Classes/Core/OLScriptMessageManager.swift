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
    var webViewContent: WKWebView { get }
    var contentViewController: UIViewController? { get }
}

/**
 注册的交互结构管理器
 */
open class OLScriptMessageManager: NSObject {

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
    public func unregister(operation: ScriptMessageOperator) {
        self.operations.removeValue(forKey: operation.scriptMessageName)
    }

    public init(delegate: OLScriptMessageManagerDelegate) {
        self.delegate = delegate
    }

    public override init() {
        super.init()
    }
    /**
     delegate
     **/
    public weak var delegate: OLScriptMessageManagerDelegate?
    /*
     共用OLScriptMessageManager
     **/
    public static let shared = OLScriptMessageManager()
    /**
     自动扫描所有OLScriptMessageOperation 的子类 operation
     并将其注册到配置的 scriptMessageManager 中， 如果配置的manager 为 nil 则执行 OLScriptMessageOperation 中的 defaultRegister 方法
     defaultRegister 方法 默认注册到 OLScriptMessageOperation.shared 实例中去
     ***/
    public func autoSearchAndRegisterOperations() {

        var count: UInt32 = 0
        var result: [String] = []

        guard let classes = objc_copyClassList(&count) else { return }

        for index in 0..<count {
            let someClass: AnyClass = classes[Int(index)]

            guard let superClass = class_getSuperclass(someClass), someClass is OLScriptMessageOperation.Type else {
                continue
            }

            guard let cls = someClass as? OLScriptMessageOperation.Type else { continue }

            if cls.autoRegisterable() {
                //operation 自动注册
                self.register(operation: cls.init())
            }
        }
    }

}

extension OLScriptMessageManager {

    var contentController: UIViewController? {
        if let delegate = self.delegate {
            return delegate.contentViewController
        }
        return nil
    }

    var web: WKWebView? {
        assert(delegate != nil)
        if let delegate = delegate {
            return delegate.webViewContent
        }
        return nil
    }
}

extension OLScriptMessageManager: WKScriptMessageHandler {

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        //根据message 创建 接口交互上下文
        let context = OLScriptMessageContext(message)
        //设置上下文操作 viewController
        context.viewController = self.contentController

        //如果交互接口已经注册 执行操作 
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
        operation_temp.context = context
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
        if let web = self.web {
            print("web will run javascript: \(jsString)")
            web.evaluateJavaScript(jsString, completionHandler: nil)
        }
    }
}

extension OLScriptMessageManager {
    public func defaultAutoRunner(operation:ScriptMessageOperator) {
        let defaultAutoRunnerJs = operation.defaultAutoRunnerJS()
        if defaultAutoRunnerJs.count > 0 {
            self.web?.evaluateJavaScript(defaultAutoRunnerJs, completionHandler: nil)
        }
    }
}
