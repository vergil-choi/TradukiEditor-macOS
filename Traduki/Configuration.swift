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
    var supportedFileTypes = [SupportedFileType.swift]
    
    // TODO: Custom map between language and extension of file
    var fileTypeMap: [SupportedFileType: [String]] = [
        .swift  : ["swift"],
        .objc   : [".m", ".mm"],
        .python : [".py"],
        .js     : [".js"],
        .php    : [".php"]
    ]
    
    
    
    // Save position, default is under the work directory
    var dataPath: String?
    
    // TODO: Save to file(s) or Database
    var savingMethod = SavingMethod.singleFile
    
    
    
    // Supported languages
    var languages = ["en_US", "zh_CN"]
    
    
    // Save to work path
    func save() {
        guard workPath != nil, dataPath != nil else {
            return
        }
        
        let json: [String: Encodable] = [
            "dataPath"            : dataPath!,
            "excluded_masks"      : excludedMasks,
            "supported_file_types": supportedFileTypes,
            "file_type_map"       : fileTypeMap,
            "saving_method"       : savingMethod.rawValue,
            "languages"           : languages
        ]
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(json)
            try data.write(to: URL(fileURLWithPath: workPath! + ".traduki"))
        } catch let e {
            print("Saving configuration failed. (\(e))")
        }
    }
    
    // Attempt to load config from work path
    func load() {
        guard workPath != nil else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: URL(fileURLWithPath: workPath! + ".traduki"))
            let json = try decoder.decode([String: Encodable].self, from: data)
            
            dataPath           = json["data_path"]            as? String
            excludedMasks      = json["excluded_masks"]       as! [String]
            supportedFileTypes = json["supported_file_types"] as! [SupportedFileType]
            fileTypeMap        = json["file_type_map"]        as! [SupportedFileType: [String]]
            savingMethod       = json["saving_method"]        as! Configuration.SavingMethod
            languages          = json["languages"]            as! [String]
            
        } catch let e {
            print("Loading configuration failed. (\(e))")
        }
    }
}
