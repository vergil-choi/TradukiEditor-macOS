//
//  Traduki.swift
//  Traduki
//
//  Created by Vergil Choi on 2017/10/11.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Foundation

class Traduki {
    static let shared = Traduki()
    private init() {}
    
    
    // TODO: Cache file last modified time to accelerate generating speed and easy to monitor file changes for auto refresh
    // Generate translations (in memory) and save to files
    func refresh() {
        
        guard let workPath = Configuration.global.workPath else {
            return
        }
        
        let parser = SwiftParser()
        
        let enumerator = FileManager.default.enumerator(atPath: workPath)
        while let filename = enumerator?.nextObject() as? String {
            // TODO: Apply config
            if filename.hasSuffix(".swift") {
                let document = parser.parseFile(workPath + filename)
                document.content = filename
                for translation in Translation.translations(with: document) {
                    let _ = KeyNode.add(translation)
                }
            }
        }
        
        JSONWriter.save()
        
    }
    
    
    // TODO: Ignore file last modified time
    func forceRefresh() {
        
    }
    
    
    // TODO: Clear translations which is already not exist
    func clear() {
        
    }
    
    // Load from files which is generated previously
    //
    // ATTENTION:
    // This function should be called before `refresh()`,
    // because the policy of merging translations is
    // keep the first translation content
    func load() {
        
        for (_, translation) in JSONReader.getTranslations() {
            let _ = KeyNode.add(translation)
        }
        
    }
}
