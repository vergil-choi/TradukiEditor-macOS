//
//  AppExtensions.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/11/15.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa

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

var gNSStringGeometricsTypesetterBehavior = NSLayoutManager.TypesetterBehavior.latestBehavior

extension NSAttributedString {
    
    func size(forWidth width: CGFloat, height: CGFloat) -> NSSize {
        var result = NSSize.zero
        
        if length > 0 {
            
            let size = NSSize(width: width, height: height)
            let textContainer = NSTextContainer(containerSize: size)
            let textStorage = NSTextStorage(attributedString: self)
            let layoutManager = NSLayoutManager()
            layoutManager.addTextContainer(textContainer)
            textStorage.addLayoutManager(layoutManager)
            layoutManager.hyphenationFactor = 0
            if gNSStringGeometricsTypesetterBehavior != NSLayoutManager.TypesetterBehavior.latestBehavior {
                layoutManager.typesetterBehavior = NSLayoutManager.TypesetterBehavior.latestBehavior
            }
            
            layoutManager.glyphRange(for: textContainer)
            result = layoutManager.usedRect(for: textContainer).size
    
            // Cut the last blank line
//            let extraLineSize = layoutManager.extraLineFragmentRect.size
//            if extraLineSize.height > 0 {
//                result.height -= extraLineSize.height
//            }
            
            gNSStringGeometricsTypesetterBehavior = NSLayoutManager.TypesetterBehavior.latestBehavior
            
        }
        
        return result
    }
    
    func height(forWidth width: CGFloat) -> CGFloat {
        return size(forWidth: width, height: .greatestFiniteMagnitude).height
    }
    
    func width(forHeight height: CGFloat) -> CGFloat {
        return size(forWidth: .greatestFiniteMagnitude, height: height).width
    }
}

extension String {
    func size(forWidth width: CGFloat, height: CGFloat, attributes: [NSAttributedStringKey: Any]? = nil) -> NSSize {
        let attributeString = NSAttributedString(string: self, attributes: attributes)
        return attributeString.size(forWidth: width, height: height)
    }
    
    func height(forWidth width: CGFloat, attributes: [NSAttributedStringKey: Any]? = nil) -> CGFloat {
        return size(forWidth: width, height: .greatestFiniteMagnitude, attributes: attributes).height
    }
    
    func width(forHeight height: CGFloat, attributes: [NSAttributedStringKey: Any]? = nil) -> CGFloat {
        return size(forWidth: .greatestFiniteMagnitude, height: height, attributes: attributes).width
    }
    
    func size(forWidth width: CGFloat, height: CGFloat, font: NSFont) -> NSSize {
        let attributeString = NSAttributedString(string: self, attributes: [NSAttributedStringKey.font: font])
        return attributeString.size(forWidth: width, height: height)
    }
    
    func height(forWidth width: CGFloat, font: NSFont) -> CGFloat {
        return size(forWidth: width, height: .greatestFiniteMagnitude, font: font).height
    }
    
    func width(forHeight height: CGFloat, font: NSFont) -> CGFloat {
        return size(forWidth: .greatestFiniteMagnitude, height: height, font: font).width
    }
}

