//
//  ProjectManager.swift
//  Traduki
//
//  Created by Vergil Choi on 2017/11/7.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Foundation

class ProjectManager {

    var traduki: Traduki
    
    init(with traduki: Traduki) {
        self.traduki = traduki
    }
    
    public func save() {
        
        let element = XMLElement(name: "Project")
        
        element.addAttribute(XMLNode.attribute(withName: "version", stringValue: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String) as! XMLNode)
        element.addChild(traduki.config.xmlElement())
        do {
            try traduki.refresh()
            let (metadata, data) = try traduki.projectWriter.xmlElement()
            element.addChild(metadata)
            element.addChild(data)
        } catch let e {
            print("XML Data failed to generate in \(#function) .", e)
        }
        
        let document = XMLDocument(rootElement: element)
        document.name = "traduki"
        document.characterEncoding = "utf-8"
        do {
            try document.xmlData(options: .nodePrettyPrint).write(to: URL(fileURLWithPath: traduki.config.workPath! + "traduki.tdk"))
        } catch let e {
            print("Create project file failed in \(#function) .", e)
        }
    }
    
}
