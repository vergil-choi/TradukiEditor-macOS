//
//  DotKey.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/7/25.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa

class Dotkey: NSObject {
    var children:[Dotkey] {
        get {
            return Array(_children.values.sorted(by: { (a, b) -> Bool in
                return a.name < b.name
            }))
        }
    }
    private var _children: [String: Dotkey] = [:]
    var name: String = "Unknown"
    var fullname: String = ""
    var translations: [String: String] = [:]
    var occurences: [String] = []
    var placeholders: [String] = []
    var desc: String = ""
    
    func addChild(_ dotkey: String) -> Dotkey {
        return self.add(keys: dotkey.components(separatedBy: "."))
    }
    
    func add(keys: [String]) -> Dotkey {
        if keys.count > 0 {
            let first = keys.first!
            var result: Dotkey!
            if let child = _children[first] {
                result = child.add(keys: Array(keys[1..<keys.count]))
            } else {
                let dotkey = Dotkey()
                dotkey.name = first
                if fullname.lengthOfBytes(using: .utf8) > 0 {
                    dotkey.fullname = fullname + "." + first
                } else {
                    dotkey.fullname = first
                }
                result = dotkey.add(keys: Array(keys[1..<keys.count]))
                _children[first] = dotkey
            }
            return result
        }
        return self
    }
    
    override var description: String {
        get {
            if children.count > 0 {
                return "\(name): \(children)"
            }
            return "\(name)"
        }
    }
}
