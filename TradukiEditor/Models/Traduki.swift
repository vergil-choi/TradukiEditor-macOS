//
//  Traduki.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/7/26.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa

class Traduki: NSObject {
    
    struct Config {
        var flat = false
        var languages: [String] = ["en_US", "zh_CN"]
        var path = "Languages"
    }
    
    let workdir: URL
    var config = Config()
    var languages: [String: [String: Any]] = [:]
    var metadata: [String: [String: Any]] = [:]
    
    lazy var rootKey: Dotkey = {
        let root = Dotkey()
        root.name = "Traduki Keys"
        for key in self.metadata.keys {
            let dotkey = root.addChild(key)
            dotkey.occurences = self.metadata[key]!["occurences"] as? [String] ?? []
            dotkey.desc = self.metadata[key]!["desc"] as? String ?? ""
            dotkey.placeholders = self.metadata[key]!["placeholders"] as? [String] ?? []
            for lang in self.config.languages {
                if let trans = self.getTrans(by: key, for: lang) {
                    dotkey.translations[lang] = trans
                }
            }
        }
        return root
    }()
    
    static var current: Traduki?
    
    init(_ workdir: URL) {
        self.workdir = workdir
        super.init()
        
        if let json = loadJSON(name: "traduki") {
            config.flat = json["flat"] as? Bool ?? false
            config.languages = json["languages"] as? [String] ?? []
            config.path = json["path"] as? String ?? ""
        }
        
        if let json = loadJSON(name: "metadata"),
           let obj = json as? [String : [String : Any]] {
            metadata = obj
        }
        
        for lang in self.config.languages {
            languages[lang] = [:]
            if let json = loadJSON(name: lang) {
                languages[lang] = json
            }
        }
        
        Traduki.current = self
        
        NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "traduki.loaded")))
    }

    func save() {
//        print(languages)
        for (lang, trans) in languages {
            saveJSON(name: lang, json: trans)
        }
    }
    
    private func loadJSON(name: String) -> [String: Any]? {
        if let data = try? Data.init(contentsOf: workdir.appendingPathComponent("\(name).json")),
           let content = try? JSONSerialization.jsonObject(with: data, options: []),
           let json = content as? [String : Any] {
            return json
        }
        return nil
    }
    
    private func saveJSON(name: String, json: Any) {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            try data.write(to: workdir.appendingPathComponent("\(name).json"))
        } catch {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = "Save failed!"
            alert.runModal()
        }
        
    }
    
    func setTrans(by dotkey: String, for lang: String, text trans: String) {
//        print(dotkey, lang, trans)
        if let translations = self.languages[lang] {
            let components = dotkey.components(separatedBy: ".")
            self.languages[lang] = setDictionary(dict: translations, value: trans, by: components)
        }
    }
    
    private func setDictionary(dict: [String: Any], value: Any, by keys: [String]) -> [String: Any] {
//        print("--------- INPUT ---------")
//        print(dict)
        
        var newDict = dict
        if keys.count == 1 {
            if var temp = dict[keys.first!] as? [String: Any] {
                temp["_"] = value
                newDict[keys.first!] = temp
            } else {
                newDict[keys.first!] = value
            }
        } else {
            newDict[keys.first!] = setDictionary(dict: dict[keys.first!] as! [String: Any], value: value, by: Array(keys[1..<keys.count]))
        }
        
//        print("--------- OUTPUT ---------")
//        print(newDict)
        
        return newDict
    }
    
    private func getTrans(by dotkey: String, for lang: String) -> String? {
        if let translations = self.languages[lang] {
            let components = dotkey.components(separatedBy: ".")
            var temp = translations
            for (index, component) in components.enumerated() {
                if index < components.count - 1 {
                    temp = temp[component] as! [String : Any]
                } else {
                    if let value = temp[component] as? String {
                        return value
                    } else if let value = temp[component] as? [String: Any] {
                        return value["_"] as? String
                    }
                }
            }
        }
        return nil
    }
    
}
