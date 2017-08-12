//
//  TargetSelector.swift
//  Corona-iOS
//
//  Created by Magnus on 2017-07-27.
//  Copyright © 2017 Corona. All rights reserved.
//

import UIKit

internal extension Bindings {
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
}
