//
//  AppkitExtensions.swift
//  Corona-macOS
//
//  Created by Magnus Nilsson on 2017-09-08.
//  Copyright © 2017 Corona. All rights reserved.
//

#if os(OSX)
import Cocoa

public extension Binder {
    
    public static let control: (NSControl?) -> Binder = { control in
        return Binder {
            guard let control = control else { return nil }
            return Event { kind, action in
                return [
                    TargetAction(target: control, perform: {
                        try action(.empty)
                    }, add: { targetAction in
                        control.target = targetAction
                        control.action = #selector(TargetAction.action(_:))
                    }, remove: { targetAction in
                        control.target = nil
                        control.action = nil
                    })
                ]
            }
        }
    }
    
    public static let menuItem: (NSMenuItem?) -> Binder = { menuItem in
        return Binder {
            guard let menuItem = menuItem else { return nil }
            return Event { kind, action in
                return [
                    TargetAction(target: menuItem, perform: {
                        try action(.empty)
                    }, add: { targetAction in
                        menuItem.target = targetAction
                        menuItem.action = #selector(TargetAction.action(_:))
                    }, remove: { targetAction in
                        menuItem.target = nil
                        menuItem.action = nil
                    })
                ]
            }
        }
    }
    
    public static let textView: (NSTextView?) -> Binder = { textView in
        return Binder {
            return Event { kind, action in
                return [
                    TextViewDelegate(target: textView, perform: { kind2 in
                        if kind == kind2 {
                            switch kind {
                            case .textViewDidChange:
                                if let string = textView?.string {
                                    try action(.string(string))
                                }
                                if let attributedString = textView?.attributedString() {
                                    try action(.attributedString(attributedString))
                                }
                            case .textViewDidChangeSelection:
                                if let selectedRange = textView?.selectedRange {
                                    try action(.range(selectedRange))
                                }
                            default:
                                break
                            }
                        }
                    })
                ]
            }
        }
    }
    
    public static let toolbarItem: (NSToolbarItem) -> Binder = { toolbarItem in
        return Binder {
            return Event { kind, action in
                return [
                    TargetAction(target: toolbarItem, perform: {
                        try action(.empty)
                    }, add: { targetAction in
                        toolbarItem.target = targetAction
                        toolbarItem.action = #selector(TargetAction.action(_:))
                    }, remove: { targetAction in
                        toolbarItem.target = nil
                        toolbarItem.action = nil
                    })
                ]
            }
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
