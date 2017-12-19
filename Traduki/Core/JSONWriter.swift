//
//  JSONWriter.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/9/26.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Foundation


class JSONWriter: FileWriter {
    
    weak var traduki: Traduki!
    
    init(with traduki: Traduki) {
        self.traduki = traduki
    }
    
    func save(_ node: KeyNode) {
        guard traduki.config.dataPath != nil else {
            return
        }
        var languages: EncodableData = [:]
        node.traversal { (node: KeyNode) in
            if let translation = node.translation {
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
        save(languages: languages)
    }
    
    private func save(languages: EncodableData) {
        do {
            let encoder = JSONEncoder.init()
            for (key, value) in languages {
                let data = try encoder.encode(value)
                let fileURL = URL(fileURLWithPath: traduki.config.dataPath! + key + ".json")
                try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                try data.write(to: fileURL)
            }
        } catch let e {
            print("Languages encode or write failed. (\(e))")
        }
    }
    
}
