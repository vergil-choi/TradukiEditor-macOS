//
//  MainViewController.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/7/25.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa

class MainViewController: NSSplitViewController {
    
    var workdir: URL? {
        didSet {
            reloadData()
        }
    }
    
    var selectedKey: Dotkey? {
        didSet {
            for item in self.splitViewItems {
                if let controller = item.viewController as? DetailViewController  {
                    controller.key = selectedKey
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        
        
        openDocument(self)
    }
    
    func openDocument(_ sender: Any) {
        
        if let traduki = Traduki.current, !traduki.isSaved {
            let alert = NSAlert()
            alert.messageText = "You have changed some translations, are you sure to close without save?"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Save")
            alert.addButton(withTitle: "Cancel")
            alert.addButton(withTitle: "Discard")
            switch alert.runModal() {
            case NSAlertFirstButtonReturn:
                traduki.save()
            case NSAlertSecondButtonReturn:
                return
            case NSAlertThirdButtonReturn:
                break
            default:
                break
            }
        }
        
        let panel = NSOpenPanel()
        panel.title = "Select Languages Directory"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.begin { (result: Int) in
            if (result == NSFileHandlingPanelOKButton) {
                self.workdir = panel.url
            }
        }
    }
    
    func saveDocument(_ sender: Any) {
        if let traduki = Traduki.current {
            traduki.save()
        }
    }
    
    func reload(_ sender: Any) {
        
        if let traduki = Traduki.current, !traduki.isSaved {
            let alert = NSAlert()
            alert.messageText = "Any changes will not be saved, are you sure to reload?"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Cancel")
            alert.addButton(withTitle: "Reload")
            switch alert.runModal() {
            case NSAlertFirstButtonReturn:
                return
            default:
                break
            }
        }
        
        reloadData()
    }
    
    func reloadData() {
        if let dir = self.workdir {
            let traduki = Traduki.init(dir)
            for item in self.splitViewItems {
                if let controller = item.viewController as? OutlineViewController  {
                    controller.keys = [traduki.rootKey]
                    controller.host = self
                }
                if let controller = item.viewController as? DetailViewController {
                    controller.key = nil
                }
            }
        }
    }

}
