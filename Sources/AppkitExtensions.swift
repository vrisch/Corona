//
//  AppkitExtensions.swift
//  Corona-macOS
//
//  Created by Magnus Nilsson on 2017-09-08.
//  Copyright © 2017 Corona. All rights reserved.
//

import Orbit
import Cocoa

public extension Binder {

    public static let toolbarItem: (NSToolbarItem) -> Binder = { toolbarItem in
        return Binder { change in
            let targetAction = TargetAction(
                target: toolbarItem,
                change: change,
                add: { targetAction in
                    toolbarItem.target = targetAction
                    toolbarItem.action = #selector(TargetAction.action(_:))
            },
                transform: { change in
                    try change(.actionPerformed(.empty))
            },
                remove: { targetAction in
                    toolbarItem.target = nil
                    toolbarItem.action = nil
            })
            return Disposables(object: targetAction)
        }
    }

    public static let textView: (NSTextView?) -> Binder = { textView in
        return Binder { change in
            return Disposables(object: TextViewDelegate(target: textView, change: change))
        }
    }
}

internal class TextViewDelegate: NSObject, NSTextViewDelegate {
    
    required init(target: NSTextView?, change: @escaping Change) {
        self.target = target
        self.change = change
        super.init()
        target?.delegate = self
    }

    deinit {
        target?.delegate = nil
    }

    @objc func textDidChange(_ notification: Notification) {
        if let textView = target {
            try! change(.valueChanged(.string(textView.string)))
        }
        if let textView = target {
            try! change(.valueChanged(.attributedString(textView.attributedString())))
        }
    }

    @objc func textViewDidChangeSelection(_ notification: Notification) {
        if let textView = target {
            try! change(.selectionChanged(.range(textView.selectedRange)))
        }
    }

    private weak var target: NSTextView?
    private let change: Change
}
