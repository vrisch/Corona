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
    var controlEvents: UIControlEvents {
        switch self {
        case .editingChanged: return .editingChanged
        case .editingDidEndOnExit: return .editingDidEndOnExit
        case .primaryActionTriggered: return .primaryActionTriggered
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
                        control.addTarget(targetAction, action: #selector(TargetAction.action(_:)), for: kind.controlEvents)
                    }, remove: { targetAction in
                        control.removeTarget(targetAction, action: #selector(TargetAction.action(_:)), for: kind.controlEvents)
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
                        textField.addTarget(targetAction, action: #selector(TargetAction.action(_:)), for: kind.controlEvents)
                    }, remove: { targetAction in
                        textField.removeTarget(targetAction, action: #selector(TargetAction.action(_:)), for: kind.controlEvents)
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
                        segmentedControl.addTarget(targetAction, action: #selector(TargetAction.action(_:)), for: kind.controlEvents)
                    }, remove: { targetAction in
                        segmentedControl.removeTarget(targetAction, action: #selector(TargetAction.action(_:)), for: kind.controlEvents)
                    })
                ]
            }
        }
    }
}

public extension Binder {
    
    public static let barButtonItem: (UIBarButtonItem) -> Binder = { barButtonItem in
        return Binder { change in
            let targetAction = TargetAction(
                target: barButtonItem,
                change: change,
                add: { targetAction in
                    barButtonItem.target = targetAction
                    barButtonItem.action = #selector(TargetAction.action(_:))
            },
                transform: { change in
                    try change(.actionPerformed(.empty))
            },
                remove: { targetAction in
                    barButtonItem.target = nil
                    barButtonItem.action = nil
            })
            return [targetAction]
        }
    }
    
    public static let control: (UIControl?) -> Binder = { control in
        return Binder { change in
            var disposables: [Any] = []
            guard let control = control else { return disposables }
            do {
                let targetAction = TargetAction(
                    target: control,
                    change: change,
                    add: { targetAction in
                        control.addTarget(targetAction, action: #selector(TargetAction.action(_:)), for: .touchUpInside)
                },
                    transform: { change in
                        try change(.actionPerformed(.empty))
                },
                    remove: { targetAction in
                        control.removeTarget(targetAction, action: #selector(TargetAction.action(_:)), for: .touchUpInside)
                })
                disposables.append(targetAction)
            }
            do {
                let targetAction = TargetAction(
                    target: control,
                    change: change,
                    add: { targetAction in
                        control.addTarget(targetAction, action: #selector(TargetAction.action(_:)), for: .primaryActionTriggered)
                },
                    transform: { change in
                        try change(.actionPerformed(.empty))
                },
                    remove: { targetAction in
                        control.removeTarget(targetAction, action: #selector(TargetAction.action(_:)), for: .primaryActionTriggered)
                })
                disposables.append(targetAction)
            }
            return disposables
        }
    }
    
    public static let textField: (UITextField?) -> Binder = { textField in
        return Binder { change in
            var disposables: [Any] = []
            guard let textField = textField else { return disposables }
            do {
                let targetAction = TargetAction(
                    target: textField,
                    change: change,
                    add: { targetAction in
                        textField.addTarget(targetAction, action: #selector(TargetAction.action(_:)), for: .editingChanged)
                },
                    transform: { change in
                        if let text = textField.text {
                            try change(.valueChanged(.string(text)))
                        }
                        if let attributedText = textField.attributedText {
                            try change(.valueChanged(.attributedString(attributedText)))
                        }
                },
                    remove: { targetAction in
                        textField.removeTarget(targetAction, action: #selector(TargetAction.action(_:)), for: .editingChanged)
                })
                disposables.append(targetAction)
            }
            do {
                let targetAction = TargetAction(
                    target: textField,
                    change: change,
                    add: { targetAction in
                        textField.addTarget(targetAction, action: #selector(TargetAction.action(_:)), for: .editingDidEndOnExit)
                },
                    transform: { change in
                        try change(.actionPerformed(.empty))
                },
                    remove: { targetAction in
                        textField.removeTarget(targetAction, action: #selector(TargetAction.action(_:)), for: .editingDidEndOnExit)
                })
                disposables.append(targetAction)
            }
            return disposables
        }
    }
    
    public static let segmentedControl: (UISegmentedControl?) -> Binder = { segmentedControl in
        return Binder { change in
            guard let segmentedControl = segmentedControl else { return [] }
            let targetAction = TargetAction(
                target: segmentedControl,
                change: change,
                add: { targetAction in
                    segmentedControl.addTarget(targetAction, action: #selector(TargetAction.action(_:)), for: .valueChanged)
            },
                transform: { change in
                    let selectedSegmentIndex = segmentedControl.selectedSegmentIndex
                    try change(.valueChanged(.index(selectedSegmentIndex)))
                    if let title = segmentedControl.titleForSegment(at: selectedSegmentIndex) {
                        try change(.valueChanged(.string(title)))
                    }
            },
                remove: { targetAction in
                    segmentedControl.removeTarget(targetAction, action: #selector(TargetAction.action(_:)), for: .valueChanged)
            })
            return [targetAction]
        }
    }
}
#endif
