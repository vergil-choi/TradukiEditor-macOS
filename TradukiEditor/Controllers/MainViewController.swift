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
    
    override func viewDidDisappear() {
        exit(0)
    }
}
