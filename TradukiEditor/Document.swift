//
//  Document.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/11/7.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

class Document: NSDocument {
    
    struct Satellite {
        var nodeSelected      = PublishSubject<[KeyNode]?>()
        var nodeEditing       = PublishSubject<KeyNode?>()
        var placeholderAdding = PublishSubject<String>()
    }
    
    var traduki = Traduki()
    var satellite = Satellite()
    
    override init() {
        super.init()
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        
        // TODO: The two line of code below this block of comment shouldn't be there
        //
        // There is two types of opening.
        // 1. Open a folder when user choose to create a new document
        // 2. Open a existed document
        //
        // Type 2 has two situation.
        // 1. The workpath is same with the path where the document is in
        // 2. Not same
        //
        // Create a new document needs a first refreshment.
        // Open a document not in work path will be not refreshable.
        
        
        
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("main-window")) as! NSWindowController
        self.addWindowController(windowController)
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
//        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        return try traduki.generateProjectDocumentData()
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
        traduki.config.workPath = fileURL!.deletingLastPathComponent().path + "/"
        traduki.loadProjectDocument(fileURL: fileURL!)
    }

}

extension NSViewController {
    var document: Document! {
        return view.window?.windowController?.document as? Document
    }
    
    func documentDidChange(_ block: ((Document?) -> Void)?) -> Disposable {
        return self.rx.observe(Document.self, "view.window.windowController.document").subscribe(onNext: block)
    }
}
