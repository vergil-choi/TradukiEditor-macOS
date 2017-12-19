//
//  XMLReader.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/12/6.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Foundation


class XMLReader: FileReader {
    
    weak var traduki: Traduki!
    
    init(with traduki: Traduki) {
        self.traduki = traduki
    }
    
    func loadProject(fileURL: URL) {
        
        do {
            let document = try XMLDocument(contentsOf: fileURL, options: .documentIncludeContentTypeDeclaration)
            
            if let config = try document.nodes(forXPath: "/Project/Configuration").first {
                traduki.config.load(from: config)
            }
            
            traduki.config.workPath = fileURL.deletingLastPathComponent().path + "/"
            if traduki.config.lastWorkPath == nil {
                traduki.config.lastWorkPath = traduki.config.workPath
            }
            
            let nodes = try document.nodes(forXPath: "/Project/Metadata/*")
            var translations: [Translation] = []
            for node in nodes {
                let key = node.attributeValue(for: "id")
                let ocurrences = try node.nodes(forXPath: "*[@id='ocurrences']/*")
                let placeholders = try node.nodes(forXPath: "*[@id='placeholders']/*")
                let translation = Translation(with: key)
                
                translation.meta.occurences = ocurrences.map { $0.stringValue! }
                translation.meta.placeholders = placeholders.map { $0.stringValue! }
                
                for language in traduki.config.languages {
                    let dataNodes = try document.nodes(forXPath: "/Project/Data/*[@id='\(language)']/*[@id='\(key)']/*")
                    if dataNodes.count > 0 {
                        translation.content[language] = dataNodes.map { $0.stringValue! }
                    }
                }
                translations.append(translation)
            }
            
            for translation in translations {
                let _ = traduki.root.add(translation)
            }
            
        } catch {
            print(error)
        }
    }
    
    func fill(translations: [Translation], withContentOfFile fileURL: URL) {
        
        do {
            let document = try XMLDocument(contentsOf: fileURL, options: .documentIncludeContentTypeDeclaration)
            
            for translation in translations {
                for language in traduki.config.languages {
                    let dataNodes = try document.nodes(forXPath: "/Project/Data/*[@id='\(language)']/*[@id='\(translation.key)']/*")
                    if dataNodes.count > 0 {
                        translation.content[language] = dataNodes.map { node -> String in
                            return node.stringValue!
                        }
                    }
                }
            }
            
        } catch {
            print(error)
        }
        
    }
}
