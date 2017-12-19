//
//  XMLWriter.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/11/14.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Foundation


class XMLWriter: FileWriter {
    
    enum Expection: Error {
        case invalidWorkPath
    }
    
    weak var traduki: Traduki!
    
    init(with traduki: Traduki) {
        self.traduki = traduki
    }
    
    func xmlElement() throws -> (XMLElement, XMLElement) {
        guard traduki.config.workPath != nil else {
            throw Expection.invalidWorkPath
        }
        
        var metadata: EncodableData = [:]
        var languages: EncodableData = [:]
        traduki.root.traversal { (node: KeyNode) in
            if let translation = node.translation {
                metadata[translation.key] = ["ocurrences": translation.meta.occurences, "placeholders": translation.meta.placeholders]
                for language in traduki.config.languages {
                    if languages[language] == nil {
                        languages[language] = [:]
                    }
                    if let content = translation.content[language], content.count > 0 {
                        languages[language]![translation.key] = content.filter { $0.count > 0 }
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
