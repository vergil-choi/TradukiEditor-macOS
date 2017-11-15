//
//  AppExtensions.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/11/15.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import AppKit

@IBDesignable
extension NSView {
    
    @IBInspectable
    var backgroundColor: NSColor {
        get {
            if layer != nil && layer!.backgroundColor != nil {
                return NSColor(cgColor: layer!.backgroundColor!)!
            }
            return .white
        }
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue.cgColor
        }
    }
    
}
