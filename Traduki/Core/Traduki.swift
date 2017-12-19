//
//  Traduki.swift
//  Traduki
//
//  Created by Vergil Choi on 2017/10/11.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Foundation

// For each document
class Traduki {
    
    enum Error: Swift.Error {
        case workPathChanged
    }
    
    var root = KeyNode(with: "root")
    var config = Configuration()
    var fileURL: URL!
    
    // TODO: Make them to be protocol based properties

    lazy var writer = JSONWriter(with: self)
    lazy var projectWriter = XMLWriter(with: self)
    lazy var projectReader = XMLReader(with: self)
    
    func loadProjectDocument(fileURL: URL) {
        self.fileURL = fileURL
        projectReader.loadProject(fileURL: fileURL)
    }
    
    func generateProjectDocumentData() throws -> Data {
        
        let element = XMLElement(name: "Project")
        
        element.addAttribute(XMLNode.attribute(withName: "version", stringValue: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String) as! XMLNode)
        element.addAttribute(XMLNode.attribute(withName: "build", stringValue: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String) as! XMLNode)
        element.addChild(config.xmlElement())
        
        let (metadata, data) = try projectWriter.xmlElement()
        element.addChild(metadata)
        element.addChild(data)

        let document = XMLDocument(rootElement: element)
        document.characterEncoding = "utf-8"

        return document.xmlData(options: .nodePrettyPrint)
        
    }
    
    func generateLanguageData() {
        writer.save(root)
    }
    
    // TODO: Cache file last modified time to accelerate generating speed and easy to monitor file changes for auto refresh
    // Generate translations (in memory) and save to files
    func refresh() throws {
        
        if let workPath = config.workPath, let lastWorkPath = config.lastWorkPath, workPath != lastWorkPath {
            throw Error.workPathChanged
        }
        
        generateTree(onRoot: root, withTranslations: generateTranslations())
    }
    
    
    // TODO: Ignore file last modified time
    func forceRefresh() {
        
    }
    
    
    // TODO: Clean translations which is already not exist
    func clean() {
        let translations = generateTranslations()
        projectReader.fill(translations: translations, withContentOfFile: fileURL)
        root = KeyNode(with: "root")
        generateTree(onRoot: root, withTranslations: translations)
    }
    
    func generateTree(onRoot root: KeyNode, withTranslations translations: [Translation]) {
        for translation in translations {
            let _ = root.add(translation)
        }
    }
    
    func generateTranslations() -> [Translation] {
        guard let workPath = config.workPath else {
            return []
        }
        
        let parser = SwiftParser()
        var translations: [Translation] = []
        
        let enumerator = FileManager.default.enumerator(atPath: workPath)
        while let filename = enumerator?.nextObject() as? String {
            // TODO: Apply config
            if filename.hasSuffix(".swift") {
                let document = parser.parseFile(workPath + filename)
                document.content = filename
                translations.append(contentsOf: Translation.translations(with: document))
                
            }
        }
        
        return translations
    }
}
