//
//  DetailViewController.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/7/26.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa

class DetailViewController: NSViewController, NSTextViewDelegate {

    var key: Dotkey? {
        didSet {
            reloadData()
        }
    }
    
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var reloadButton: NSButton!
    @IBOutlet weak var detailTitle: NSTextField!
    
    @IBOutlet weak var propmtLabel: NSTextField!
    @IBOutlet weak var descTextField: NSTextField!
    @IBOutlet weak var occurencesTextField: NSTextField!
    
    @IBOutlet weak var textScrollView: NSScrollView!
    @IBOutlet var translationTextView: NSTextView!
    @IBOutlet weak var langButton: NSPopUpButton!
    
    @IBOutlet weak var placeholderButtonsView: NSView!
    
    @IBOutlet weak var firstLangLabel: NSTextField!
    @IBOutlet weak var firstTransLabel: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        translationTextView.focusRingType = .none
        langButton.removeAllItems()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadLanguages), name: NSNotification.Name(rawValue: "traduki.loaded"), object: nil)
    }
    
    func loadLanguages() {
        langButton.removeAllItems()
        langButton.addItems(withTitles: MainProcessor.current!.config.languages)
        langButton.selectItem(at: 0)
        reloadButton.isEnabled = true
        saveButton.isEnabled = true
        if let first = MainProcessor.current!.config.languages.first {
            firstLangLabel.stringValue = first
        }
    }
    
    func reloadData() {
        
        for view in placeholderButtonsView.subviews {
            view.removeFromSuperview()
        }

        if let k = key {
            
            // Set title to key name
            detailTitle.cell?.title = k.fullname
            
            // Set Description and Occurences
            descTextField.stringValue = k.desc
            var occurencesString = ""
            for o in k.occurences {
                occurencesString += o + "\n"
            }
            occurencesTextField.stringValue = occurencesString
            
            // Set first language translation
            if let lang = MainProcessor.current!.config.languages.first, let trans = k.translations[lang] {
                firstTransLabel.stringValue = trans
            }
            
            // Set translation
            if let seleted = langButton.selectedItem, let trans = k.translations[seleted.title] {
                textScrollView.isHidden = false
                propmtLabel.isHidden = true
                translationTextView.string = trans
            } else {
                textScrollView.isHidden = true
                propmtLabel.isHidden = false
                firstTransLabel.stringValue = ""
            }
            
            // Set placeholders
            var buttons: [NSButton] = []
            for (i, o) in k.placeholders.enumerated() {
                let button = NSButton.init(title: o, target: self, action: #selector(placeholderButtonClicked(_:)))
                button.frame.origin.y = 0
                if i > 0 {
                    button.frame.origin.x = buttons[i - 1].frame.origin.x + buttons[i - 1].frame.size.width + 8
                }
                buttons.append(button)
                placeholderButtonsView.addSubview(button)
            }
        } else { // Selected no key
            detailTitle.cell?.title = "Select a Key at left"
            descTextField.stringValue = ""
            occurencesTextField.stringValue = ""
            firstTransLabel.stringValue = ""
            propmtLabel.isHidden = true
            textScrollView.isHidden = true
        }
        
    }
    
    
    @IBAction func langChanged(_ sender: Any) {
        reloadData()
    }
    
    func placeholderButtonClicked(_ sender: NSButton) {
        if let selectedRange = translationTextView.selectedRanges.first {
            if let string = translationTextView.string as NSString? {
                translationTextView.string = string.replacingCharacters(in: selectedRange.rangeValue, with: "{" + sender.title + "}")
                textDidChange(Notification(name: Notification.Name(rawValue: "")))
            }
        }
    }
    
    func textDidChange(_ notification: Notification) {
        if let k = key, let selected = langButton.selectedItem, let traduki = MainProcessor.current {
            k.translations[selected.title] = translationTextView.string
            traduki.setTrans(by: k.fullname, for: selected.title, text: translationTextView.string!)
        }
    }
}
