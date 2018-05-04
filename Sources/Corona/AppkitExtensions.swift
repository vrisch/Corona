//
//  AppkitExtensions.swift
//  Corona-macOS
//
//  Created by Magnus Nilsson on 2017-09-08.
//  Copyright © 2017 Corona. All rights reserved.
//

#if canImport(Cocoa)
import Cocoa

public extension NSControl {
    
    public func bind() -> Event {
        return Event { kind, action in
            return [
                TargetAction(target: self, perform: {
                    try action(.empty)
                }, add: { targetAction in
                    self.target = targetAction
                    self.action = #selector(TargetAction.action(_:))
                }, remove: { targetAction in
                    self.target = nil
                    self.action = nil
                })
            ]
        }
    }
}

public extension NSMenuItem {
    
    public func bind() -> Event {
        return Event { kind, action in
            return [
                TargetAction(target: self, perform: {
                    try action(.empty)
                }, add: { targetAction in
                    self.target = targetAction
                    self.action = #selector(TargetAction.action(_:))
                }, remove: { targetAction in
                    self.target = nil
                    self.action = nil
                })
            ]
        }
    }
}

public extension NSTextView {
    
    public func bind() -> Event {
        return Event { kind, action in
            return [
                TextViewDelegate(target: self, perform: { kind2 in
                    if kind == kind2 {
                        switch kind {
                        case .textViewDidChange:
                            try action(.string(self.string))
                            try action(.attributedString(self.attributedString()))
                        case .textViewDidChangeSelection:
                            try action(.range(self.selectedRange))
                        default:
                            break
                        }
                    }
                })
            ]
        }
    }
}

public extension NSToolbarItem {
    
    public func bind() -> Event {
        return Event { kind, action in
            return [
                TargetAction(target: self, perform: {
                    try action(.empty)
                }, add: { targetAction in
                    self.target = targetAction
                    self.action = #selector(TargetAction.action(_:))
                }, remove: { targetAction in
                    self.target = nil
                    self.action = nil
                })
            ]
        }
    }
}

internal class TextViewDelegate: NSObject, NSTextViewDelegate {
    
    required init(target: NSTextView?, perform: @escaping (Event.Kind) throws -> Void) {
        self.target = target
        self.perform = perform
        super.init()
        target?.delegate = self
    }
    
    deinit {
        target?.delegate = nil
    }
    
    @objc func textDidChange(_ notification: Notification) {
        try! perform(.textViewDidChange)
    }
    
    @objc func textViewDidChangeSelection(_ notification: Notification) {
        try! perform(.textViewDidChangeSelection)
    }
    
    private weak var target: NSTextView?
    private let perform: (Event.Kind) throws -> Void
}
#endif
