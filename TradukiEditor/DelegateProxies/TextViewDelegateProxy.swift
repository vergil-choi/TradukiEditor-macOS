//
//  TextViewDelegateProxy.swift
//  TradukiEditor
//
//  Created by Vergil Choi on 2017/12/20.
//  Copyright © 2017 Vergil Choi. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

class TextViewDelegateProxy: DelegateProxy<NSTextView, NSTextViewDelegate>, DelegateProxyType, NSTextViewDelegate {
    
    init(_ textView: NSTextView) {
        super.init(parentObject: textView, delegateProxy: TextViewDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { TextViewDelegateProxy($0) }
    }
    
    override func setForwardToDelegate(_ forwardToDelegate: NSTextViewDelegate?, retainDelegate: Bool) {
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: true)
    }
    
    
    static func setCurrentDelegate(_ delegate: TextViewDelegateProxy.Delegate?, to object: TextViewDelegateProxy.ParentObject) {
        object.delegate = delegate
    }
    
    static func currentDelegate(for object: TextViewDelegateProxy.ParentObject) -> TextViewDelegateProxy.Delegate? {
        return object.delegate
    }
}

extension Reactive where Base: NSTextView {
    var delegate: TextViewDelegateProxy {
        return TextViewDelegateProxy.proxy(for: base)
    }
    
    var textDidChange: Observable<String?> {
        return delegate
            .methodInvoked(#selector(NSTextViewDelegate.textDidChange(_:)))
            .map({ _ in
                return self.base.textStorage?.string
            })
            .takeUntil(deallocated)
    }
    
    var didBecomeFirstResponder: Observable<Bool> {
        return base
            .rx
            .methodInvoked(#selector(NSTextView.becomeFirstResponder))
            .map({ _ in true })
            .takeUntil(deallocated)
    }
    
    var didResignFirstResponder: Observable<Bool> {
        return base
            .rx
            .methodInvoked(#selector(NSTextView.resignFirstResponder))
            .map({ _ in false })
            .takeUntil(deallocated)
    }
}
