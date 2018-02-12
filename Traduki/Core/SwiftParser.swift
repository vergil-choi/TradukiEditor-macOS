//
//  SwiftParser.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/9/26.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//


// IMPORTANT!
//
//
// There are some special situation below
//
// - Declaration of the function '__()'
// - Escape character '\' with '('
// - Empty argument
// - Function name follows spaces
//
//
// And some TODOS:
//
// - Get the postion (row, column)
// - Redesign GrammarContext
// - Abstract Parser, make it reusable, flexible
//


import Foundation

let PREFIXES = ["", "(", "\"", "[", "", "", ""]
let SUFFIXES = ["", ")", "\"", "]", ",", ":", ""]

class SyntaxContext {
    enum Kind: Int {
        case document   = 0
        case function   = 1
        case string     = 2
        case dictionary = 3
        case argument   = 4
        case key        = 5
        case value      = 6
    }
    
    var type: Kind
    var startIndex: String.Index
    var endIndex: String.Index
    var content: String = ""
    var nodes: [SyntaxContext] = []
    var parent: SyntaxContext?
    
    var isEmpty: Bool {
        get {
            return startIndex != endIndex
        }
    }
    
    var prefix: String {
        get {
            return PREFIXES[type.rawValue]
        }
    }
    
    var suffix: String {
        get {
            return SUFFIXES[type.rawValue]
        }
    }
    
    init(type: Kind, startIndex: String.Index) {
        self.type = type
        self.startIndex = startIndex
        self.endIndex = startIndex
    }
    
    // leaf first
    func traversalPrint(_ terminator: String = "\n") {
        switch self.type {
        case .dictionary:
            print("[", terminator: "")
        case .string:
            print("\"", terminator: "")
        case .function:
            print("(", terminator: "")
        default:
            break
        }
        for leaf in self.nodes {
            leaf.traversalPrint("")
        }
        print(self.content, terminator: "")
        switch self.type {
        case .dictionary:
            print("]", terminator: "")
        case .string:
            print("\"", terminator: "")
        case .function:
            print(")", terminator: "")
        case .argument:
            print(",", terminator: "")
        case .key:
            print(":", terminator: "")
        case .value:
            print(",", terminator: "")
        default:
            break
        }
        print(terminator, terminator: "")
    }
}

class SwiftParser: Parser {
    
    var target: String!
    
    func parseFile(_ file: String) -> SyntaxContext {
        
        loadContent(file)
        let document = parseDocument()
        return document
    }
    
    private func loadContent(_ file: String) {
        do {
            try target = String(contentsOfFile: file, encoding: .utf8)
        } catch {
            print("File load failed.")
        }
    }
    
    private func parseDocument() -> SyntaxContext {
        let document = SyntaxContext.init(type: .document, startIndex: target.startIndex)
        
        // Search for '__'
        var start = target.startIndex
        while let range = target.range(of: "__", options: .regularExpression, range: start..<target.endIndex) {
            start = range.upperBound
            if currentChar(start) == "(" {
                let _ = parseFunctionCall(context: document, startIndex: start)
            } else {
                continue
            }
        }
        
        return document
    }
    
    private func parseFunctionCall(context: SyntaxContext, startIndex: String.Index) -> String.Index {
        var currentIndex = target.index(after: startIndex)
        let function = createContext(withType: .function, startIndex: startIndex, inContext: context)
        var currentContext = function
        
        while !function.isEmpty {
            
            let char = currentChar(currentIndex)
            
            switch char {
            case "(":
                currentIndex = parseFunctionCall(context: currentContext, startIndex: currentIndex)
                continue
            case ")":
                currentContext = jumpOut(ofContext: currentContext, endIndex: target.index(after: currentIndex))
            case " ", "\n":
                break
            default:
                currentIndex = parseArgument(context: currentContext, startIndex: currentIndex)
                continue
            }
            
            currentIndex = target.index(after: currentIndex)
        }
        
        return currentIndex
    }
    
    private func parseString(context: SyntaxContext, startIndex: String.Index) -> String.Index {
        var currentIndex = target.index(after: startIndex)
        let string = createContext(withType: .string, startIndex: startIndex, inContext: context)
        
        while !string.isEmpty {
            let char = currentChar(currentIndex)
            if char == "\"" && previousChar(currentIndex) != "\\" {
                string.endIndex = target.index(after: currentIndex)
            } else {
                string.content.append(char)
            }
            
            currentIndex = target.index(after: currentIndex)
        }
        
        return currentIndex
    }
    
