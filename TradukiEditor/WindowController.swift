//
//  WindowController.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/12/7.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa
import RxSwift

class WindowController: NSWindowController {
    
    // may need to call takeUntil(_:)
    var needsReload = PublishSubject<Any?>()

    override func windowDidLoad() {
        super.windowDidLoad()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @IBAction func scan(_ sender: Any?) {
        refresh()
        needsReload.onNext(sender)
    }
    
    @IBAction func clean(_ sender: Any?) {
        if let document = self.document as? Document {
            refresh()
            document.traduki.clean()
            needsReload.onNext(sender)
        }
        
    }
    
    @IBAction func generateLanguageFiles(_ sender: Any?) {
        if let document = self.document as? Document {
            document.traduki.writer.save(document.traduki.root)
        }
    }
    
    func refresh() {
        if let document = self.document as? Document {
            do {
                try document.traduki.refresh()
            } catch Traduki.Error.workPathChanged {
                let alert = NSAlert()
                alert.messageText = "Reset work path"
                alert.informativeText = "You have moved your project file to another position. Do you want to reset work path to make scan avaliable?"
                alert.alertStyle = NSAlert.Style.warning
                alert.addButton(withTitle: "Cancel")
                alert.addButton(withTitle: "Reset")
                alert.beginSheetModal(for: window!, completionHandler: { response in
                    if response == NSApplication.ModalResponse.alertSecondButtonReturn {
                        document.traduki.config.lastWorkPath = document.traduki.config.workPath
                    }
                })
            } catch {
                
            }
        }
    }

}


extension NSViewController {
    func windowControllerChanged(_ block: ((WindowController?) -> Void)?) {
        let _ = self.rx.observe(WindowController.self, "view.window.windowController").subscribe(onNext: block)
    }
}
