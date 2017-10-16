//
//  Translation.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/9/26.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Foundation


class Translation: CustomStringConvertible {
    
    struct Meta {
        var occurences: [String]
        var placeholders: [String]
    }
    
    
    let key: String
    var meta = Meta(occurences: [], placeholders: [])
    var content: [String: [String]] = [:]
    
    
    class func translations(with documentContext: GrammarContext) -> [Translation] {
        
        if documentContext.type != GrammarContext.Kind.document {
            return []
        }
        
        var translations: [Translation] = []
        for function in documentContext.nodes {
            
            var key = ""
            var placeholders: [String] = []
            
            // First argument is the key
            if let firstArgument = function.nodes.first, let string = firstArgument.nodes.first, string.type == GrammarContext.Kind.string {
                key = string.content
            } else {
                // Current function's first argument is empty or not a string, skip
                continue
            }
            
            // Second argument is the dictionary of placeholders
            if function.nodes.count >= 2, let dict = function.nodes[1].nodes.first, dict.type == GrammarContext.Kind.dictionary {
                for key in dict.nodes {
                    if key.type == GrammarContext.Kind.key, let string = key.nodes.first, string.type == GrammarContext.Kind.string {
                        placeholders.append(string.content)
                    }
                }
            }
            
            let translation = Translation(with: key)
            translation.meta.placeholders = placeholders
            translation.meta.occurences.append(documentContext.content)
            translations.append(translation)
        }
        
        return translations
    }
    
    func merge(from translation: Translation) {
        if self.key == translation.key {
            self.meta.occurences.append(contentsOf: translation.meta.occurences)
            self.meta.placeholders.append(contentsOf: translation.meta.placeholders)
        }
    }
    
    func merge(to translation: Translation) {
        translation.merge(from: self)
    }
    
    init(with key: String) {
        self.key = key
    }
    
    var description: String {
        get {
            return "\(key): \(content)"
        }
    }
}
