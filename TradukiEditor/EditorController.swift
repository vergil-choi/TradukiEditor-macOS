//
//  EditorController.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/11/24.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

class EditorController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var languageButton: NSButton!
    @IBOutlet weak var languagesView: NSScrollView!
    
    var nodes: [KeyNode]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var language: String = "en_US" {
        didSet {
            tableView.reloadData()
            
            languageButton.title = language + "  "
        }
    }
    
    var nodeSelection: Disposable?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        documentDidChange { [unowned self] document in
            self.nodeSelection?.dispose()
            self.nodeSelection = document?.nodeSubject.subscribe(onNext: { [unowned self] nodes in
                self.nodes = nodes
            })
            if let lang = document?.traduki.config.languages.first {
                self.language = lang
            }
        }
        
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        tableView.reloadData()
    }
    
    @IBAction func languageButtonClicked(_ sender: NSButton) {
        let menu = NSMenu(title: "Languages")
        for lang in document.traduki.config.languages {
            let item = menu.addItem(withTitle: lang, action: #selector(languageSelected(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = lang
            if lang == language {
                item.state = .on
            }
        }
        menu.popUp(positioning: nil, at: sender.frame.origin, in: view)
    }
    
    @objc func languageSelected(_ sender: NSMenuItem) {
        if let lang = sender.representedObject as? String {
            language = lang
        }
    }
    
    
    deinit {
        nodeSelection?.dispose()
    }
}

extension EditorController {
    
    func addLanguageTabButtons() {
        
    }
    
}

extension EditorController: NSTableViewDelegate, NSTableViewDataSource {
 
    struct CellHeightCorrection {
        static let lineSpacing: CGFloat      = 1
        static let padding: CGFloat          = 1
        static let horizontalMargin: CGFloat = 180
        static let verticalMargin: CGFloat   = 116
        static let lineHeight: CGFloat       = 18
        static let fontSize: CGFloat         = 14
    }
    
    var translations: [Translation] {
        guard nodes != nil else {
            return []
        }
        
        var items: [Translation] = []
        
        for node in nodes! {
            if node.translation != nil {
                items.append(node.translation!)
            }
        }
        return items
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return translations.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        // Correction Numbers
        if let content = translations[row].content[language]?.first {
            let paragraph = NSMutableParagraphStyle()
            
            // Line height deviation
            paragraph.lineSpacing = CellHeightCorrection.lineSpacing
            
            // The height of text with no line break is the same with height of text with only one line break.
            // Actually it is corrected below at the return line
            var height = content.height(forWidth: self.view.frame.width - CellHeightCorrection.horizontalMargin,
                                        attributes: [.font: NSFont.systemFont(ofSize: CellHeightCorrection.fontSize, weight: .light),
                                                     .paragraphStyle: paragraph])
            if height < CellHeightCorrection.lineHeight {
                height = CellHeightCorrection.lineHeight
            }
            let result = height + CellHeightCorrection.verticalMargin + CellHeightCorrection.padding
            return result
        }
        return CellHeightCorrection.verticalMargin + CellHeightCorrection.padding + CellHeightCorrection.lineHeight
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if let cell = tableView.makeView(withIdentifier: .init("editor-cell"), owner: self) as? EditorCellView {
            let translation = translations[row]
            cell.subscription?.dispose()
            
            if let content = translation.content[language]?.first {
                cell.contentField.attributedStringValue =
                    NSAttributedString(string: content,
                                       attributes: [.font: NSFont.systemFont(ofSize: CellHeightCorrection.fontSize, weight: .light)])
            } else {
                cell.contentField.attributedStringValue =  NSAttributedString()
            }
            
            cell.keyLabel.stringValue = translation.key
            
            cell.subscription = cell.contentField.rx.text.subscribe(onNext: { [unowned self] content in
                if translation.content[self.language] != nil {
                    translation.content[self.language]![0] = content!
                } else {
                    translation.content[self.language] = [content!]
                }
                NSAnimationContext.beginGrouping()
                NSAnimationContext.current.duration = 0
                tableView.noteHeightOfRows(withIndexesChanged: IndexSet(integer: row))
                NSAnimationContext.endGrouping()
            })
            
            return cell
        }
        return nil
        
    }
    
}

class EditorCellView: NSTableCellView, NSTextFieldDelegate {
    
    @IBOutlet weak var baseView: NSView!
    @IBOutlet weak var keyLabel: NSTextField!
    @IBOutlet weak var contentField: NSTextField!
    
    var subscription: Disposable?
    
    override func awakeFromNib() {
        
        contentField.delegate = self
        
        baseView.wantsLayer = true
        baseView.shadow = NSShadow()
        baseView.layer!.shadowOpacity = 0.75
        baseView.layer!.shadowColor = #colorLiteral(red: 0.7333333333, green: 0.7333333333, blue: 0.7333333333, alpha: 1)
        baseView.layer!.shadowOffset = NSSize(width: 1, height: -2)
        baseView.layer!.shadowRadius = 1
        
        keyLabel.wantsLayer = true
        keyLabel.shadow = NSShadow()
        keyLabel.layer!.shadowOpacity = 0.95
        keyLabel.layer!.shadowColor = #colorLiteral(red: 0.7490196078, green: 0.7490196078, blue: 0.7490196078, alpha: 1)
        keyLabel.layer!.shadowOffset = NSSize(width: 1, height: 1)
        keyLabel.layer!.shadowRadius = 1
        
        contentField.placeholderString = "Translation here"
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(insertNewline(_:)) {
            textView.insertNewlineIgnoringFieldEditor(self)
            return true
        }
        if commandSelector == #selector(insertTab(_:)) {
            textView.insertTabIgnoringFieldEditor(self)
            return true
        }
        return false
    }
}


