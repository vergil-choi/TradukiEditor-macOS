//
//  InspectorViewController.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/11/24.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa
import RxSwift

class InspectorViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    var language: String?
    var node: KeyNode? {
        didSet {
            model = TableModel(with: node)
            tableView.reloadData()
        }
    }
    var model: TableModel?
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        documentDidChange { [unowned self] document in
            if document != nil {
                document?.satellite.nodeSelected.subscribe(onNext: { [unowned self] nodes in
                    self.node = nodes?.first
                }).disposed(by: self.disposeBag)
                document?.satellite.nodeEditing.subscribe(onNext: { [unowned self] node in
                    self.node = node
                }).disposed(by: self.disposeBag)
            }
        } .disposed(by: disposeBag)
        
    }
    
    override func viewDidLayout() {
        tableView.reloadData()
    }
    
}

extension InspectorViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if let m = model {
            return m.height(forRow: row, view: view)
        }
        return 0
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let m = model {
            return m.data.count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if let m = model,
            let cell = tableView.makeView(withIdentifier: .init(m.data(forRow: row).identifier), owner: self) as? InspectorCellView {
            cell.prepare(for: m.data(forRow: row).data)
            if let c = cell as? PlcCellView {
                c.button.target = self
                c.button.action = #selector(placeholderButtonClicked(_:))
            }
            return cell
        }
        return nil
    }
    
    @objc func placeholderButtonClicked(_ sender: NSButton) {
        document!.satellite.placeholderAdding.onNext(sender.title)
    }
    
}

extension InspectorViewController {
    struct TableModel {
        static let PlcHeader = "ins-plc-header"
        static let PlcCell = "ins-plc-cell"
        static let OccHeader = "ins-occ-header"
        static let OccCell = "ins-occ-cell"
        static let TransHeader = "ins-trans-header"
        static let TransCell = "ins-trans-cell"
        static let LastHeader = "ins-last-header"
        static let TransFontSize: CGFloat = 12
        
        var data: [(String, CGFloat, Any)]
        
        init(with node: KeyNode?) {
            if let trans = node?.translation {
                data = []
                data.append((TableModel.PlcHeader, 30, TableModel.PlcHeader))
                data.append(contentsOf: trans.meta.placeholders.map { (TableModel.PlcCell, 30, $0) } as [(String, CGFloat, Any)])
                data.append((TableModel.OccHeader, 30, TableModel.OccHeader))
                data.append(contentsOf: trans.meta.occurences.map { (TableModel.OccCell, 30, $0) } as [(String, CGFloat, Any)])
                data.append((TableModel.TransHeader, 30, TableModel.TransHeader))
                data.append(contentsOf: trans.content.map { (TableModel.TransCell, 0, ($0, $1)) } as [(String, CGFloat, Any)])
                //                data.append((TableModel.LastHeader, 30, TableModel.LastHeader))
            } else {
                data = []
            }
        }
        
        func data(forRow row: Int) -> (identifier: String, height: CGFloat, data: Any) {
            return data[row]
        }
        
        func height(forRow row: Int, view: NSView) -> CGFloat {
            let d = data[row]
            if d.0 == TableModel.TransCell {
                let content = (d.2 as! (String , [String])).1.first ?? " "
                return content.height(forWidth: view.frame.width - 40, font: NSFont.systemFont(ofSize: TableModel.TransFontSize)) + 40
            }
            return d.1
        }
    }
}

class InspectorCellView: NSTableCellView {
    func prepare(for data: Any) {}
}

class PlcCellView: InspectorCellView {
    
    @IBOutlet weak var button: NSButton!
    
    override func prepare(for data: Any) {
        if let d = data as? String {
            button.attributedTitle = NSAttributedString(string: d, attributes: [
                .font: NSFont.systemFont(ofSize: 12),
                .foregroundColor: NSColor.black
            ])
        }
    }
}

class OccCellView: InspectorCellView {
    
    @IBOutlet weak var fileIcon: NSImageView!
    @IBOutlet weak var label: NSTextField!
    
    override func prepare(for data: Any) {
        if let d = data as? String {
            label.stringValue = d
            fileIcon.image = NSWorkspace.shared.icon(forFileType: d.components(separatedBy: ".").last!)
        }
    }
}

class TransCellView: InspectorCellView {
    
    @IBOutlet weak var langLabel: NSTextField!
    var textView: NSTextView!
    @IBOutlet weak var contentView: NSView!
    
    override func awakeFromNib() {
        contentView.wantsLayer = true
        contentView.layer?.borderColor = #colorLiteral(red: 0.8117647059, green: 0.8117647059, blue: 0.8117647059, alpha: 1)
        contentView.layer?.borderWidth = 1
        contentView.layer?.cornerRadius = 5
        
        textView = InspectorTextView()
        textView.drawsBackground = false
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            textView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    override func prepare(for data: Any) {
        if let d = data as? (String, [String]) {
            langLabel.stringValue = d.0
            textView.textStorage?.setAttributedString(NSAttributedString(string: d.1.first ?? "", attributes: [.font: NSFont.systemFont(ofSize: InspectorViewController.TableModel.TransFontSize)]))
        }
    }
}

class InspectorTextView: NSTextView {
    override func resignFirstResponder() -> Bool {
        setSelectedRange(NSRange(location: 0, length: 0))
        return true
    }
}
