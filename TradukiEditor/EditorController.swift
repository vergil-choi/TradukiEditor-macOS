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
    @IBOutlet weak var languagesView: NSScrollView!
    var languageButtonGroup = LanguageButton.Group()
    
    var nodes: [KeyNode]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var language: String = "en_US" {
        didSet {
            tableView.reloadData()
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
            self.addTabButtons()
        }
        
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        tableView.reloadData()
    }
    
    deinit {
        nodeSelection?.dispose()
    }
}

// MARK: UI Setups
extension EditorController {
    
    func addTabButtons() {
        languagesView.documentView = NSView()
        
        if let langs = document?.traduki.config.languages {
            for lang in langs {
                addTabButton(with: lang)
            }
        }
        languagesView.documentView?.frame.size.width = CGFloat(languageButtonGroup.buttons.count) * (120 + 1)
        languagesView.documentView?.frame.size.height = languagesView.frame.size.height
    }
    
    func addTabButton(with lang: String) {
        let button = LanguageButton(withTitle: lang)
        button.bezelStyle = .regularSquare
        button.isBordered = false
        button.frame.size.height = languagesView.frame.height
        button.frame.size.width = 120
        button.frame.origin.x = CGFloat(languageButtonGroup.buttons.count) * (120 + 1)
        button.target = self
        button.action = #selector(languageButtonClicked(_:))
        languageButtonGroup.add(button)
        languagesView.documentView?.addSubview(button)
        if let last = UISettings.lastLanguage, last == lang {
            button.selected = true
        }

        addSeperator(at: CGFloat(languageButtonGroup.buttons.count) * 120 + CGFloat(languageButtonGroup.buttons.count - 1) * 1)
    }
    
    func addSeperator(at x: CGFloat) {
        let seperator = NSView()
        seperator.backgroundColor = #colorLiteral(red:0.63, green:0.63, blue:0.63, alpha:1.00)
        seperator.frame.size.width = 1
        seperator.frame.size.height = languagesView.frame.height
        seperator.frame.origin.x = x
        languagesView.documentView?.addSubview(seperator)
    }
}

// MARK: - Controls Behavior
extension EditorController {
    
    @objc func languageButtonClicked(_ sender: LanguageButton) {
        sender.selected = true
        if let lang = sender.language {
            language = lang
            UISettings.lastLanguage = lang
        }
    }
}

// MARK: - Table View
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

// MARK: - Cell
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

// MARK: - Tab-like Language Button
class LanguageButton: NSButton {
    
    class Group {
        var buttons: [LanguageButton] {
            return _buttons
        }
        private var _buttons: [LanguageButton] = []
        var selectedButton: LanguageButton? {
            for button in buttons {
                if button.selected {
                    return button
                }
            }
            return buttons.first
        }
        func add(_ button: LanguageButton) {
            _buttons.append(button)
            button.group = self
        }
        func clearSelected() {
            for button in _buttons {
                button.state = .off
            }
        }
    }
    
    var language: String?
    var normalTitle: NSAttributedString?
    var highlightTitle: NSAttributedString?
    
    weak var group: Group?
    var selected: Bool {
        get {
            return state == .on
        }
        set {
            group?.clearSelected()
            state = newValue ? .on : .off
        }
    }
    
    init(withTitle title: String) {
        super.init(frame: .zero)
        language = title
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        normalTitle = NSAttributedString(string: title,
                                         attributes: [
                                            .foregroundColor: #colorLiteral(red: 0.35, green: 0.35, blue: 0.35, alpha: 1),
                                            .paragraphStyle: paragraph
            ])
        highlightTitle = NSAttributedString(string: title,
                                            attributes: [
                                                .foregroundColor: NSColor.black,
                                                .paragraphStyle: paragraph
            ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override var wantsUpdateLayer: Bool {
        return true
    }
    
    override func updateLayer() {
        if cell!.isHighlighted || selected {
            backgroundColor = #colorLiteral(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
            attributedTitle = highlightTitle!
        } else {
            backgroundColor = #colorLiteral(red: 0.73, green: 0.73, blue: 0.73, alpha: 1)
            attributedTitle = normalTitle!
        }
    }

}


