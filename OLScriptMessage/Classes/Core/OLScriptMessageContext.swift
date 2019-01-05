//
//  OLScriptMessageContext.swift
//  FourPlatform
//
//  Created by LiTengFei on 2017/8/24.
//  Copyright © 2017年 WinKind. All rights reserved.
//

import UIKit
import WebKit

/// js 脚本交互参数
public class OLScriptMessageContext {

    public var params: [String: Any] = [:]
    var functionName: String?
    var callback: String?
    public var viewController: UIViewController?

    init(_ message: WKScriptMessage) {

        self.response = [:]

        guard let maps = message.body as? [String: AnyObject] else {
            self.callback = ""
            self.functionName = ""
            self.params = [:]
            return
        }

        self.callback = maps["callback"] as? String ?? ""
        self.params = maps["params"] as? [String: Any] ?? [:]
        self.functionName = maps["func_name"] as? String ?? ""
    }

    var response: [String: Any]

    public func response( value: Any?, key: String) {
        response[key] = value
    }

    func send(_ sender: WKSCriptCallBackable) {
        sender.callback(callback!, response: response)
    }
}
