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
    
    var language: String?
    var node: KeyNode?
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        documentDidChange { [unowned self] document in
            if document != nil {
                document?.nodeEditingSubject.subscribe(onNext: { [unowned self] node in
                    self.node = node
                }).disposed(by: self.disposeBag)
            }
        } .disposed(by: disposeBag)
        
    }
    
}
