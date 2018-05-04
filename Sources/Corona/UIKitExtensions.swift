//
//  UIKitExtensions.swift
//  Corona-iOS
//
//  Created by Magnus Nilsson on 2017-09-08.
//  Copyright © 2017 Corona. All rights reserved.
//

#if canImport(UIKit)
import UIKit

fileprivate extension Event.Kind {
    var controlEvents: UIControlEvents? {
        switch self {
        case .editingChanged: return .editingChanged
        case .editingDidEndOnExit: return .editingDidEndOnExit
        case .primaryActionTriggered: return .primaryActionTriggered
        case .textViewDidChange: return nil
        case .textViewDidChangeSelection: return nil
        case .textViewDidEndEditing: return nil
        case .touchUpInside: return .touchUpInside
        case .valueChanged: return .valueChanged
        }
    }
}

public extension UIBarButtonItem {
    
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

public extension UIButton {
    
    public func bind() -> Event {
        return Event { kind, action in
            return [
                TargetAction(target: self, perform: {
                    try action(.empty)
                }, add: { targetAction in
                    self.addTarget(targetAction, action: #selector(TargetAction.action(_:)), for: kind.controlEvents!)
                }, remove: { targetAction in
                    self.removeTarget(targetAction, action: #selector(TargetAction.action(_:)), for: kind.controlEvents!)
                })
            ]
        }
    }
}

public extension UITextField {
    
    public func bind() -> Event {
        return Event { kind, action in
            return [
                TargetAction(target: self, perform: {
                    switch kind {
                    case .editingChanged:
                        if let text = self.text {
                            try action(.string(text))
                        }
                        if let attributedText = self.attributedText {
                            try action(.attributedString(attributedText))
                        }
                    case .editingDidEndOnExit:
                        try action(.empty)
                    default:
                        break
                    }
                }, add: { targetAction in
                    self.addTarget(targetAction, action: #selector(TargetAction.action(_:)), for: kind.controlEvents!)
                }, remove: { targetAction in
                    self.removeTarget(targetAction, action: #selector(TargetAction.action(_:)), for: kind.controlEvents!)
                })
            ]
        }
    }
}

public extension UISegmentedControl {
    
    public func bind() -> Event {
        return Event { kind, action in
            return [
                TargetAction(target: self, perform: {
                    let selectedSegmentIndex = self.selectedSegmentIndex
                    try action(.index(selectedSegmentIndex))
                    if let title = self.titleForSegment(at: selectedSegmentIndex) {
                        try action(.string(title))
                    }
                }, add: { targetAction in
                    self.addTarget(targetAction, action: #selector(TargetAction.action(_:)), for: kind.controlEvents!)
                }, remove: { targetAction in
                    self.removeTarget(targetAction, action: #selector(TargetAction.action(_:)), for: kind.controlEvents!)
                })
            ]
        }
    }
}

public extension UITextView {
    
    public func bind() -> Event {
        return Event { kind, action in
            return [
                TextViewDelegate(target: self, perform: { kind2 in
                    if kind == kind2 {
                        switch kind {
                        case .textViewDidChange:
                            if let text = self.text {
                                try action(.string(text))
                            }
                            if let attributedText = self.attributedText {
                                try action(.attributedString(attributedText))
                            }
                        case .textViewDidChangeSelection:
                            try action(.range(self.selectedRange))
                        case .textViewDidEndEditing:
                            try action(.empty)
                        default:
                            break
                        }
                    }
                })
            ]
        }
    }
}

fileprivate class TextViewDelegate: NSObject, UITextViewDelegate {
    
    required init(target: UITextView?, perform: @escaping (Event.Kind) throws -> Void) {
        self.target = target
        self.perform = perform
        super.init()
        target?.delegate = self
    }
    
    deinit {
        target?.delegate = nil
    }
    
    @objc func textViewDidChange(_ textView: UITextView) {
        try! perform(.textViewDidChange)
    }
    
    @objc func textViewDidChangeSelection(_ textView: UITextView) {
        try! perform(.textViewDidChangeSelection)
    }
    
    @objc func textViewDidEndEditing(_ textView: UITextView) {
        try! perform(.textViewDidEndEditing)
    }
    
    private weak var target: UITextView?
    private let perform: (Event.Kind) throws -> Void
}
#endif
