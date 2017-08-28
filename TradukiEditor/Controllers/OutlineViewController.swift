//
//  OutlineViewController.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/7/25.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa

class OutlineViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, NSSearchFieldDelegate {

    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var topTabBottomLine: NSView!
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var searchTypeMenu: NSPopUpButton!
    
    var keys: [Dotkey] = [] {
        didSet {
            outlineView.reloadData()
            outlineView.expandItem(nil, expandChildren: true)
        }
    }
    
    var host: MainViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchField.focusRingType = .none
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        topTabBottomLine.wantsLayer = true
        topTabBottomLine.layer?.backgroundColor = NSColor(white: 0.83, alpha: 1.0).cgColor
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
                textField.stringValue = key.displayName
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

    @IBAction func searchTypeChanged(_ sender: Any) {
        searchChanged(searchField)
    }
    
    @IBAction func searchChanged(_ sender: NSSearchField) {
        if let traduki = Traduki.current {
            if sender.stringValue.lengthOfBytes(using: .utf8) > 0 {
                switch searchTypeMenu.indexOfSelectedItem {
                case 0:
                    keys = traduki.search(sender.stringValue, .key)
                case 1:
                    keys = traduki.search(sender.stringValue, .content)
                default:
                    keys = traduki.search(sender.stringValue, .key)
                }
                
            } else {
                keys = [traduki.rootKey]
            }
        }
    }
    
    
}
