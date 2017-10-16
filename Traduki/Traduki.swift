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
    
    func generateData() {
        
        guard let workPath = Configuration.global.workPath else {
            return
        }
        
        let parser = SwiftParser()
        
        let enumerator = FileManager.default.enumerator(atPath: workPath)
        while let filename = enumerator?.nextObject() as? String {
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
}
