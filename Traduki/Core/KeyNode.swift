//
//  KeyNode.swift
//  Traduki
//
//  Created by Vergil Choi on 2017/10/12.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Foundation


//
// NOTE:
//
// - Add more information, eg. How many children (whole hierarchy) the current node have
//
class KeyNode: NSObject {
    
    var name: String
    
    // Keep ordered
    var children: [KeyNode] = []
    
    // Traversal-oriented
    private var indexedChildren: [String: KeyNode] = [:]
    
    var translation: Translation?
    
    init(with name: String) {
        self.name = name
    }
    
    // Create the key node tree, but also merged same keys with translation
    func add(_ translation: Translation) -> KeyNode {
        let components = translation.key.components(separatedBy: ".")
        
        var currentNode = self
        
        for component in components {
            if let node = currentNode.indexedChildren[component] {
                currentNode = node
            } else {
                let node = KeyNode(with: component)
                
                // Ordered insertion
                currentNode.insert(node)
                
                currentNode.indexedChildren[component] = node
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
    
    // Insertion sort
    private func insert(_ node: KeyNode) {
        guard children.count > 0 else {
            children.append(node)
            return
        }
        
        for (index, child) in children.enumerated() {
            if node.name < child.name {
                children.insert(node, at: index)
                return
            }
        }
        children.append(node)
    }
    
    // Root first
    func traversal(action: (_ node: KeyNode) -> Void) {
        action(self)
        for child in children {
            child.traversal(action: action)
        }
    }
    
    func debugPrint(_ level: Int = 0) {
        print(String(repeating: " ", count: level * 2) + name)
        for child in children {
            child.debugPrint(level + 1)
        }
    }
}
