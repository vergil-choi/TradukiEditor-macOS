//
//  WelcomeViewController.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/11/14.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa

class WelcomeViewController: NSViewController {

    
    @IBOutlet weak var closeButton: WelcomeCloseButton!
    @IBOutlet weak var showWelcomeCheckButton: NSButton!
    @IBOutlet weak var versionLabel: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        closeButton.alphaValue = 0
        showWelcomeCheckButton.alphaValue = 0
        view.addTrackingArea(NSTrackingArea(rect: view.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil))
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        versionLabel.stringValue = "Version \(version) (\(build))"
    }
    
    @IBAction func newProjectButtonClicked(_ sender: Any) {
        view.window?.close()
        DocumentController.shared.newDocument(sender)
    }
    
    @IBAction func openProjectButtonClicked(_ sender: Any) {
        view.window?.close()
        DocumentController.shared.openDocument(sender)
    }
}

class ProjectCellView: NSTableCellView {
    
    @IBOutlet weak var subTextField: NSTextField!
    
}


// MARK: - Resent Projects Table View
extension WelcomeViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return DocumentController.shared.recentDocumentURLs.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "recent-project-cell"), owner: self) as? ProjectCellView {
            let url = DocumentController.shared.recentDocumentURLs[row]
            cell.textField?.stringValue = url.deletingPathExtension().lastPathComponent
            
            var path = url.deletingLastPathComponent().path
            if path.hasPrefix(FileManager.default.homeDirectoryForCurrentUser.path) {
                path = "~" + path.suffix(from: .init(encodedOffset: NSHomeDirectory().count))
            }
            
            cell.subTextField.stringValue = path
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        
        if let row = tableView.rowView(atRow: row, makeIfNecessary: false) {
            row.backgroundColor = #colorLiteral(red: 0.2483458817, green: 0.6029202938, blue: 0.9974204898, alpha: 1)
        }
        if let cell = tableView.view(atColumn: 0, row: row, makeIfNecessary: false) as? ProjectCellView {
            cell.textField?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.subTextField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        
        return true
    }
    
    func selectionShouldChange(in tableView: NSTableView) -> Bool {
        
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
        
        return true
    }
}

// MARK: - Controls Behaviors
extension WelcomeViewController {

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
