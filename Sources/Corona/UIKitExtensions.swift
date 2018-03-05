//
//  UIKitExtensions.swift
//  Corona-iOS
//
//  Created by Magnus Nilsson on 2017-09-08.
//  Copyright © 2017 Corona. All rights reserved.
//

#if os(iOS)
import UIKit

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
