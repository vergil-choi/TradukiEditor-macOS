//
//  Defines.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/12/1.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Foundation

enum ErrorDomain: String {
    case file = "com.traduki.file"
}

enum FileErrorCode: Int {
    case fileAlreadyExist = 1000
}

struct UISettings {
    static var lastLanguage: String? {
        get {
            return UserDefaults.standard.value(forKey: "global.language.last") as? String
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "global.language.last")
        }
    }
    
    static var showWelcomeWindow: Bool {
        get {
            if let value = UserDefaults.standard.value(forKey: "global.welcome") as? Bool {
                return value
            } else {
                return true
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "global.welcome")
        }
    }
}
