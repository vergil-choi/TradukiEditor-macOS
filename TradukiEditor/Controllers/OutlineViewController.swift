//
//  OutlineViewController.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/7/25.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa

class OutlineViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {

    @IBOutlet weak var outlineView: NSOutlineView!
    var keys: [Dotkey] = [] {
        didSet {
            outlineView.reloadData()
            outlineView.expandItem(nil, expandChildren: true)
        }
    }
    
    var host: MainViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
    @IBAction func expandButtonClicked(_ sender: Any) {
        outlineView.expandItem(nil, expandChildren: true)
    }
    
    @IBAction func collapseButtonClicked(_ sender: Any) {
        outlineView.collapseItem(nil, collapseChildren: true)
    }
    
    
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let key = item as? Dotkey {
            return key.children.count
        }
        return keys.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let key = item as? Dotkey {
            return key.children[index]
        }
        return keys[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let key = item as? Dotkey {
            return key.children.count > 0
        }
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?
        
        if let key = item as? Dotkey {
            view = outlineView.make(withIdentifier: "dotkey", owner: self) as? NSTableCellView
            if let textField = view?.textField {
                textField.stringValue = key.name
                textField.sizeToFit()
            }
        }
        
        return view
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }
        
        let selectedIndex = outlineView.selectedRow
        
        host.selectedKey = outlineView.item(atRow: selectedIndex) as? Dotkey
        
    }
    
}
