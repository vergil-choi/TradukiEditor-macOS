//
//  ProjectManager.swift
//  Traduki
//
//  Created by Vergil Choi on 2017/11/7.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Foundation

class ProjectManager {
    static let shared = ProjectManager()
    private init() {}
    
    public func save() {
        
        let element = XMLElement(name: "Project")
        
        element.addAttribute(XMLNode.attribute(withName: "version", stringValue: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String) as! XMLNode)
        element.addChild(Configuration.global.xmlElement())
        do {
            Traduki.shared.refresh()
            let (metadata, data) = try XMLWriter.createXMLElement()
            element.addChild(metadata)
            element.addChild(data)
        } catch let e {
            print("XML Data failed to generate in \(#function) .", e)
        }
        
        let document = XMLDocument(rootElement: element)
        document.name = "traduki"
        document.characterEncoding = "utf-8"
        do {
            try document.xmlData(options: .nodePrettyPrint).write(to: URL(fileURLWithPath: Configuration.global.workPath! + "traduki.tdk"))
        } catch let e {
            print("Create project file failed in \(#function) .", e)
        }
    }
    
}
