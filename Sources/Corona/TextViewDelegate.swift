//
//  TextViewDelegate.swift
//  Corona-iOS
//
//  Created by Magnus on 2017-07-27.
//  Copyright © 2017 Corona. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
    
    public extension Binder {
        
        public static let textView: (UITextView?) -> Binder = { textView in
            return Binder { change in
                return [TextViewDelegate(target: textView, change: change)]
            }
        }
    }
    
    internal class TextViewDelegate: NSObject, UITextViewDelegate {
        
        required init(target: UITextView?, change: @escaping Change) {
            self.target = target
            self.change = change
            super.init()
            target?.delegate = self
        }
        
        deinit {
            target?.delegate = nil
        }
        
        @objc func textViewDidChange(_ textView: UITextView) {
            if let text = textView.text {
                try! change(.valueChanged(.string(text)))
            }
            if let attributedText = textView.attributedText {
                try! change(.valueChanged(.attributedString(attributedText)))
            }
        }
        
        @objc func textViewDidChangeSelection(_ textView: UITextView) {
            try! change(.selectionChanged(.range(textView.selectedRange)))
        }
        
        @objc func textViewDidEndEditing(_ textView: UITextView) {
            try! change(.actionPerformed(.empty))
        }
        
        private weak var target: UITextView?
        private let change: Change
    }
#endif
