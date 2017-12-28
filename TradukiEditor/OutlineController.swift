//
//  MainOutlineViewController.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/11/15.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

class OutlineController: NSViewController {
    
    @IBOutlet weak var outlineClipView: NSClipView!
    @IBOutlet weak var outlineView: MainOutlineView!
    
    @IBOutlet weak var hierarchicalModeButton: NSButton!
    var currentModeButton: NSButton!
    
    @IBOutlet weak var searchField: NSSearchField!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        currentModeButton = hierarchicalModeButton
        searchField.layer?.cornerRadius = 5
        searchField.layer?.borderWidth = 1
        searchField.layer?.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
        
        documentDidChange { [unowned self] document in
            if document != nil {
                self.outlineView.reloadData()
            }
        } .disposed(by: disposeBag)
        
        windowControllerChanged { [unowned self] windowController in
            if let controller = windowController {
                let _ = controller.needsReload.subscribe(onNext: { [unowned self] _ in
                    self.outlineView.reloadData()
                })
            }
        }
        
        let _ = outlineView.rx.selectionDidChange.subscribe(onNext: { indexSet in
            self.document.satellite.nodeSelected.onNext(indexSet.map {
                return self.outlineView.item(atRow: $0) as! KeyNode
            })
        })
        
    }
    
    override func viewDidLayout() {
        // Resize outline column when outline view size is changed
        outlineView.tableColumns.first?.width = outlineClipView.frame.size.width - 5
    }
    
    @IBAction func modeButtonClicked(_ sender: NSButton) {
        if currentModeButton != sender {
            var temp = currentModeButton.image
            currentModeButton.image = currentModeButton.alternateImage
            currentModeButton.alternateImage = temp
            
            temp = sender.image
            sender.image = sender.alternateImage
            sender.alternateImage = temp
            
            currentModeButton = sender
        }
        
    }
    
    @IBAction func filterButtonClicked(_ sender: NSButton) {
        let menu = NSMenu(title: "Filter")
        menu.addItem(withTitle: "Deleted", action: nil, keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Untranslated", action: nil, keyEquivalent: "")
        menu.addItem(withTitle: "Incompleted", action: nil, keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "All", action: nil, keyEquivalent: "")
        menu.item(at: 5)?.state = .on
        menu.popUp(positioning: nil, at: sender.frame.origin, in: view)
    }
    
}


// MARK: - Main Outline View
extension OutlineController: NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 30
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let node = item as? KeyNode {
            return node.children.count
        }
        return 1
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let node = item as? KeyNode {
            return node.children[index]
        }
        return document?.traduki.root ?? KeyNode(with: "root")
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let node = item as? KeyNode {
            return node.children.count > 0
        }
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if tableColumn?.identifier.rawValue == "main-outline-column",
            let node = item as? KeyNode,
            let cell = outlineView.makeView(withIdentifier: .init(rawValue: "main-outline-cell"), owner: self) as? MainOutlineCellView {
            cell.textField?.stringValue = node.name
            
            cell.node = node
            
            // Expanding & disclosure button setting
            if node.children.count > 0 {
                cell.disclosureButton.isHidden = false
                cell.disclosureButton.target = outlineView
                cell.disclosureButton.action = #selector(MainOutlineView.disclosureButtonClicked(sender:))
            } else {
                cell.disclosureButton.isHidden = true
            }
            
            if node.translation != nil {
                cell.imageView?.image = #imageLiteral(resourceName: "translation-icon")
            } else if node == document?.traduki.root {
                cell.imageView?.image = #imageLiteral(resourceName: "main-app-icon")
                cell.textField?.stringValue = document.fileURL!.deletingPathExtension().lastPathComponent
            } else {
                cell.imageView?.image = #imageLiteral(resourceName: "folder-icon")
            }
            
            return cell
        }
        return nil
    }
    
    // Make custom row view
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        let rowIdentifier = NSUserInterfaceItemIdentifier(rawValue: "main-outline-row")
        var rowView = outlineView.makeView(withIdentifier: rowIdentifier, owner: self) as? MainOutlineRowView
        if rowView == nil {
            rowView = MainOutlineRowView(frame: NSRect.zero)
            rowView?.identifier = rowIdentifier
        }
        return rowView
    }

    
    func selectionShouldChange(in outlineView: NSOutlineView) -> Bool {

        guard outlineView.selectedRow >= 0 else {
            return true
        }

        // Set disclosure button image to unselected
        if let cell = outlineView.view(atColumn: 0, row: outlineView.selectedRow, makeIfNecessary: false) as? MainOutlineCellView {
            if outlineView.isItemExpanded(cell.node) {
                cell.disclosureButton.image = #imageLiteral(resourceName: "disclosure-button-expanded")
            } else {
                cell.disclosureButton.image = #imageLiteral(resourceName: "disclosure-button-normal")
            }
            if cell.node?.translation != nil {
                cell.imageView?.image = #imageLiteral(resourceName: "translation-icon")
            }
        }

        return true
    }

    func outlineViewSelectionIsChanging(_ notification: Notification) {

        guard outlineView.selectedRow >= 0 else {
            return
        }
        
        // Set disclosure button image to selected
        if let cell = outlineView.view(atColumn: 0, row: outlineView.selectedRow, makeIfNecessary: false) as? MainOutlineCellView {
            if outlineView.isItemExpanded(cell.node) {
                cell.disclosureButton.image = #imageLiteral(resourceName: "disclosure-button-expanded-selected")
            } else {
                cell.disclosureButton.image = #imageLiteral(resourceName: "disclosure-button-normal-selected")
            }
            if cell.node?.translation != nil {
                cell.imageView?.image = #imageLiteral(resourceName: "translation-selected-icon")
            }
        }
    }
}



class MainOutlineView: NSOutlineView {
    
    // Hide default disclosure button
    override func frameOfOutlineCell(atRow row: Int) -> NSRect {
        return NSRect.zero
    }
    
    // Custom disclosure button action
    @objc func disclosureButtonClicked(sender: NSButton) {
        if let cell = sender.superview as? MainOutlineCellView {
            
            // Expanded & collapse outline view like default
            if isItemExpanded(cell.node) {
                animator().collapseItem(cell.node)
            } else {
                animator().expandItem(cell.node)
            }
            
            // Image changing when clicked
            if row(forItem: cell.node) == selectedRow {
                if isItemExpanded(cell.node) {
                    sender.image = #imageLiteral(resourceName: "disclosure-button-expanded-selected")
                } else {
                    sender.image = #imageLiteral(resourceName: "disclosure-button-normal-selected")
                }
            } else {
                if isItemExpanded(cell.node) {
                    sender.image = #imageLiteral(resourceName: "disclosure-button-expanded")
                } else {
                    sender.image = #imageLiteral(resourceName: "disclosure-button-normal")
                }
            }
        }
    }
    
}

class MainOutlineCellView: NSTableCellView {
    
    @IBOutlet weak var disclosureButton: NSButton!
    var node: KeyNode?
    
}

class MainOutlineRowView: NSTableRowView {
    
    // Custom row selection background color
    override func drawSelection(in dirtyRect: NSRect) {
        #colorLiteral(red: 0.2483458817, green: 0.6029202938, blue: 0.9974204898, alpha: 1).setFill()
        dirtyRect.fill()
    }
    
}
