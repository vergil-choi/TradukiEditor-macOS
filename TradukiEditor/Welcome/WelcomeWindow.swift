//
//  WelcomeWindow.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/11/14.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa

class WelcomeWindow: NSWindow {

    override func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        if let action = item.action {
            if action == #selector(performClose(_:)) {
                return true
            }
        }
        return super.validateUserInterfaceItem(item)
    }
    
    override func performClose(_ sender: Any?) {
        self.close()
    }
    
}
