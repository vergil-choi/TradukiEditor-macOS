//
//  KeyNode.swift
//  Traduki
//
//  Created by Vergil Choi on 2017/10/12.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Foundation

class KeyNode {
    
    // Default there's only one root in global, but still can make others for different purposes
    // eg. comparing tree, snapshot tree, etc.
    static var root = KeyNode(with: "root")
    
    
    var name: String
    var children: [String: KeyNode] = [:]
    var translation: Translation?
    
    
    // Create the key node tree, but also merged same keys with translation
    class func add(_ translation: Translation) -> KeyNode {
        let components = translation.key.components(separatedBy: ".")
        
        var currentNode = KeyNode.root
        
        for component in components {
            if let node = currentNode.children[component] {
                currentNode = node
            } else {
                let node = KeyNode(with: component)
                currentNode.children[component] = node
                currentNode = node
            }
        }
        
        
        if currentNode.translation != nil {
            currentNode.translation!.merge(from: translation)
        } else {
            currentNode.translation = translation
        }
        
        
        return currentNode
    }
    
    private init(with name: String) {
        self.name = name
    }
    
    // root first
    func traversal(action: (_ node: KeyNode) -> Void) {
        action(self)
        for (_, child) in children.sorted(by: { $0.value.name < $1.value.name }) {
            child.traversal(action: action)
        }
    }
    
    func debugPrint(_ level: Int = 0) {
        print(String(repeating: " ", count: level * 2) + name)
        for (_, child) in children.sorted(by: { $0.value.name < $1.value.name }) {
            child.debugPrint(level + 1)
        }
    }
}
