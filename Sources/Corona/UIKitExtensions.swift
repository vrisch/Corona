//
//  UIKitExtensions.swift
//  Corona-iOS
//
//  Created by Magnus Nilsson on 2017-09-08.
//  Copyright © 2017 Corona. All rights reserved.
//

#if os(iOS)
import UIKit

fileprivate extension Event2.Kind {
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

public extension Binder2 {
    
    public static let barButtonItem: (UIBarButtonItem) -> Binder2 = { barButtonItem in
        return Binder2 {
            return Event2 { kind, action in
                return [
                    TargetAction2(target: barButtonItem, perform: {
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

    public static let control: (UIControl?) -> Binder2 = { control in
        return Binder2 {
            guard let control = control else { return nil }
            return Event2 { kind, action in
                return [
                    TargetAction2(target: control, perform: {
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
    
    public static let textField: (UITextField?) -> Binder2 = { textField in
        return Binder2 {
            guard let textField = textField else { return nil }
            return Event2 { kind, action in
                return [
                    TargetAction2(target: textField, perform: {
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

    public static let segmentedControl: (UISegmentedControl?) -> Binder2 = { segmentedControl in
        return Binder2 {
            guard let segmentedControl = segmentedControl else { return nil }
            return Event2 { kind, action in
                return [
                    TargetAction2(target: segmentedControl, perform: {
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
}

#endif
