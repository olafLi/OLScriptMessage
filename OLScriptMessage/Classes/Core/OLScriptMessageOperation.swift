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

    var contentController: UIViewController? { get set }

    var executeCompletion: ExecuteCompletion? { get set }
    var context: OLScriptMessageContext? { get set }

    var scriptMessageName: String { get set }
    /**
     加载本操作对应的 js
     **/
    var userScript: WKUserScript { get }
    func loadJSScriptContent() -> String
    /**
     执行本接口是进行的本地操作
     **/
    func execute(_ context: OLScriptMessageContext, scriptMessageName: String, executeCompletion: @escaping ExecuteCompletion)

}

public class OLScriptMessageOperation: NSObject, ScriptMessageOperator {

    public var contentController: UIViewController?

    public func execute(_ context: OLScriptMessageContext, scriptMessageName: String, executeCompletion: @escaping (OLScriptMessageContext) -> Void) {
        self.context = context
        self.executeCompletion = executeCompletion
        self.contentController = context.viewController
    }

    required init(scriptMessageName: String) {
        self.scriptMessageName = scriptMessageName
    }

    public var executeCompletion: ExecuteCompletion?
    public var context: OLScriptMessageContext?

    public var scriptMessageName: String = ""

    public var userScript: WKUserScript {
        return WKUserScript(source: self.loadJSScriptContent(), injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: true)
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
