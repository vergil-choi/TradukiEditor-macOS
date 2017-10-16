//
//  MainWindowController.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/8/1.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    func windowShouldClose(_ sender: Any) -> Bool {
        if let traduki = MainProcessor.current, !traduki.isSaved {
            
            let alert = saveAlert()
            switch alert.runModal() {
            case NSAlertFirstButtonReturn:
                traduki.save()
                return true
            case NSAlertSecondButtonReturn:
                return false
            case NSAlertThirdButtonReturn:
                return true
            default:
                break
            }
        }
        return true
    }
    
    func saveAlert() -> NSAlert {
        let alert = NSAlert()
        alert.messageText = "You have changed some translations, are you sure to exit without save?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Discard")
        return alert
    }

}
