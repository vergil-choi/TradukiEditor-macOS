//
//  WelcomeViewController.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/11/14.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa

class WelcomeViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    // MARK: - Controls
    @IBOutlet weak var closeButton: WelcomeCloseButton!
    @IBOutlet weak var showWelcomeCheckButton: NSButton!
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        closeButton.alphaValue = 0
        showWelcomeCheckButton.alphaValue = 0
        view.addTrackingArea(NSTrackingArea(rect: view.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil))
    }
    
    // MARK: - Resent Projects Table View
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 10
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "recent-project-cell"), owner: self) as? ProjectCellView {
            cell.textField?.stringValue = "Success"
            cell.subTextField.stringValue = "success"
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        
        if tableView.selectedRow >= 0 {
            if let row = tableView.rowView(atRow: tableView.selectedRow, makeIfNecessary: false) {
                row.backgroundColor = .clear
            }
            if let cell = tableView.view(atColumn: 0, row: tableView.selectedRow, makeIfNecessary: false) as? ProjectCellView {
                cell.textField?.textColor = .black
                cell.subTextField.textColor = #colorLiteral(red: 0.462745098, green: 0.462745098, blue: 0.462745098, alpha: 1)
            }
            
            tableView.deselectRow(tableView.selectedRow)
        }
        
        if let row = tableView.rowView(atRow: row, makeIfNecessary: false) {
            row.backgroundColor = #colorLiteral(red: 0.2483458817, green: 0.6029202938, blue: 0.9974204898, alpha: 1)
        }
        if let cell = tableView.view(atColumn: 0, row: row, makeIfNecessary: false) as? ProjectCellView {
            cell.textField?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.subTextField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        
        return true
    }
    
    
    // MARK: - Controls Behaviors
    
    
    @IBAction func tableViewDoubleClicked(_ sender: NSTableView) {
        
        self.view.window?.close()
        
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.view.window?.close()
    }
    
    @IBAction func openButtonClicked(_ sender: Any) {
        self.view.window?.close()
    }
    
    override func mouseEntered(with event: NSEvent) {
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext) in
            context.duration = 0
            self.closeButton.animator().alphaValue = 1
            self.showWelcomeCheckButton.animator().alphaValue = 1
        }, completionHandler: nil)
    }
    
    override func mouseExited(with event: NSEvent) {
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext) in
            context.duration = 0.3
            self.closeButton.animator().alphaValue = 0
            self.showWelcomeCheckButton.animator().alphaValue = 0
        }, completionHandler: nil)
    }
}
