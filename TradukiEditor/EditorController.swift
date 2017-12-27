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
    
    var language: String = UISettings.lastLanguage! {
        didSet {
            tableView.reloadData()
        }
    }
    
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        // There is strange thing that the document will be changed for four times, and 3 first times is nil.
        // May need to consider disposing every changes.
        documentDidChange { [unowned self] document in
            document?.nodeSelectionSubject.subscribe(onNext: { [unowned self] nodes in
                self.nodes = nodes
            }).disposed(by: self.disposeBag)
            self.addTabButtons()
        } .disposed(by: disposeBag)
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        tableView.reloadData()
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
        static let padding: CGFloat          = 1
        static let horizontalMargin: CGFloat = 180
        static let verticalMargin: CGFloat   = 116
        static let lineHeight: CGFloat       = 18
        static let fontSize: CGFloat         = 14
    }
    
    var translations: [(node: KeyNode, trans: Translation)] {
        guard nodes != nil else {
            return []
        }
        
        var items: [(KeyNode, Translation)] = []
        
        for node in nodes! {
            if node.translation != nil {
                items.append((node, node.translation!))
            }
        }
        return items
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return translations.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        // Correction Numbers
        if let content = translations[row].trans.content[language]?.first {
            // The height of text with no line break is the same with height of text with only one line break.
            // Actually it is corrected below at the return line
            var height = content.height(forWidth: self.view.frame.width - CellHeightCorrection.horizontalMargin,
                                        attributes: [.font: NSFont.systemFont(ofSize: CellHeightCorrection.fontSize, weight: .light)])
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
            let tuple = translations[row]
            
            // Dispose all subsciption
            cell.disposeBag = DisposeBag()
            
            // Setting display
            if let content = tuple.trans.content[language]?.first {
                cell.textView.textStorage?.setAttributedString(
                    NSAttributedString(string: content,
                                       attributes: [.font: NSFont.systemFont(ofSize: CellHeightCorrection.fontSize, weight: .light)])
                )
            } else {
                cell.textView.textStorage?.setAttributedString(NSAttributedString())
            }
            cell.keyLabel.stringValue = tuple.trans.key
            
            // Subscribe events
            cell.textView.rx.textDidChange.subscribe(onNext: { [unowned self] content in
                if tuple.trans.content[self.language] != nil {
                    tuple.trans.content[self.language]![0] = content!
                } else {
                    tuple.trans.content[self.language] = [content!]
                }
                NSAnimationContext.beginGrouping()
                NSAnimationContext.current.duration = 0
                tableView.noteHeightOfRows(withIndexesChanged: IndexSet(integer: row))
                NSAnimationContext.endGrouping()
            }).disposed(by: cell.disposeBag)
            
            // Temporarily set it as async to avoid warnings
//            Observable.of(cell.textView.rx.didBecomeFirstResponder, cell.textView.rx.didResignFirstResponder).merge().observeOn(MainScheduler.asyncInstance).subscribe(onNext: { [unowned self] first in
//                
//            }).disposed(by: cell.disposeBag)
            if nodes!.count > 1 {
                cell.textView.rx.didBecomeFirstResponder.subscribe(onNext: { [unowned self] first in
                    self.document.nodeEditingSubject.onNext(first ? tuple.node : nil)
                }).disposed(by: cell.disposeBag)
            }
            
            
            return cell
        }
        return nil
        
    }
    
}

// MARK: - Cell
class EditorCellView: NSTableCellView {
    
    @IBOutlet weak var baseView: NSView!
    @IBOutlet weak var keyLabel: NSTextField!
    var textView: NSTextView!
    

    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
    
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
        
        textView = NSTextView()
        textView.isRichText = false
        textView.usesFontPanel = false
        textView.isGrammarCheckingEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.typingAttributes = [.font: NSFont.systemFont(ofSize: 14, weight: .light)]
//        textView.placeholderString = "Translation here"
        
        baseView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        baseView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.leftAnchor.constraint(equalTo: baseView.leftAnchor, constant: 40),
            textView.rightAnchor.constraint(equalTo: baseView.rightAnchor, constant: -40),
            textView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 50),
            textView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -30)
        ])
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


