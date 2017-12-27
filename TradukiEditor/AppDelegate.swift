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
    
    var welcome: NSWindowController!

    func applicationWillFinishLaunching(_ notification: Notification) {
        let _ = DocumentController()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        if UISettings.showWelcomeWindow {
            openWelcomeWindow(nil)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        if let window = welcome?.window, window.isVisible {
            window.close()
        }
        
        DocumentController.shared.simplyOpenFile(withPath: filename)
        return true
    }
    
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        for filename in filenames {
            DocumentController.shared.simplyOpenFile(withPath: filename)
        }
        
        if let window = welcome?.window, window.isVisible {
            window.close()
        }
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
    
    @IBAction func openWelcomeWindow(_ sender: Any?) {
        welcome = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: Bundle.main).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "welcome")) as! NSWindowController
        welcome.showWindow(nil)
        welcome.window?.makeKey()
    }
}

