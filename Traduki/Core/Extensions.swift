//
//  Extensions.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/11/14.
//  Copyright © 2017年 Vergil Choi. All rights reserved.
//

import Foundation

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
                dict[node.id] = node.array
            }
        }
        return dict
    }
    
    var type: String {
        return name!
    }
    
    var id: String {
        return attributeValue(for: "id")
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
    class func element(from string: String, forKey key: String? = nil) -> XMLElement {
        let stringElement = XMLElement.element(withName: "String", children: nil, attributes: key == nil ? nil : [XMLNode.attribute(withName: "id", stringValue: key!) as! XMLNode]) as! XMLElement
        stringElement.stringValue = string
        return stringElement
    }
    
    // <Item type="Array">
    //     <Item type="String">Sample Text</Item>
    // </Item>
    class func element(from array: [String], forKey key: String? = nil) -> XMLElement {
        let element = XMLElement(name: "Array")
        for item in array {
            element.addChild(self.element(from: item))
        }
        if let k = key {
            element.addAttribute(XMLNode.attribute(withName: "id", stringValue: k) as! XMLNode)
        }
        return element
    }
    
    // <Item type="Dictionary">
    //     <keyString type="Array">
    //         <Item type="String">Sample Text</Item>
    //     </keyString>
    // </Item>
    class func element(from dict: [String: [String]], forKey key: String? = nil) -> XMLElement {
        let element = XMLElement(name: "Dictionary")
        for (key, items) in dict {
            element.addChild(self.element(from: items, forKey: key))
        }
        if let k = key {
            element.addAttribute(XMLNode.attribute(withName: "id", stringValue: k) as! XMLNode)
        }
        return element
    }
}
