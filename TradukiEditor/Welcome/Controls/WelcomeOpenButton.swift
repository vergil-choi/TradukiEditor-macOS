//
//  WelcomeOpenButton.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/11/15.
//  Copyright © 2017年 Vergil Choi. All rights reserved.
//

import Cocoa

class WelcomeOpenButton: NSButton {
    
    override func awakeFromNib() {
        
        addTrackingArea(NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil))
        wantsLayer = true
        layer?.cornerRadius = 3
        setTitle(with: .black)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func mouseEntered(with event: NSEvent) {
        backgroundColor = #colorLiteral(red: 0.7215686275, green: 0.7215686275, blue: 0.7215686275, alpha: 1)
        setTitle(with: .white)
    }
    
    override func mouseExited(with event: NSEvent) {
        backgroundColor = .clear
        setTitle(with: .black)
    }
    
    private func setTitle(with color: NSColor) {
        let centerStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        centerStyle.alignment = .center
        attributedTitle = NSAttributedString(string: "Open another project...",
                                             attributes: [NSAttributedStringKey.foregroundColor: color,
                                                          NSAttributedStringKey.paragraphStyle: centerStyle])
    }
}
