//
//  TextOperation.swift
//  OLScriptMessage
//
//  Created by LiTengFei on 2019/5/21.
//

import UIKit
import OLScriptMessage

class TextOperation: OLScriptMessageOperation {

	required init() {
		super.init(scriptMessageName: "image_picker")
	}

	override func execute(_ context: OLScriptMessageContext, scriptMessageName: String, executeCompletion: @escaping (OLScriptMessageContext) -> Void) {
		context.params.forEach { (key,value) in
			context.response(value: value, key: key)
		}
		executeCompletion(context)
	}
}
