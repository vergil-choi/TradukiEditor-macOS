//
//  main.swift
//  Traduki
//
//  Created by Vergil Choi on 2017/9/28.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Foundation

//let parser = SwiftParser()
//
//let document = parser.parseFile("/Users/vergilchoi/Documents/Practice/Ruby/repos/traduki-swift/Example/ViewController.swift")
//
//let translations = Translation.translations(with: document)
//
//for translation in translations {
//    print(translation)
//}

//Traduki.shared.generateData(from: "/Users/vergilchoi/Documents/Repositories/crazybaby/crazybaby/")


Configuration.global.workPath = "/Users/vergilchoi/Documents/Practice/Ruby/repos/traduki-swift/Example/"
//Traduki.shared.generateData()

//JSONReader.getTranslations()

//KeyNode.root.debugPrint()

Configuration.global.save()