    private func parseDictionary(context: SyntaxContext, startIndex: String.Index) -> String.Index {
        var currentIndex = target.index(after: startIndex)
        let dictionary = createContext(withType: .dictionary, startIndex: startIndex, inContext: context)
        var currentContext = dictionary
        
        while !dictionary.isEmpty {
            let char = currentChar(currentIndex)
            
            switch char {
            case "[":
                currentIndex = parseDictionary(context: currentContext, startIndex: currentIndex)
                continue
            case "]":
                currentContext = jumpOut(ofContext: currentContext, endIndex: target.index(after: currentIndex))
            case " ", "\n":
                break
            default:
                currentIndex = parseKey(context: currentContext, startIndex: currentIndex)
                continue
            }
            
            currentIndex = target.index(after: currentIndex)
        }
        
        return currentIndex
    }
    
    private func parseArgument(context: SyntaxContext, startIndex: String.Index) -> String.Index {
        var currentIndex = startIndex
        let argument = createContext(withType: .argument, startIndex: startIndex, inContext: context)
        
        while !argument.isEmpty {
            let char = currentChar(currentIndex)
            
            switch char {
            case "\"":
                currentIndex = parseString(context: argument, startIndex: currentIndex)
                continue
            case "[":
                currentIndex = parseDictionary(context: argument, startIndex: currentIndex)
                continue
            case "(":
                currentIndex = parseFunctionCall(context: argument, startIndex: currentIndex)
                continue
            case ",":
                argument.endIndex = target.index(after: currentIndex)
            case argument.parent!.suffix:
                argument.endIndex = currentIndex
                continue
            case " ", "\n":
                break
            default:
                argument.content.append(char)
            }
            
            currentIndex = target.index(after: currentIndex)
        }
        
        return currentIndex
    }
    
    private func parseKey(context: SyntaxContext, startIndex: String.Index) -> String.Index {
        var currentIndex = startIndex
        let key = createContext(withType: .key, startIndex: startIndex, inContext: context)
        
        loop: while !key.isEmpty {
            let char = currentChar(currentIndex)
            
            switch char {
            case "\"":
                currentIndex = parseString(context: key, startIndex: currentIndex)
                continue
            case ":":
                key.endIndex = currentIndex
                currentIndex = parseValue(context: context, startIndex: target.index(after: currentIndex))
                break loop
            case " ", "\n":
                break
            default:
                key.content.append(char)
            }
            
            currentIndex = target.index(after: currentIndex)
        }
        
        return currentIndex
    }
    
    private func parseValue(context: SyntaxContext, startIndex: String.Index) -> String.Index {
        var currentIndex = startIndex
        let value = createContext(withType: .value, startIndex: startIndex, inContext: context)
        
        loop: while !value.isEmpty {
            let char = currentChar(currentIndex)
            
            switch char {
            case "\"":
                currentIndex = parseString(context: value, startIndex: currentIndex)
                continue
            case ",":
                value.endIndex = target.index(after: currentIndex)
            case value.parent!.suffix:
                value.endIndex = currentIndex
                break loop
            case " ", "\n":
                break
            default:
                value.content.append(char)
            }
            
            currentIndex = target.index(after: currentIndex)
        }
        
        return currentIndex
    }
    
    private func currentChar(_ startIndex: String.Index) -> String {
        return String(target[startIndex..<target.index(after: startIndex)])
    }
    
    private func previousChar(_ startIndex: String.Index) -> String {
        return String(target[target.index(before: startIndex)..<startIndex])
    }
    
    private func createContext(withType type: SyntaxContext.Kind, startIndex: String.Index, inContext context: SyntaxContext) -> SyntaxContext {
        let newContext = SyntaxContext.init(type: type, startIndex: startIndex)
        newContext.parent = context
        context.nodes.append(newContext)
        return newContext
    }
    
    private func jumpOut(ofContext context: SyntaxContext, endIndex: String.Index) -> SyntaxContext {
        context.endIndex = endIndex
        return context.parent!
    }
    
}
