//
//  XMLWriter.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/11/14.
//  Copyright © 2017年 Vergil Choi. All rights reserved.
//

import Foundation


class XMLWriter: FileWriter {
    
    enum Expection: Error {
        case invalidWorkPath
    }
    
    let workPath: String
    
    class func createXMLElement() throws -> (XMLElement, XMLElement) {
        
        guard let workPath = Configuration.global.workPath else {
            throw Expection.invalidWorkPath
        }
        
        return XMLWriter(with: workPath).xmlElement(node: KeyNode.root)
    }
    
    init(with workPath: String) {
        self.workPath = workPath
    }
    
    private func xmlElement(node: KeyNode) -> (XMLElement, XMLElement) {
        var metadata: EncodableData = [:]
        var languages: EncodableData = [:]
        node.traversal { (node: KeyNode) in
            if let translation = node.translation {
                metadata[translation.key] = ["ocurrences": translation.meta.occurences, "placeholders": translation.meta.placeholders]
                for language in Configuration.global.languages {
                    if languages[language] == nil {
                        languages[language] = [:]
                    }
                    if let content = translation.content[language] {
                        languages[language]![translation.key] = content
                    }
                }
            }
        }
        return (xmlElement(metadata: metadata), xmlElement(languages: languages))
    }
    
    private func xmlElement(metadata: EncodableData) -> XMLElement {
        let element = XMLElement(name: "Metadata")
        for (key, value) in metadata {
            element.addChild(XMLNode.element(from: value, forKey: key))
        }
        return element
    }
    
    private func xmlElement(languages: EncodableData) -> XMLElement {
        let element = XMLElement(name: "Data")
        for (language, translations) in languages {
            element.addChild(XMLNode.element(from: translations, forKey: language))
        }
        return element
    }
}
