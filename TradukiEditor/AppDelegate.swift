//
//  AppDelegate.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/11/7.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        print(ProjectManager.shared.projectElement().xmlString(options: .nodePrettyPrint))
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

