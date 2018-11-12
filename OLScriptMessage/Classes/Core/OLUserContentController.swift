//
//  OLUserContentController.swift
//  OLScriptMessage
//
//  Created by LiTengFei on 2018/11/12.
//

import UIKit
import WebKit

open class OLUserContentController:WKUserContentController {

    private var defaultCallbackSupportorJsUrl:URL? {
        guard let url = Bundle(for: OLScriptMessageContext.self).url(forResource: "OLScriptMessage", withExtension: "bundle") else { return nil }
        return Bundle(url: url)?.url(forResource: "common", withExtension: "js")
    }

    //获取支持callback 模式的javascript userscript
    private var defaultCallbackSupportorUserScript:WKUserScript? {
        guard let commonJSURL = self.defaultCallbackSupportorJsUrl , let data = NSData(contentsOf: commonJSURL) else { return nil}
        var jsString: String = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
        jsString = jsString.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        var script = WKUserScript(source: jsString, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
        return script
    }

    public override init() {
        super.init()
        if let script = self.defaultCallbackSupportorUserScript {
            self.addUserScript(script)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func addScriptMessageManager(_ scriptMessageManager: OLScriptMessageManager) {
        for (name, operation) in scriptMessageManager.operations {
            if let userScript = operation.userScript {
                self.addUserScript(userScript)
            }
            self.add(scriptMessageManager, name: name)
        }
    }
}
