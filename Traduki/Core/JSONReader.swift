//
//  JSONReader.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/9/26.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Foundation


class JSONReader: FileReader {
    
    var dataPath: String
    
    class func getTranslations() -> [String: Translation] {
        
        guard let dataPath = Configuration.global.dataPath else {
            return [:]
        }
        
        return JSONReader(with: dataPath).getTranslations()
    }
    
    init(with dataPath: String) {
        self.dataPath = dataPath
    }
    
    private func getTranslations() -> [String: Translation] {
    
        do {
            let metadata = try getMetadata()
            var translations: [String: Translation] = [:]
            for (key, value) in metadata {
                let translation = Translation(with: key)
                translation.meta.occurences = value["occurrences"]!
                translation.meta.placeholders = value["placeholders"]!
                translations[key] = translation
            }
            
            for language in Configuration.global.languages {
                for (key, content) in try getContent(with: language) {
                    if let translation = translations[key] {
                        translation.content[language] = content
                    }
                }
            }
            
            return translations
        } catch let e {
            print("Translations read failed. (\(e))")
        }
        
        return [:]
    }
    
    private func getMetadata() throws -> EncodableData {
        let data = try Data(contentsOf: URL(fileURLWithPath: dataPath + "metadata.json"))
        let decoder = JSONDecoder()
        return try decoder.decode(EncodableData.self, from: data)
    }
    
    private func getContent(with language: String) throws -> [String: [String]] {
        let data = try Data(contentsOf: URL(fileURLWithPath: dataPath + language + ".json"))
        let decoder = JSONDecoder()
        return try decoder.decode([String: [String]].self, from: data)
    }
    
}
