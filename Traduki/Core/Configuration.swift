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
    
    
    static var global = Configuration()
    static let properties = ["workPath", "dataPath", "keyScope", "excludedMasks", "languages", "supportedFileTypes", "fileTypeMap"]
    
    // Work path
    @objc var workPath: String? {
        didSet {
            if workPath != nil {
                dataPath = workPath! + "Languages/"
            } else {
                dataPath = workPath
            }
        }
    }
    
    
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
    @objc var dataPath: String?
    
    @objc var keyScope = KeyScope.global.rawValue
    
    // Supported languages
    @objc var languages = ["en_US", "zh_CN"]
    
    // Database
    var database = Database()
    
    
    // Attempt to save to work path
    func save() throws {
        guard workPath != nil, dataPath != nil else {
            return
        }
        
        let json = JSON([
            "dataPath"            : dataPath!,
            "excluded_masks"      : excludedMasks,
//            "supported_file_types": supportedFileTypes,
            "file_type_map"       : fileTypeMap,
            "key_scope"           : keyScope,
            "languages"           : languages
        ])
        
        try json.rawData().write(to: URL(fileURLWithPath: workPath! + ".traduki/config"))
    }
    
    // Attempt to load config from work path
    func load() throws {
        guard workPath != nil else {
            return
        }

        let json = try JSON(data: Data(contentsOf: URL(fileURLWithPath: workPath! + ".traduki/config")))
        
        dataPath           = json["data_path"].stringValue
        excludedMasks      = json["excluded_masks"].arrayValue.map { $0.stringValue }
//        supportedFileTypes = json["supported_file_types"].arrayValue.map { $0.stringValue }
        fileTypeMap        = json["file_type_map"].dictionaryValue.mapValues { $0.arrayValue.map {$0.stringValue} }
        keyScope           = json["key_scope"].stringValue
        languages          = json["languages"].arrayValue.map { $0.stringValue }
    }
    
    func xmlElement() -> XMLElement {
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
    
    func load(from element: XMLElement) {
        
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
