//
//  UIKitExtensions.swift
//  Corona-iOS
//
//  Created by Magnus Nilsson on 2017-09-08.
//  Copyright © 2017 Corona. All rights reserved.
//

#if os(iOS)
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

public extension Binder {
    
    public static let barButtonItem: (UIBarButtonItem) -> Binder = { barButtonItem in
        return Binder {
            return Event { kind, action in
                return [
                    TargetAction(target: barButtonItem, perform: {
                        try action(.empty)
                    }, add: { targetAction in
                        barButtonItem.target = targetAction
                        barButtonItem.action = #selector(TargetAction.action(_:))
                    }, remove: { targetAction in
                        barButtonItem.target = nil
                        barButtonItem.action = nil
                    })
                ]
            }
        }
    }

    public static let control: (UIControl?) -> Binder = { control in
        return Binder {
            guard let control = control else { return nil }
            return Event { kind, action in
                return [
                    TargetAction(target: control, perform: {
                        try action(.empty)
                    }, add: { targetAction in
                        control.addTarget(targetAction, action: #selector(TargetAction.action(_:)), for: kind.controlEvents!)
                    }, remove: { targetAction in
                        control.removeTarget(targetAction, action: #selector(TargetAction.action(_:)), for: kind.controlEvents!)
                    })
                ]
            }
        }
    }
    
    public static let textField: (UITextField?) -> Binder = { textField in
        return Binder {
            guard let textField = textField else { return nil }
            return Event { kind, action in
                return [
                    TargetAction(target: textField, perform: {
                        switch kind {
                        case .editingChanged:
                            if let text = textField.text {
                                try action(.string(text))
                            }
                            if let attributedText = textField.attributedText {
                                try action(.attributedString(attributedText))
                            }
                        case .editingDidEndOnExit:
                            try action(.empty)
                        default:
                            break
                        }
                    }, add: { targetAction in
                        textField.addTarget(targetAction, action: #selector(TargetAction.action(_:)), for: kind.controlEvents!)
                    }, remove: { targetAction in
                        textField.removeTarget(targetAction, action: #selector(TargetAction.action(_:)), for: kind.controlEvents!)
                    })
                ]
            }
        }
    }

    public static let segmentedControl: (UISegmentedControl?) -> Binder = { segmentedControl in
        return Binder {
            guard let segmentedControl = segmentedControl else { return nil }
            return Event { kind, action in
                return [
                    TargetAction(target: segmentedControl, perform: {
                        let selectedSegmentIndex = segmentedControl.selectedSegmentIndex
                        try action(.index(selectedSegmentIndex))
                        if let title = segmentedControl.titleForSegment(at: selectedSegmentIndex) {
                            try action(.string(title))
                        }
                    }, add: { targetAction in
                        segmentedControl.addTarget(targetAction, action: #selector(TargetAction.action(_:)), for: kind.controlEvents!)
                    }, remove: { targetAction in
                        segmentedControl.removeTarget(targetAction, action: #selector(TargetAction.action(_:)), for: kind.controlEvents!)
                    })
                ]
            }
        }
    }

    public static let textView: (UITextView?) -> Binder = { textView in
        return Binder {
            return Event { kind, action in
                return [
                    TextViewDelegate(target: textView, perform: { kind2 in
                        if kind == kind2 {
                            switch kind {
                            case .textViewDidChange:
                                if let text = textView?.text {
                                    try action(.string(text))
                                }
                                if let attributedText = textView?.attributedText {
                                    try action(.attributedString(attributedText))
                                }
                            case .textViewDidChangeSelection:
                                if let selectedRange = textView?.selectedRange {
                                    try action(.range(selectedRange))
                                }
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
