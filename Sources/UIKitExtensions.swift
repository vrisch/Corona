//
//  UIKitExtensions.swift
//  Corona-iOS
//
//  Created by Magnus Nilsson on 2017-09-08.
//  Copyright © 2017 Corona. All rights reserved.
//

import Orbit
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
            return Disposables(object: targetAction)
        }
    }
    
    public static let control: (UIControl?) -> Binder = { control in
        return Binder { change in
            guard let control = control else { return Disposables() }
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
            return Disposables(object: targetAction)
        }
    }
    
    public static let textField: (UITextField?) -> Binder = { textField in
        return Binder { change in
            guard let textField = textField else { return Disposables() }
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
            return Disposables(object: targetAction)
        }
    }
    
    public static let segmentedControl: (UISegmentedControl?) -> Binder = { segmentedControl in
        return Binder { change in
            guard let segmentedControl = segmentedControl else { return Disposables() }
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
            return Disposables(object: targetAction)
        }
    }
}
/*
internal class TargetSelector: NSObject {
    init(target: UIControl?, change: @escaping Change) {
        self.barButtonItem = nil
        self.control = target
        self.change = change
        super.init()
        
        control?.addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
        control?.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        control?.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
    }
    init(target: UIBarButtonItem?, change: @escaping Change) {
        self.barButtonItem = target
        self.control = nil
        self.change = change
        super.init()
        
        barButtonItem?.target = self
        barButtonItem?.action = #selector(touchUpInside(_:))
    }
    
    deinit {
        barButtonItem?.target = nil
        barButtonItem?.action = nil
        control?.removeTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
        control?.removeTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        control?.removeTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
    }
    
    @objc func editingChanged(_ sender: Any) {
        if let textField = sender as? UITextField {
            if let text = textField.text {
                try! change(.valueChanged(.string(text)))
            }
            if let attributedText = textField.attributedText {
                try! change(.valueChanged(.attributedString(attributedText)))
            }
        }
    }
    
    @objc func touchUpInside(_ sender: Any) {
        try! change(.actionPerformed(.empty))
    }
    
    @objc func valueChanged(_ sender: Any) {
        if let segementedControl = sender as? UISegmentedControl {
            let selectedSegmentIndex = segementedControl.selectedSegmentIndex
            try! change(.valueChanged(.index(selectedSegmentIndex)))
            if let title = segementedControl.titleForSegment(at: selectedSegmentIndex) {
                try! change(.valueChanged(.string(title)))
            }
        }
        try! change(.actionPerformed(.empty))
    }
    
    private weak var barButtonItem: UIBarButtonItem?
    private weak var control: UIControl?
    private let change: Change
}
*/
