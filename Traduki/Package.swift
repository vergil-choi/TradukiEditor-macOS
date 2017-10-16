//
//  Package.swift
//  Traduki
//
//  Created by Vergil Choi on 2017/10/16.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "TradukiEditor",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", versions: Version(1, 0, 0)..<Version(3, .max, .max)),
        ]
)
