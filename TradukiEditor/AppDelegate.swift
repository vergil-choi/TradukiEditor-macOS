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
        
        openWelcomeWindow(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func openWelcomeWindow(_ sender: Any?) {
        let welcome = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: Bundle.main).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "welcome")) as! NSWindowController
        welcome.showWindow(nil)
        welcome.window?.makeKey()
    }
}

