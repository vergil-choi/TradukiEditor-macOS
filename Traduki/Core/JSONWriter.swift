//
//  JSONWriter.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/9/26.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Foundation


class JSONWriter: FileWriter {
    
    typealias EncodableData = [String: [String: [String]]]
    
    let dataPath: String
    
    class func save() {
        
        guard let dataPath = Configuration.global.dataPath else {
            return
        }
        
        JSONWriter(with: dataPath).save(KeyNode.root)

    }
    
    init(with dataPath: String) {
        self.dataPath = dataPath
    }
    
    private func save(_ node: KeyNode) {
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
        save(metadata: metadata)
        save(languages: languages)
    }
    
    private func save(metadata: EncodableData) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(metadata)
            try data.write(to: URL(fileURLWithPath: dataPath + "metadata.json"))
        } catch let e {
            print("Metadata encode or write failed. (\(e))")
        }
    }
    
    private func save(languages: EncodableData) {
        do {
            let encoder = JSONEncoder.init()
            for (key, value) in languages {
                let data = try encoder.encode(value)
                try data.write(to: URL(fileURLWithPath: dataPath + key + ".json"))
            }
        } catch let e {
            print("Languages encode or write failed. (\(e))")
        }
    }
    
}
