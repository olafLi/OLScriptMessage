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
/*
 Operation
 自注册协议
 */
public protocol ScriptMessageRegistable {
    static var autoRegisterable: Bool { get }
    static var registedManager: OLScriptMessageManager? { get }
    static func defaultRegister()
}

@objc open class OLScriptMessageOperation: NSObject, ScriptMessageOperator {

    public var contentController: UIViewController? {
        return self.context?.viewController
    }

    public func execute(_ context: OLScriptMessageContext, scriptMessageName: String, executeCompletion: @escaping (OLScriptMessageContext) -> Void) {
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

    public func loadJSScriptContent() -> String {
        guard scriptMessageName.count > 0 else { return "" }
        let source =  """
        var \(self.scriptMessageName) = function (options, callback) {
        var message = JKEventHandler.bindCallBack(this.\(self.scriptMessageName),\"\(self.scriptMessageName)\");
        window.webkit.messageHandlers.\(self.scriptMessageName).postMessage(message);
        }
        window.cci.\(self.scriptMessageName) = \(self.scriptMessageName);
        """
        return source.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
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
        window.cci.\(self.scriptMessageName) = \(self.scriptMessageName);
        """

        let source = mould.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)

        return WKUserScript(source: source, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: true)
    }

}

extension OLScriptMessageOperation: ScriptMessageRegistable {

    public static func defaultRegister() {
        let registerManager = self.registedManager ?? OLScriptMessageManager.shared
        registerManager.register(operation: self.init())
        print("\(type(of: registerManager).description()) register operation:\(type(of: self)) and \(self.init().scriptMessageName)")
    }

    public class var autoRegisterable: Bool {
        return true
    }

    public class var registedManager: OLScriptMessageManager? {
        return nil
    }

}
