//
//  Configuration.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/9/26.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Foundation
import SwiftyJSON

class Configuration: NSObject {

    enum SupportedFileType: String {
        case java   = "java"
        case js     = "js"
        case objc   = "objc"
        case php    = "php"
        case python = "python"
        case swift  = "swift"
    }
    
    enum KeyScope: String {
        case global = "global"
        case file   = "file"
    }
    
    struct Database {
        enum Driver: String {
            case MySQL = "mysql"
        }
        
        var driver = Driver.MySQL
        var host = ""
        var port = ""
        var database = ""
        var username = ""
        var password = ""
    }
    
    static let properties = ["lastWorkPath", "relativeDataPath", "keyScope", "excludedMasks", "languages", "fileTypeMap"]
    
    // Work path
    @objc var workPath: String?
    @objc var lastWorkPath: String?
    
    
    // TODO: Excluded directories and files
    @objc var excludedMasks = [".*", "DS_Store"]
    
    
    // TODO: Supported types of file and which is need to be read
    @objc var supportedFileTypes = [SupportedFileType.swift.rawValue]
    
    
    // TODO: Custom map between language and extension of file
    @objc var fileTypeMap: [String: [String]] = [
        SupportedFileType.swift.rawValue  : ["swift"],
//        SupportedFileType.objc.rawValue   : [".m", ".mm"],
//        SupportedFileType.python.rawValue : [".py"],
//        SupportedFileType.js.rawValue     : [".js"],
//        SupportedFileType.php.rawValue    : [".php"]
    ]
    
    
    // Save position, default is under the work directory
    @objc var relativeDataPath: String? {
        didSet {
            if relativeDataPath == nil {
                relativeDataPath = "Languages/"
            }
        }
    }
    var dataPath: String? {
        if workPath != nil && relativeDataPath != nil {
            return workPath! + relativeDataPath!
        }
        return nil
    }
    
    @objc var keyScope = KeyScope.global.rawValue
    
    // Supported languages
    @objc var languages = ["en_US", "zh_CN"]
    
    // Database
    var database = Database()
    
    func xmlElement() -> XMLElement {
        let element = XMLElement(name: "Configuration")
        for key in Configuration.properties {
            if let value = self.value(forKey: key) {
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
    
    func load(from element: XMLNode) {
        
        do {
            for p in Configuration.properties {
                let props = try element.nodes(forXPath: "*[@id='\(p)']")
                var value: Any?
                if let prop = props.first {
                    switch prop.type {
                    case "String":
                        value = prop.string
                    case "Array" where prop.children != nil:
                        value = prop.array
                    case "Dictionary" where prop.children != nil:
                        value = prop.dict
                    default:
                        break
                    }
                }
                setValue(value, forKey: p)
            }
        } catch let e {
            print("XPath failed.", e)
        }
        
    }
}
