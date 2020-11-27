//
//  ATWebAction.swift
//  AnyThinkSDKDemo
//
//  Created by Jason on 2020/9/30.
//  Copyright © 2020 AnyThink. All rights reserved.
//

import Foundation

@objc protocol ATWebActionProtocol: NSObjectProtocol  {
    func goBack()
    func refresh()
    func goForward()
    func close()
}

enum ATWebAction {
    case goBack
    case goForward
    case refresh
    case close
    
    var action: Selector {
        switch self {
        case .goBack:
            return #selector(ATWebActionProtocol.goBack)
        case .goForward:
            return #selector(ATWebActionProtocol.goForward)
        case .refresh:
            return #selector(ATWebActionProtocol.refresh)
        case .close:
            return #selector(ATWebActionProtocol.close)
        
        }
    }
}
