//
//  Configuration.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/9/26.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Foundation

class Configuration {
    
    enum SupportedFileType: String {
        case java   = "java"
        case js     = "js"
        case objc   = "objc"
        case php    = "php"
        case python = "python"
        case swift  = "swift"
    }
    
    enum SavingMethod: String {
        case singleFile = "single_file"
        case files      = "files"
        case database   = "database"
    }
    
    
    static var global = Configuration()
    
    
    // Work path
    var workPath: String? {
        didSet {
            if workPath != nil {
                dataPath = workPath! + "Languages/"
            } else {
                dataPath = workPath
            }
        }
    }
    
    
    // TODO: Excluded directories and files
    var excludedMasks = [".*", "DS_Store"]
    
    
    // TODO: Supported types of file and which is need to be read
    var supportedFileTypes = [SupportedFileType.swift.rawValue]
    
    
    // TODO: Custom map between language and extension of file
    var fileTypeMap: [String: [String]] = [
        SupportedFileType.swift.rawValue  : ["swift"],
//        SupportedFileType.objc.rawValue   : [".m", ".mm"],
//        SupportedFileType.python.rawValue : [".py"],
//        SupportedFileType.js.rawValue     : [".js"],
//        SupportedFileType.php.rawValue    : [".php"]
    ]
    
    
    // Save position, default is under the work directory
    var dataPath: String?

    
    // TODO: Save to file(s) or Database
    var savingMethod = SavingMethod.singleFile
    
    
    // Supported languages
    var languages = ["en_US", "zh_CN"]
    
    
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
            "saving_method"       : savingMethod.rawValue,
            "languages"           : languages
        ])
        
        try json.rawData().write(to: URL(fileURLWithPath: workPath! + ".traduki"))
    }
    
    // Attempt to load config from work path
    func load() throws {
        guard workPath != nil else {
            return
        }

        let json = try JSON(data: Data(contentsOf: URL(fileURLWithPath: workPath! + ".traduki")))
        
        dataPath           = json["data_path"].stringValue
        excludedMasks      = json["excluded_masks"].arrayValue.map { $0.stringValue }
//        supportedFileTypes = json["supported_file_types"].arrayValue.map { $0.stringValue }
        fileTypeMap        = json["file_type_map"].dictionaryValue.mapValues { $0.arrayValue.map {$0.stringValue} }
        savingMethod       = SavingMethod(rawValue: json["saving_method"].stringValue)!
        languages          = json["languages"].arrayValue.map { $0.stringValue }
    }
}
