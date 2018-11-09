//
//  NavigationScriptMessageHandler.swift
//  FourPlatform
//
//  Created by LiTengFei on 2017/8/16.
//  Copyright © 2017年 Winkind. All rights reserved.
//

import UIKit
import WebKit

public class OLDefaultScriptMessageHandler: OLScriptMessageHandler {

    public override init(delegate: OLBaseScriptMessageHandlerDelegate) {
        super.init(delegate: delegate)
        register(operation: NavigationScriptMessageOperation())
    }

}
