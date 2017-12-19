//
//  SplitView.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/11/17.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa

class SplitView: NSSplitView {

    override func drawDivider(in rect: NSRect) {
        #colorLiteral(red: 0.7215686275, green: 0.7215686275, blue: 0.7215686275, alpha: 1).setFill()
        rect.fill()
    }
    
}
