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
    
    public func projectElement() -> XMLElement {
        let element = XMLElement(name: "Project")
        
        element.addAttribute(XMLNode.attribute(withName: "version", stringValue: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String) as! XMLNode)
        element.addChild(configElement())
        
        return element
    }
    
    func configElement() -> XMLElement {
        let config = Configuration.global
        let element = XMLElement(name: "Configuration")
        for key in Configuration.properties {
            if let value = config.value(forKey: key) {
                if let string = value as? String {
                    element.addChild(XMLNode.element(from: string, forKey: key))
                }
                else if let array = value as? [String] {
                    element.addChild(XMLNode.element(from: array, forKey: key))
                }
                else if let dict = value as? [String: [String]] {
                    element.addChild(XMLNode.element(from: dict, forKey: key))
                }
            }
        }
        return element
    }
    
    func loadConfig(from element: XMLElement) {
        
        do {
            for p in Configuration.properties {
                let props = try element.nodes(forXPath: p)
                if let prop = props.first {
                    switch prop.type {
                    case "String":
                        print(prop.string)
                    case "Array" where prop.children != nil:
                        print(prop.array)
                    case "Dictionary" where prop.children != nil:
                        print(prop.dict)
                    default:
                        break
                    }
                }
            }
        } catch let e {
            print("XPath failed.", e)
        }
        
        print(element.xmlString(options: .nodePrettyPrint))
        
    }
}


// TODO: Maybe need to find a better way to store data
// TODO: Make it more common
extension XMLNode {
    var string: String {
        get {
            return self.stringValue ?? ""
        }
    }
    
    var array: [String] {
        var array: [String] = []
        if let nodes = self.children {
            for node in nodes {
                array.append(node.string)
            }
        }
        return array
    }
    
    var dict: [String: [String]] {
        var dict: [String: [String]] = [:]
        if let nodes = self.children {
            for node in nodes {
                dict[node.name!] = node.array
            }
        }
        return dict
    }
    
    var type: String {
        return attributeValue(for: "type")
    }
    
    var version: String {
        return attributeValue(for: "version")
    }
    
    func attributeValue(for key: String) -> String {
        do {
            let nodes = try self.nodes(forXPath: "@\(key)")
            if let value = nodes.first?.stringValue {
                return value
            }
        } catch let e {
            print("XPath failed in function \(#function) .", e)
        }
        return ""
    }
    
    // <Item type="String">Sample Text</Item>
    class func element(from string: String, forKey key: String = "Item") -> XMLElement {
        let stringElement = XMLElement.element(withName: key, children: nil, attributes: [XMLNode.attribute(withName: "type", stringValue: "String") as! XMLNode]) as! XMLElement
        stringElement.stringValue = string
        return stringElement
    }
    
    // <Item type="Array">
    //     <Item type="String">Sample Text</Item>
    // </Item>
    class func element(from array: [String], forKey key: String = "Item") -> XMLElement {
        let element = XMLElement(name: key)
        for item in array {
            element.addChild(self.element(from: item))
        }
        element.addAttribute(XMLNode.attribute(withName: "type", stringValue: "Array") as! XMLNode)
        return element
    }
    
    // <Item type="Dictionary">
    //     <keyString type="Array">
    //         <Item type="String">Sample Text</Item>
    //     </keyString>
    // </Item>
    class func element(from dict: [String: [String]], forKey key: String = "Item") -> XMLElement {
        let element = XMLElement(name: key)
        for (key, items) in dict {
            element.addChild(self.element(from: items, forKey: key))
        }
        element.addAttribute(XMLNode.attribute(withName: "type", stringValue: "Dictionary") as! XMLNode)
        return element
    }
}
