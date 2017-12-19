//
//  DocumentController.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/12/1.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa

class DocumentController: NSDocumentController {

    override class var shared: DocumentController {
        get {
            return super.shared as! DocumentController
        }
    }
    
    override func newDocument(_ sender: Any?) {
        
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.allowedFileTypes = ["tdk"]
        panel.begin { button in
            if button == .OK, let url = panel.url {
                let fileURL = url.appendingPathComponent(url.lastPathComponent + ".tdk")
                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    FileManager.default.createFile(atPath: fileURL.path, contents: Data(), attributes: nil)
                }
                self.simplyOpenFile(withURL: fileURL)
            }
        }
    }
    
    func simplyOpenFile(withPath path: String) {
        simplyOpenFile(withURL: URL(fileURLWithPath: path))
    }
    
    func simplyOpenFile(withURL url: URL) {
        openDocument(withContentsOf: url, display: true, completionHandler: { (document, isOpened, error) in
            if error != nil {
                NSAlert(error: error!).runModal()
            }
        })
    }
}
