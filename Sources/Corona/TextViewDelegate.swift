//
//  TextViewDelegate.swift
//  Corona-iOS
//
//  Created by Magnus on 2017-07-27.
//  Copyright © 2017 Corona. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension Binder2 {
    
    public static let textView: (UITextView?) -> Binder2 = { textView in
        return Binder2 {
            return Event2 { kind, action in
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

internal class TextViewDelegate: NSObject, UITextViewDelegate {
    
    required init(target: UITextView?, perform: @escaping (Event2.Kind) throws -> Void) {
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
    private let perform: (Event2.Kind) throws -> Void
}
#endif
