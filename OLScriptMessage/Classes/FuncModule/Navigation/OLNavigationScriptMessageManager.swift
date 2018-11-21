//
//  NavigationScriptMessageHandler.swift
//  FourPlatform
//
//  Created by LiTengFei on 2017/8/16.
//  Copyright © 2017年 Winkind. All rights reserved.
//

import UIKit
import WebKit

public class OLNavigationScriptMessageManager: OLScriptMessageManager {

    public override init(delegate: OLScriptMessageManagerDelegate) {
        super.init(delegate: delegate)
        register(operation: NavigationScriptMessageOperation())
    }

}
