//
//  OLScriptMessageOperation.swift
//  FourPlatform
//
//  Created by LiTengFei on 2018/10/15.
//  Copyright © 2018 WinKind. All rights reserved.
//

import UIKit
import WebKit

public typealias ExecuteCompletion = (_ context: OLScriptMessageContext) -> Void

public protocol ScriptMessageOperator {

    var contentController: UIViewController? { get }

    var executeCompletion: ExecuteCompletion? { get set }
    var context: OLScriptMessageContext? { get set }

    var scriptMessageName: String { get set }
    /**
     加载本操作对应的 js
     **/
    var userScript: WKUserScript? { get }
    func loadJSScriptContent() -> String
    /**
     执行本接口是进行的本地操作
     **/
    func execute(_ context: OLScriptMessageContext, scriptMessageName: String, executeCompletion: @escaping ExecuteCompletion)

}

extension ScriptMessageOperator {
    public func loadJSScriptContent() -> String {
        return ""
    }
}
/*
 Operation
 自注册协议
 */
public protocol ScriptMessageRegistable {
    static func autoRegisterable() -> Bool
    static var registedManager: OLScriptMessageManager? { get }
    static func defaultRegister()
}

extension ScriptMessageRegistable {

    public static func autoRegisterable() -> Bool {
        return true
    }

    public static var registedManager: OLScriptMessageManager? {
        return nil
    }
}

@objc open class OLScriptMessageOperation: NSObject, ScriptMessageOperator , ScriptMessageRegistable {

    public var contentController: UIViewController? {
        return self.context?.viewController
    }

    open func execute(_ context: OLScriptMessageContext, scriptMessageName: String, executeCompletion: @escaping (OLScriptMessageContext) -> Void) {
        self.context = context
        self.executeCompletion = executeCompletion
    }

    public required override init() {
        super.init()
    }

    @objc public init(scriptMessageName: String) {
        self.scriptMessageName = scriptMessageName
    }

    public var executeCompletion: ExecuteCompletion?
    public var context: OLScriptMessageContext?

    public var scriptMessageName: String = ""

    public var userScript: WKUserScript? {
        return self.defaultUserScript
    }

//    public func loadJSScriptContent() -> String {
//        guard self.scriptMessageName.count > 0 else { return "" }
//        let scriptMessageName = self.scriptMessageName
//        let source =  """
//        var \(scriptMessageName) = function (options, callback) {
//        var message = JKEventHandler.bindCallBack(this.\(scriptMessageName),\"\(scriptMessageName)\");
//        window.webkit.messageHandlers.\(scriptMessageName).postMessage(message);
//        }
//        window.client.\(scriptMessageName) = \(scriptMessageName);
//        """
//        return source.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
//    }

    public static func defaultRegister() {
        OLScriptMessageManager.shared.register(operation: self.init())
        print("register operation:\(type(of: self)) and \(self.init().scriptMessageName)")
    }

}

extension OLScriptMessageOperation {

    public var defaultUserScript: WKUserScript? {

        guard scriptMessageName.count > 0 else { return nil }
        let mould =  """
        var \(self.scriptMessageName) = function (options, callback) {
        var message = JKEventHandler.bindCallBack(this.\(self.scriptMessageName),\"\(self.scriptMessageName)\");
        window.webkit.messageHandlers.\(self.scriptMessageName).postMessage(message);
        }
        window.client.\(self.scriptMessageName) = \(self.scriptMessageName);
        CCIClient.\(self.scriptMessageName) = \(self.scriptMessageName);
        """

        let source = mould.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)

        return WKUserScript(source: source, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: true)
    }

}

