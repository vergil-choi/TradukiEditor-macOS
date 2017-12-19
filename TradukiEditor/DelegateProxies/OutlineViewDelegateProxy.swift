//
//  OutlineViewDelegateProxy.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/11/30.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

class OutlineViewDelegateProxy: DelegateProxy<MainOutlineView, NSOutlineViewDelegate>, DelegateProxyType, NSOutlineViewDelegate {
    
    init(_ outlineView: MainOutlineView) {
        super.init(parentObject: outlineView, delegateProxy: OutlineViewDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        self.register { OutlineViewDelegateProxy($0) }
    }
    
    override func setForwardToDelegate(_ forwardToDelegate: NSOutlineViewDelegate?, retainDelegate: Bool) {
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: true)
    }
    
    
    static func setCurrentDelegate(_ delegate: OutlineViewDelegateProxy.Delegate?, to object: OutlineViewDelegateProxy.ParentObject) {
        object.delegate = delegate
    }
    
    static func currentDelegate(for object: OutlineViewDelegateProxy.ParentObject) -> OutlineViewDelegateProxy.Delegate? {
        return object.delegate
    }
    
}

extension Reactive where Base: MainOutlineView {
    var delegate: DelegateProxy<MainOutlineView, NSOutlineViewDelegate> {
        return OutlineViewDelegateProxy.proxy(for: base)
    }
    
    var selectionDidChange: Observable<IndexSet> {
        return delegate.methodInvoked(#selector(NSOutlineViewDelegate.outlineViewSelectionDidChange(_:))).map({ _ in
            return self.base.selectedRowIndexes
        }).takeUntil(deallocated)
    }
}

