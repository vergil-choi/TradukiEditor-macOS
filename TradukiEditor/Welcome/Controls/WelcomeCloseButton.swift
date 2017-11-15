//
//  WelcomeCloseButton.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/11/15.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa

class WelcomeCloseButton: NSButton {
    
    override func awakeFromNib() {
        self.addTrackingArea(NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil))
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func mouseEntered(with event: NSEvent) {
        image = #imageLiteral(resourceName: "welcome-close-button-hover")
    }
    
    override func mouseExited(with event: NSEvent) {
        image = #imageLiteral(resourceName: "welcome-close-button")
    }
}
