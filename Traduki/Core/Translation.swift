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
    
    
    class func translations(with documentContext: SyntaxContext) -> [Translation] {
        
        if documentContext.type != SyntaxContext.Kind.document {
            return []
        }
        
        var translations: [Translation] = []
        for function in documentContext.nodes {
            
            var key = ""
            var placeholders: [String] = []
            
            // First argument is the key
            if let firstArgument = function.nodes.first, let string = firstArgument.nodes.first, string.type == SyntaxContext.Kind.string {
                key = string.content
            } else {
                // Current function's first argument is empty or not a string, skip
                continue
            }
            
            // Second argument is the dictionary of placeholders
            if function.nodes.count >= 2, let dict = function.nodes[1].nodes.first, dict.type == SyntaxContext.Kind.dictionary {
                for key in dict.nodes {
                    if key.type == SyntaxContext.Kind.key, let string = key.nodes.first, string.type == SyntaxContext.Kind.string {
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
            self.meta.occurences.union(translation.meta.occurences)
            self.meta.placeholders.union(translation.meta.placeholders)
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

extension Array where Element: Hashable {
    mutating func union(_ other: [Element]) {
        let s = Set<Element>(self)
        let t = Set<Element>(other)
        
        self.removeAll()
        self.append(contentsOf: Array(s.union(t)))
    }
}
